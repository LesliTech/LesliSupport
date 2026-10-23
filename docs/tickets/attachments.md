# Ticket Attachments

The **Attachments** tab on a ticket lets authorized users upload, download, and remove files. Attachments are scoped to both the current Lesli account and the ticket; knowing an attachment ID does not provide access across accounts.

LesliSupport stores attachment ownership and labels in `lesli_support_items_attachments`. The file itself and its technical metadata are managed by Rails Active Storage.

## Setup

The host application, rather than Lesli Core or an individual engine, owns the
Active Storage infrastructure. It must contain these shared tables:

| Table | Responsibility |
| --- | --- |
| `active_storage_blobs` | File metadata, checksum, storage key, and service name |
| `active_storage_attachments` | Association between a blob and a Lesli attachment record |
| `active_storage_variant_records` | Generated image and preview variants |

If the host does not already use Active Storage, install its migration once:

```shell
bin/rails active_storage:install
bin/rails db:migrate
```

The Lesli-specific `lesli_support_items_attachments` table does not replace
these Rails tables. `bin/rails lesli:db:prepare` can apply a generated Active
Storage migration, but it does not run `active_storage:install` or create that
migration. Do not install separate Active Storage tables for each Lesli engine.

Development and test environments can use the disk service. AWS S3 and Cloudflare R2 use the Active Storage S3 adapter and require `aws-sdk-s3` in the host application.

## Supported Files

The default maximum size is 25 MB. The first implementation accepts common images, PDF, plain text, CSV, ZIP, and Microsoft Office formats. An engine can override `lesli_attachment_max_file_size` or `lesli_attachment_content_types` on its concrete attachment model.

Files are private by default. Downloads pass through the authenticated Lesli endpoint, which verifies account ownership before generating a five-minute service URL. Provider URLs and credentials are never persisted in the LesliSupport attachment table.

## Storage Services

Select the service in the host application's environment configuration:

```ruby
config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym
```

Set `ACTIVE_STORAGE_SERVICE=amazon` or
`ACTIVE_STORAGE_SERVICE=cloudflare` in production after defining that service
in `config/storage.yml`. If production uses `local`, mount the Rails `storage`
directory on persistent storage; container-local files are lost when a
container is replaced.

An S3-compatible configuration for Cloudflare R2 looks like:

```yaml
cloudflare:
  service: S3
  access_key_id: <%= ENV.fetch("R2_ACCESS_KEY_ID") %>
  secret_access_key: <%= ENV.fetch("R2_SECRET_ACCESS_KEY") %>
  region: auto
  bucket: <%= ENV.fetch("R2_BUCKET") %>
  endpoint: <%= ENV.fetch("R2_ENDPOINT") %>
  force_path_style: true
```

The initial implementation sends uploads through Rails. Browser-to-storage direct uploads and upload progress can be added without changing the attachment domain model.
