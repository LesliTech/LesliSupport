# Changelog

## 1.2.3 (unreleased)

- Update compatibility for Lesli 5.1, Ruby 3.3.5, and Rails 8.1.
- Integrate the final Activity, Task, Discussion, and Attachment Item APIs with
  Support tickets and local Support accounts.
- Record ticket changes transactionally with actor and `from`/`to` metadata.
- Add Active Storage ticket attachments, private downloads, tenant access
  checks, tests, and S3-compatible provider documentation.
- Adopt the shared LesliActions engine workflow.

Applications using attachments must follow the
[Active Storage setup](docs/tickets/attachments.md).
