# FlowOps

## Real-Time Engineering Operations Intelligence Platform

FlowOps is a cloud-native streaming data engineering platform built on Google Cloud.

It captures real-time GitHub webhook events, transports them through Pub/Sub, processes and validates them using Cloud Run services, stores them in BigQuery, and produces engineering intelligence dashboards for repositories, pull requests, CI/CD workflows, deployments, and releases.

## Technology Stack

- Python
- Google Cloud Run
- Google Cloud Pub/Sub
- BigQuery
- Cloud Storage
- Secret Manager
- Docker
- Terraform
- GitHub Actions
- Looker Studio

## Architecture

```
GitHub
    ↓
Cloud Run Webhook Receiver
    ↓
Pub/Sub
    ↓
Cloud Run Event Processor
    ↓
BigQuery
    ↓
Looker Studio
```

## Status

🚧 Currently under development. 60% DONE
Pull request webhook pipeline test.

Additional pull request synchronization test.

Second pull request webhook test.

Pull request synchronize event test.

Pull request synchronize lifecycle test.

Synchronize test after PR opened: 2026-07-15 17:59:56

Synchronize test after PR opened: 2026-07-15 18:04:45
