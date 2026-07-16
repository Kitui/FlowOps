import json

import apache_beam as beam
from apache_beam.testing.test_pipeline import TestPipeline as BeamTestPipeline
from apache_beam.testing.util import assert_that, equal_to

from flowops_beam.transforms import (
    ParsePubSubEvent,
    to_raw_bigquery_row,
)


def test_parse_valid_event() -> None:
    event = {
        "event_id": "event-001",
        "delivery_id": "delivery-001",
        "source": "github",
        "event_type": "push",
        "repository": "Kitui/FlowOps",
        "received_at": "2026-07-16T10:00:00Z",
        "schema_version": "1.0",
        "payload": {
            "ref": "refs/heads/main",
        },
    }

    with BeamTestPipeline() as pipeline:
        result = (
            pipeline
            | "Create valid event"
            >> beam.Create([json.dumps(event).encode("utf-8")])
            | "Parse valid event"
            >> beam.ParDo(ParsePubSubEvent()).with_outputs(
                ParsePubSubEvent.INVALID_TAG,
                main="valid",
            )
        )

        delivery_ids = result.valid | "Extract delivery ID" >> beam.Map(
            lambda row: row["delivery_id"]
        )

        assert_that(
            delivery_ids,
            equal_to(["delivery-001"]),
        )


def test_parse_invalid_event() -> None:
    invalid_event = {
        "event_id": "event-002",
    }

    with BeamTestPipeline() as pipeline:
        result = (
            pipeline
            | "Create invalid event"
            >> beam.Create([json.dumps(invalid_event).encode("utf-8")])
            | "Parse invalid event"
            >> beam.ParDo(ParsePubSubEvent()).with_outputs(
                ParsePubSubEvent.INVALID_TAG,
                main="valid",
            )
        )

        validation_results = (
            result.invalid
            | "Check validation error"
            >> beam.Map(
                lambda row: "Missing required fields" in row["error"]
            )
        )

        assert_that(
            validation_results,
            equal_to([True]),
        )


def test_to_raw_bigquery_row() -> None:
    event = {
        "event_id": "event-003",
        "delivery_id": "delivery-003",
        "source": "github",
        "event_type": "push",
        "repository": "Kitui/FlowOps",
        "received_at": "2026-07-16T10:00:00Z",
        "schema_version": "1.0",
        "payload": {
            "ref": "refs/heads/main",
        },
        "beam_processed_at": "2026-07-16T10:00:01Z",
    }

    row = to_raw_bigquery_row(event)

    assert row["delivery_id"] == "delivery-003"
    assert row["processing_status"] == "processed"
    assert json.loads(row["payload"]) == event["payload"]