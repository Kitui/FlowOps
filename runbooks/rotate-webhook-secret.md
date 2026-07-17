# Rotate Webhook Secret

1. Generate a strong new secret.
2. Add it as a new Secret Manager version.
3. Update the GitHub webhook configuration.
4. Confirm Cloud Run reads the new version.
5. Send a test push event.
6. Verify successful ingestion.
7. Disable obsolete secret versions.

Never place the secret in documentation, screenshots, or Git.
