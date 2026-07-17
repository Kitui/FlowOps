# FlowOps Technical Decisions

## GCP

Selected to build a fully managed cloud streaming platform with Pub/Sub, Dataflow, BigQuery, and Cloud Run.

## Pub/Sub Instead of Kafka

Pub/Sub reduces operational overhead and fits the low-cost managed-service goal. Kafka remains a useful alternative for a separate portfolio project.

## Cloud Run and Dataflow

Both paths are retained because they demonstrate different patterns:

- Cloud Run: lightweight serverless event processing
- Dataflow: distributed streaming and future windowed analytics

## BigQuery

Selected for serverless analytical storage and direct integration with Dataflow.

## Firestore

Used for Cloud Run idempotency because it provides simple low-latency state storage.

## Terraform

Selected to make infrastructure repeatable, reviewable, and recoverable.

## Canonical Event Envelope

Used to standardize metadata across GitHub event types and simplify downstream processing.
