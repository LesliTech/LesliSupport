# Installation

LesliSupport provides account-scoped support tickets, assignments, discussions, tasks, activities, service catalogs, and dashboard summaries. It requires Lesli `~> 5.1.0`.

## Install and Mount

```shell
bundle add lesli_support
```

The standard router mounts it at `/support`:

```ruby
Rails.application.routes.draw do
  Lesli::Router.mount(self)
end
```

For a manual mount:

```ruby
Rails.application.routes.draw do
  mount LesliSupport::Engine => "/support"
end
```

Prepare the database and initialize installed engines:

```shell
bin/rails lesli:db:prepare
```

## Active Storage Requirement

LesliSupport ticket attachments use Rails Active Storage. The host application
must provide the shared Active Storage tables before files can be uploaded.
Install them once if the host does not already use Active Storage:

```shell
bin/rails active_storage:install
bin/rails lesli:db:prepare
```

`active_storage:install` is a standard Rails generator. It creates a migration
for `active_storage_blobs`, `active_storage_attachments`, and
`active_storage_variant_records`. Do not generate separate copies for each
Lesli engine, and do not run the generator again when the host already has
these tables or an equivalent pending migration.

`lesli:db:prepare` applies existing migrations but does not generate the Active
Storage migration. The host also owns `config/storage.yml`, the selected
`config.active_storage.service`, storage credentials, and any provider adapter
such as `aws-sdk-s3`.

See [Ticket Attachments](/engines/support/tickets/attachments/) for local disk,
AWS S3, and Cloudflare R2 configuration.

## Verify the Installation

```shell
bin/rails routes -g support
bin/rails server
```

Visit `http://127.0.0.1:3000/support/tickets`. Ticket type, category, and priority selectors require the corresponding account catalog entries.
