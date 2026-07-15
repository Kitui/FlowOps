import json
import pathlib
import shutil
import subprocess
import sys


PROJECT_ID = "flowops-dev"
LOCATION = "US"
DISPLAY_NAME = "FlowOps Standardize Push Events"
TARGET_DATASET = "flowops_standardized"
SCHEDULE = "every 5 minutes"

SERVICE_ACCOUNT = (
    "flowops-bigquery-transformer@flowops-dev."
    "iam.gserviceaccount.com"
)

SQL_FILE = pathlib.Path(
    r"sql\transformations\merge_push_events.sql"
)


def find_bq_executable() -> str:
    """Find the BigQuery CLI executable on Windows or Unix."""

    executable = shutil.which("bq.cmd") or shutil.which("bq")

    if not executable:
        raise RuntimeError(
            "Could not locate bq.cmd or bq on PATH. "
            "Confirm that the Google Cloud CLI is installed."
        )

    return executable


def read_sql_file() -> str:
    """Read the scheduled-query SQL as a plain string."""

    if not SQL_FILE.exists():
        raise FileNotFoundError(
            f"SQL file not found: {SQL_FILE.resolve()}"
        )

    query = SQL_FILE.read_text(encoding="utf-8").strip()

    if not query:
        raise ValueError(
            f"SQL file is empty: {SQL_FILE.resolve()}"
        )

    return query


def build_transfer_parameters(query: str) -> str:
    """Create the JSON parameters accepted by scheduled_query."""

    return json.dumps(
        {
            "query": query,
        },
        separators=(",", ":"),
    )


def create_scheduled_query() -> int:
    """Create the BigQuery scheduled-query transfer configuration."""

    bq_executable = find_bq_executable()
    query = read_sql_file()
    params = build_transfer_parameters(query)

    command = [
        bq_executable,
        "mk",
        "--transfer_config",
        f"--project_id={PROJECT_ID}",
        f"--location={LOCATION}",
        "--data_source=scheduled_query",
        f"--display_name={DISPLAY_NAME}",
        f"--target_dataset={TARGET_DATASET}",
        f"--schedule={SCHEDULE}",
        f"--service_account_name={SERVICE_ACCOUNT}",
        f"--params={params}",
    ]

    print("Creating scheduled query...")
    print(f"Project: {PROJECT_ID}")
    print(f"Location: {LOCATION}")
    print(f"Display name: {DISPLAY_NAME}")
    print(f"Schedule: {SCHEDULE}")
    print(f"SQL file: {SQL_FILE}")

    result = subprocess.run(
        command,
        check=False,
    )

    if result.returncode != 0:
        print(
            "Scheduled query creation failed.",
            file=sys.stderr,
        )
        return result.returncode

    print("Scheduled query created successfully.")
    return 0


if __name__ == "__main__":
    try:
        exit_code = create_scheduled_query()
    except (
        FileNotFoundError,
        RuntimeError,
        ValueError,
    ) as error:
        print(
            f"Error: {error}",
            file=sys.stderr,
        )
        exit_code = 1

    raise SystemExit(exit_code)