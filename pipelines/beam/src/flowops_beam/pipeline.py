from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Sequence

import apache_beam as beam
from apache_beam.io.gcp.bigquery import BigQueryDisposition
from apache_beam.options.pipeline_options import (
    PipelineOptions,
    SetupOptions,
    StandardOptions,
)

from flowops_beam.transforms import (
    ParsePubSubEvent,
    to_raw_bigquery_row,
)


VALID_TABLE_SCHEMA = {
    "fields": [
        {"name": "event_id", "type": "STRING", "mode": "REQUIRED"},
        {"name": "delivery_id", "type": "STRING", "mode": "REQUIRED"},
        {"name": "source", "type": "STRING", "mode": "REQUIRED"},
        {"name": "event_type", "type": "STRING", "mode": "REQUIRED"},
        {"name": "repository", "type": "STRING", "mode": "REQUIRED"},
        {"name": "received_at", "type": "TIMESTAMP", "mode": "REQUIRED"},
        {"name": "schema_version", "type": "STRING", "mode": "REQUIRED"},
        {"name": "payload", "type": "JSON", "mode": "NULLABLE"},
        {
            "name": "beam_processed_at",
            "type": "TIMESTAMP",
            "mode": "REQUIRED",
        },
        {
            "name": "processing_status",
            "type": "STRING",
            "mode": "REQUIRED",
        },
    ]
}


INVALID_TABLE_SCHEMA = {
    "fields": [
        {"name": "error", "type": "STRING", "mode": "REQUIRED"},
        {"name": "error_type", "type": "STRING", "mode": "REQUIRED"},
        {
            "name": "raw_payload_base64",
            "type": "STRING",
            "mode": "REQUIRED",
        },
        {"name": "failed_at", "type": "TIMESTAMP", "mode": "REQUIRED"},
    ]
}


def read_local_events(
    pipeline: beam.Pipeline,
    input_path: str,
) -> beam.PCollection[bytes]:
    """Read newline-delimited events from a local file."""

    return (
        pipeline
        | "Read local events" >> beam.io.ReadFromText(input_path)
        | "Encode local events"
        >> beam.Map(lambda row: row.encode("utf-8"))
    )


def read_pubsub_events(
    pipeline: beam.Pipeline,
    subscription: str,
) -> beam.PCollection[bytes]:
    """Read canonical FlowOps events from Pub/Sub."""

    return pipeline | "Read PubSub events" >> beam.io.ReadFromPubSub(
        subscription=subscription,
        with_attributes=False,
    )


def write_local_outputs(
    valid_rows: beam.PCollection[dict],
    invalid_rows: beam.PCollection[dict],
    output_prefix: str,
) -> None:
    """Write valid and invalid records to local JSONL files."""

    (
        valid_rows
        | "Serialize valid rows" >> beam.Map(json.dumps)
        | "Write valid local rows"
        >> beam.io.WriteToText(
            f"{output_prefix}-valid",
            file_name_suffix=".jsonl",
        )
    )

    (
        invalid_rows
        | "Serialize invalid rows" >> beam.Map(json.dumps)
        | "Write invalid local rows"
        >> beam.io.WriteToText(
            f"{output_prefix}-invalid",
            file_name_suffix=".jsonl",
        )
    )


def write_bigquery_outputs(
    valid_rows: beam.PCollection[dict],
    invalid_rows: beam.PCollection[dict],
    valid_table: str,
    invalid_table: str,
) -> None:
    """Write valid and invalid records to BigQuery."""

    valid_rows | "Write valid rows to BigQuery" >> beam.io.WriteToBigQuery(
        table=valid_table,
        schema=VALID_TABLE_SCHEMA,
        create_disposition=BigQueryDisposition.CREATE_NEVER,
        write_disposition=BigQueryDisposition.WRITE_APPEND,
        method=beam.io.WriteToBigQuery.Method.STREAMING_INSERTS,
    )

    invalid_rows | "Write invalid rows to BigQuery" >> beam.io.WriteToBigQuery(
        table=invalid_table,
        schema=INVALID_TABLE_SCHEMA,
        create_disposition=BigQueryDisposition.CREATE_NEVER,
        write_disposition=BigQueryDisposition.WRITE_APPEND,
        method=beam.io.WriteToBigQuery.Method.STREAMING_INSERTS,
    )


def build_pipeline(
    pipeline: beam.Pipeline,
    input_mode: str,
    input_path: str | None,
    subscription: str | None,
    output_mode: str,
    output_prefix: str | None,
    valid_table: str | None,
    invalid_table: str | None,
) -> None:
    """Build the FlowOps Beam pipeline."""

    if input_mode == "local":
        if input_path is None:
            raise ValueError(
                "--input is required when --input-mode=local."
            )

        raw_events = read_local_events(
            pipeline=pipeline,
            input_path=input_path,
        )

    elif input_mode == "pubsub":
        if subscription is None:
            raise ValueError(
                "--subscription is required "
                "when --input-mode=pubsub."
            )

        raw_events = read_pubsub_events(
            pipeline=pipeline,
            subscription=subscription,
        )

    else:
        raise ValueError(
            f"Unsupported input mode: {input_mode}"
        )

    parsed_events = (
        raw_events
        | "Parse events"
        >> beam.ParDo(ParsePubSubEvent()).with_outputs(
            ParsePubSubEvent.INVALID_TAG,
            main="valid",
        )
    )

    valid_rows = (
        parsed_events.valid
        | "Convert valid events"
        >> beam.Map(to_raw_bigquery_row)
    )

    invalid_rows = parsed_events.invalid

    if output_mode == "local":
        if output_prefix is None:
            raise ValueError(
                "--output-prefix is required "
                "when --output-mode=local."
            )

        write_local_outputs(
            valid_rows=valid_rows,
            invalid_rows=invalid_rows,
            output_prefix=output_prefix,
        )

    elif output_mode == "bigquery":
        if valid_table is None or invalid_table is None:
            raise ValueError(
                "--valid-table and --invalid-table are required "
                "when --output-mode=bigquery."
            )

        write_bigquery_outputs(
            valid_rows=valid_rows,
            invalid_rows=invalid_rows,
            valid_table=valid_table,
            invalid_table=invalid_table,
        )

    else:
        raise ValueError(
            f"Unsupported output mode: {output_mode}"
        )


def parse_arguments(
    argv: Sequence[str] | None = None,
) -> tuple[argparse.Namespace, list[str]]:
    """Parse FlowOps and Apache Beam arguments."""

    parser = argparse.ArgumentParser(
        description="Run the FlowOps Apache Beam pipeline.",
    )

    parser.add_argument(
        "--input-mode",
        choices=("local", "pubsub"),
        default="local",
        help="Source from which the pipeline reads events.",
    )

    parser.add_argument(
        "--input",
        help="Local newline-delimited JSON input file.",
    )

    parser.add_argument(
        "--subscription",
        help=(
            "Pub/Sub subscription in "
            "projects/PROJECT/subscriptions/SUBSCRIPTION format."
        ),
    )

    parser.add_argument(
        "--output-mode",
        choices=("local", "bigquery"),
        default="local",
        help="Destination for processed records.",
    )

    parser.add_argument(
        "--output-prefix",
        help="Local output-file prefix.",
    )

    parser.add_argument(
        "--valid-table",
        help="BigQuery table in project:dataset.table format.",
    )

    parser.add_argument(
        "--invalid-table",
        help="BigQuery table in project:dataset.table format.",
    )

    return parser.parse_known_args(argv)


def validate_arguments(
    known_args: argparse.Namespace,
) -> None:
    """Validate FlowOps-specific command-line arguments."""

    if known_args.input_mode == "local":
        if not known_args.input:
            raise ValueError(
                "--input is required when --input-mode=local."
            )

        input_path = Path(known_args.input)

        if not input_path.exists():
            raise FileNotFoundError(
                f"Input file does not exist: {input_path}"
            )

    if (
        known_args.input_mode == "pubsub"
        and not known_args.subscription
    ):
        raise ValueError(
            "--subscription is required "
            "when --input-mode=pubsub."
        )

    if (
        known_args.input_mode == "pubsub"
        and known_args.output_mode != "bigquery"
    ):
        raise ValueError(
            "Pub/Sub streaming input currently requires "
            "--output-mode=bigquery."
        )

    if (
        known_args.output_mode == "local"
        and not known_args.output_prefix
    ):
        raise ValueError(
            "--output-prefix is required "
            "when --output-mode=local."
        )

    if known_args.output_mode == "bigquery":
        if not known_args.valid_table:
            raise ValueError(
                "--valid-table is required "
                "when --output-mode=bigquery."
            )

        if not known_args.invalid_table:
            raise ValueError(
                "--invalid-table is required "
                "when --output-mode=bigquery."
            )


def run(argv: Sequence[str] | None = None) -> None:
    """Run the FlowOps Beam pipeline."""

    known_args, beam_args = parse_arguments(argv)

    validate_arguments(known_args)

    pipeline_options = PipelineOptions(beam_args)

    pipeline_options.view_as(
        SetupOptions
    ).save_main_session = True

    pipeline_options.view_as(
        StandardOptions
    ).streaming = known_args.input_mode == "pubsub"

    with beam.Pipeline(options=pipeline_options) as pipeline:
        build_pipeline(
            pipeline=pipeline,
            input_mode=known_args.input_mode,
            input_path=known_args.input,
            subscription=known_args.subscription,
            output_mode=known_args.output_mode,
            output_prefix=known_args.output_prefix,
            valid_table=known_args.valid_table,
            invalid_table=known_args.invalid_table,
        )


if __name__ == "__main__":
    run()