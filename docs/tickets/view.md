# View and Update a Ticket

Select a ticket from `/support/tickets` to open its detail page. The page currently provides these tabs:

| Tab | Purpose |
| --- | --- |
| Information | Update subject, classification, owner, and description |
| Discussions | Add and read a linear list of ticket comments |
| Tasks | Track work attached to the ticket |
| Activities | Review changes to the ticket |
| Attachments | Upload and manage files associated with the ticket |

Saving the information form updates the ticket in place. Discussions, tasks,
activities, and attachments use Lesli's shared item components and routes.

Ticket activity events are recorded by `LesliSupport::TicketService` in the
same transaction as the ticket change. Creation records `ticket_created`.
Changes to owner, type, category, and priority use semantic event codes and
store `from` and `to` snapshots in their metadata. The actor is always the
current user executing the service operation. Removing an optional relation is
represented by a `nil` `to` snapshot.

The shared `LesliView::Items::Activities` component converts those records into
timeline data. Event titles and descriptions are resolved through I18n, while
LesliSupport uses the engine-specific `lesli_support.items.activities` scope
and maps each known event to a Material Symbol. The timeline displays the
actor, event, date, and change description. It loads the 25 most recent
activities initially and displays a translated empty state when no events have
been recorded.

Ticket lookup remains scoped to the current account. Form selectors also load
their options from that account, but ticket updates do not perform an
additional ownership validation for submitted relation IDs.
