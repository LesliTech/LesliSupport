# View and Update a Ticket

Select a ticket from `/support/tickets` to open its detail page. The page currently provides these tabs:

| Tab | Purpose |
| --- | --- |
| Information | Update subject, classification, owner, and description |
| Discussions | Add and read the ticket conversation |
| Tasks | Track work attached to the ticket |
| Activities | Review changes to the ticket |
| Attachments | Reserved in the interface; persistence and rendering are not currently enabled |

Saving the information form updates the ticket in place. Discussion creation is exposed through the ticket's nested discussion route, while tasks and activities use Lesli's shared item components.

All records and selector values must belong to the current account. Authorization and account scoping should remain in the ticket service when extending the page.
