import json
import pathlib
import shutil
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request


PROJECT_ID = "flowops-dev"
LOCATION = "us"
DISPLAY_NAME = "FlowOps Standardize Push Events"

SQL_FILE = pathlib.Path(
    r"sql\transformations\run_all_standardizations.sql"
)


def find_executable(name: str) -> str:
    """Find a command-line executable on PATH."""

    executable = shutil.which(name)

    if not executable and sys.platform == "win32":
        executable = shutil.which(f"{name}.cmd")

    if not executable:
        raise RuntimeError(
            f"Could not find {name} on PATH."
        )

    return executable


def read_master_query() -> str:
    """Read the complete multi-statement SQL query."""

    if not SQL_FILE.exists():
        raise FileNotFoundError(
            f"SQL file not found: {SQL_FILE.resolve()}"
        )

    query = SQL_FILE.read_text(
        encoding="utf-8"
    ).strip()

    if not query:
        raise ValueError(
            f"SQL file is empty: {SQL_FILE.resolve()}"
        )

    return query


def run_command(command: list[str]) -> str:
    """Run a command and return its standard output."""

    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        check=False,
    )

    if result.returncode != 0:
        error_message = (
            result.stderr.strip()
            or result.stdout.strip()
            or "Command failed."
        )

        raise RuntimeError(error_message)

    return result.stdout.strip()


def get_access_token() -> str:
    """Retrieve an OAuth access token from gcloud."""

    gcloud = find_executable("gcloud")

    token = run_command(
        [
            gcloud,
            "auth",
            "print-access-token",
        ]
    )

    if not token:
        raise RuntimeError(
            "gcloud returned an empty access token."
        )

    return token


def list_transfer_configs(
    access_token: str,
) -> list[dict]:
    """List BigQuery transfer configurations in the US location."""

    url = (
        "https://bigquerydatatransfer.googleapis.com/v1/"
        f"projects/{PROJECT_ID}/locations/{LOCATION}/transferConfigs"
    )

    request = urllib.request.Request(
        url,
        headers={
            "Authorization": f"Bearer {access_token}",
            "Accept": "application/json",
        },
        method="GET",
    )

    try:
        with urllib.request.urlopen(request) as response:
            response_body = response.read().decode("utf-8")
    except urllib.error.HTTPError as error:
        error_body = error.read().decode(
            "utf-8",
            errors="replace",
        )

        raise RuntimeError(
            f"Could not list transfer configurations.\n"
            f"HTTP {error.code}: {error_body}"
        ) from error

    payload = json.loads(response_body)

    return payload.get("transferConfigs", [])


def find_transfer_config(
    configs: list[dict],
) -> dict:
    """Find the single FlowOps scheduled query."""

    matches = [
        config
        for config in configs
        if config.get("displayName") == DISPLAY_NAME
    ]

    if not matches:
        raise RuntimeError(
            f"Scheduled query not found: {DISPLAY_NAME}"
        )

    if len(matches) > 1:
        raise RuntimeError(
            f"Multiple schedules found with name: {DISPLAY_NAME}"
        )

    return matches[0]


def update_transfer_config(
    access_token: str,
    config: dict,
    query: str,
) -> dict:
    """Update the scheduled-query SQL through the REST API."""

    resource_name = config.get("name")

    if not resource_name:
        raise RuntimeError(
            "Transfer configuration has no resource name."
        )

    encoded_mask = urllib.parse.quote(
        "params",
        safe="",
    )

    url = (
        "https://bigquerydatatransfer.googleapis.com/v1/"
        f"{resource_name}"
        f"?updateMask={encoded_mask}"
    )

    request_body = json.dumps(
        {
            "name": resource_name,
            "params": {
                "query": query,
            },
        }
    ).encode("utf-8")

    request = urllib.request.Request(
        url,
        data=request_body,
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
        method="PATCH",
    )

    try:
        with urllib.request.urlopen(request) as response:
            response_body = response.read().decode("utf-8")
    except urllib.error.HTTPError as error:
        error_body = error.read().decode(
            "utf-8",
            errors="replace",
        )

        raise RuntimeError(
            f"Schedule update failed.\n"
            f"HTTP {error.code}: {error_body}"
        ) from error

    return json.loads(response_body)


def main() -> int:
    """Update the FlowOps standardization schedule."""

    print("Reading master transformation SQL...")
    query = read_master_query()

    print(f"SQL length: {len(query):,} characters")

    print("Retrieving Google Cloud access token...")
    access_token = get_access_token()

    print("Finding FlowOps scheduled query...")
    configs = list_transfer_configs(access_token)
    config = find_transfer_config(configs)

    resource_name = config["name"]

    print("Updating FlowOps scheduled transformation...")
    print(f"Project: {PROJECT_ID}")
    print(f"Location: {LOCATION}")
    print(f"Schedule: {DISPLAY_NAME}")
    print(f"Configuration: {resource_name}")
    print(f"SQL file: {SQL_FILE}")

    updated_config = update_transfer_config(
        access_token,
        config,
        query,
    )

    print("Schedule updated successfully.")
    print(
        "Updated configuration:",
        updated_config.get("name"),
    )

    return 0


if __name__ == "__main__":
    try:
        exit_code = main()
    except (
        FileNotFoundError,
        json.JSONDecodeError,
        RuntimeError,
        ValueError,
    ) as error:
        print(
            f"Error: {error}",
            file=sys.stderr,
        )
        exit_code = 1

    raise SystemExit(exit_code)