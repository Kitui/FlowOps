# Replay a Failed Event

## Before Replay

- identify the delivery ID
- confirm the original failure cause is fixed
- check whether the event was already stored
- avoid creating duplicate analytical records

## Replay Options

- redeliver the webhook from GitHub
- republish a validated message to Pub/Sub
- pull and inspect a dead-letter message before republishing

Record the replay reason and result for audit purposes.
