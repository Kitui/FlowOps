import os

from dotenv import load_dotenv

load_dotenv()


class Settings:
    """Event Processor configuration."""

    def __init__(self) -> None:
        self.gcp_project_id = self._required("GCP_PROJECT_ID")
        self.bigquery_raw_dataset = self._required(
            "BIGQUERY_RAW_DATASET"
        )
        self.bigquery_raw_table = self._required(
            "BIGQUERY_RAW_TABLE"
        )

    @staticmethod
    def _required(name: str) -> str:
        value = os.getenv(name)

        if not value:
            raise RuntimeError(
                f"{name} environment variable is not configured."
            )

        return value

    @property
    def raw_table_id(self) -> str:
        """Return the fully qualified BigQuery table identifier."""

        return (
            f"{self.gcp_project_id}."
            f"{self.bigquery_raw_dataset}."
            f"{self.bigquery_raw_table}"
        )


settings = Settings()