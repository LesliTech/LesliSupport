# Ticket List

Open `/support/tickets` to view the tickets available to the current account. The table displays:

* Ticket ID
* Subject
* Requesting user
* Assigned agent
* Priority
* Deadline

Results are produced through `LesliSupport::TicketService` and the standard paginated response. Keep any custom filters or exports in that account-scoped service rather than querying all tickets from the controller.

Select a row to open its ticket. Use **Create ticket** in the page header to start a new request.
