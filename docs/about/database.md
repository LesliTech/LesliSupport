# Database

LesliSupport uses collection code `07` and engine code `02`.

| Migration code | Table | Responsibility |
| --- | --- | --- |
| `07.02.00.01.10` | `lesli_support_accounts` | Engine state for a Lesli account |
| `07.02.00.01.10` | `lesli_support_items_tasks` | Tasks attached to supported records |
| `07.02.00.01.10` | `lesli_support_items_activities` | Activity history for supported records |
| `07.02.00.01.10` | `lesli_support_items_discussions` | Linear comments attached to supported records |
| `07.02.00.02.10` | `lesli_support_items_attachments` | File metadata attached to supported records |
| `07.02.00.20.10` | `lesli_support_catalogs` | Account-scoped catalog groups |
| `07.02.00.20.10` | `lesli_support_catalog_items` | Type, category, priority, and other catalog values |
| `07.02.10.01.10` | `lesli_support_slas` | Service-level configuration |
| `07.02.11.01.10` | `lesli_support_tickets` | Ticket details, ownership, classification, and lifecycle dates |

A ticket belongs to a Support account and its creator, may have an assigned owner, and references catalog items for type, category, and priority. Ticket records include the shared tasks, activities, discussions, and attachments features.

Task rows require a Core user, a Support account, a polymorphic taskable, and a
non-blank title. They do not include `deleted_at`; LesliSupport does not expose
an individual task deletion operation.

Discussion rows represent individual comments, not threads. Each row requires
a Core author, a Support account, a polymorphic discussable, and a non-blank
plain-text message. The first version does not provide replies, editing,
deletion, or soft deletion.

Attachment rows contain tenant ownership and domain metadata. Active Storage
owns the corresponding filename, content type, byte size, checksum, and
storage-service key in the host application's shared `active_storage_blobs`,
`active_storage_attachments`, and `active_storage_variant_records` tables.
Those infrastructure tables are installed once in the host; they are not
created by the LesliSupport migration. See
[Ticket Attachments](/engines/support/tickets/attachments/) for setup and
storage-provider configuration.

The current migrations do not create settings, workflows, subscribers, versions, or assignment tables. Some of those integrations remain visible as commented implementation code and must not be treated as persisted features.

```shell
bin/rails lesli:db:prepare
bin/rails db:migrate:status
```

Preserve account ownership in every query and service. See [Database Architecture](/engines/lesli/database/structure) for shared migration helpers and migration naming.
