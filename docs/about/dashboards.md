# Dashboard Components

LesliSupport registers four account-scoped dashboard components:

| Component | Current presentation | Default layout |
| --- | --- | --- |
| `tickets_created` | Tickets grouped by creation date | Standard width and position |
| `tickets_by_category` | Bar chart currently grouped by ticket priority | Standard width and position |
| `tickets_open` | Count of open tickets | Standard width and position |
| `latest_tickets` | Table of the five latest tickets | Width `8`, position `1` |

The `tickets_by_category` name and its current priority-based query do not match. Treat the displayed data as priorities until the implementation or component name is aligned.

All component queries must remain scoped to the current Lesli account. Add explicit empty states when replacing or extending the current partials.

After installing LesliSupport for existing accounts, or after registering a component, run:

```shell
bin/rails lesli_dashboard:register
```

Registration creates missing records without overwriting user-customized layout. See the [LesliDashboard component contract](/engines/dashboard/about/dashboards) before adding another widget.
