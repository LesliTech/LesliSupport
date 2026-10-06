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

## Verify the Installation

```shell
bin/rails routes -g support
bin/rails server
```

Visit `http://127.0.0.1:3000/support/tickets`. Ticket type, category, and priority selectors require the corresponding account catalog entries.
