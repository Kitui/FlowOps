import os

from dotenv import load_dotenv

load_dotenv()


class Settings:
    """Application configuration loaded from environment variables."""

    def __init__(self) -> None:
        self.github_webhook_secret = self._get_required_variable(
            "GITHUB_WEBHOOK_SECRET"
        )
        self.gcp_project_id = self._get_required_variable("GCP_PROJECT_ID")
        self.pubsub_topic_id = self._get_required_variable("PUBSUB_TOPIC_ID")

    @staticmethod
    def _get_required_variable(name: str) -> str:
        value = os.getenv(name)

        if not value:
            raise RuntimeError(
                f"{name} environment variable is not configured."
            )

        return value


settings = Settings()