import hashlib
import hmac


def verify_github_signature(
    *,
    payload_body: bytes,
    signature_header: str,
    webhook_secret: str,
) -> bool:
    """Verify a GitHub webhook HMAC-SHA256 signature."""

    if not signature_header.startswith("sha256="):
        return False

    expected_signature = "sha256=" + hmac.new(
        key=webhook_secret.encode("utf-8"),
        msg=payload_body,
        digestmod=hashlib.sha256,
    ).hexdigest()

    return hmac.compare_digest(
        expected_signature,
        signature_header,
    )