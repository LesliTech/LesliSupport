# View and Update a Ticket

Select a ticket from `/support/tickets` to open its detail page. The page currently provides these tabs:

| Tab | Purpose |
| --- | --- |
| Information | Update subject, classification, owner, and description |
| Discussions | Add and read the ticket conversation |
| Tasks | Track work attached to the ticket |
| Activities | Review changes to the ticket |
| Attachments | Upload and manage files associated with the ticket |

Saving the information form updates the ticket in place. Discussion creation is exposed through the ticket's nested discussion route, while tasks and activities use Lesli's shared item components.

Ticket activity events are recorded by `LesliSupport::TicketService` in the
same transaction as the ticket change. Creation records `ticket_created`.
Changes to owner, type, category, and priority use semantic event codes and
store `from` and `to` snapshots in their metadata. The actor is always the
current user executing the service operation. Removing an optional relation is
represented by a `nil` `to` snapshot.

All records and selector values must belong to the current account. Authorization and account scoping should remain in the ticket service when extending the page.
