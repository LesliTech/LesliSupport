=begin
Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end
module CloudHelp
    class Ticket  < CloudObject
        include ActiveModel::Dirty

        belongs_to :account,    class_name: "CloudHelp::Account",                   foreign_key: "cloud_help_accounts_id"
        belongs_to :user_creator, class_name: "::User",                             foreign_key: "users_id"
        belongs_to :user_main,  class_name: "::User",                               foreign_key: "user_main_id", optional: true
        belongs_to :type,       class_name: "CloudHelp::Catalog::TicketType",       foreign_key: "cloud_help_catalog_ticket_types_id"
        belongs_to :category,   class_name: "CloudHelp::Catalog::TicketCategory",   foreign_key: "cloud_help_catalog_ticket_categories_id", optional: true
        belongs_to :priority,   class_name: "CloudHelp::Catalog::TicketPriority",   foreign_key: "cloud_help_catalog_ticket_priorities_id", optional: true
        belongs_to :source,     class_name: "CloudHelp::Catalog::TicketSource",     foreign_key: "cloud_help_catalog_ticket_sources_id", optional: true
        belongs_to :workspace,  class_name: "CloudHelp::Catalog::TicketWorkspace",  foreign_key: "cloud_help_catalog_ticket_workspaces_id", optional: true
        belongs_to :status,     class_name: "CloudHelp::Workflow::Status",          foreign_key: "cloud_help_workflow_statuses_id"
        belongs_to :sla,        class_name: "CloudHelp::Sla",                       foreign_key: "cloud_help_slas_id"

        has_many :discussions,  foreign_key: "cloud_help_tickets_id"
        has_many :actions,      foreign_key: "cloud_help_tickets_id"
        has_many :files,        foreign_key: "cloud_help_tickets_id"
        has_many :subscribers,  foreign_key: "cloud_help_tickets_id"
        has_many :timelines,    foreign_key: "cloud_help_tickets_id"
        has_many :activities,   foreign_key: "cloud_help_tickets_id"

        has_many :assignments, foreign_key: "cloud_help_tickets_id"
        has_many :histories,   foreign_key: "cloud_help_tickets_id"

        before_validation :set_deadline, :set_type, :set_sla, :set_workflow, :set_workspace, on: :create
        after_update :after_update_actions

        # @return [Boolean] Whether this ticket was successfully saved or not. If it was not saved,
        #     an error is added to the *ticket*'s *errors* attribute
        # @description saves a ticket based on the params allowed by *CloudHelp::TicketsController*. 
        #     If the ticket is new, creates an entry in the timeline. Also, depending on which 
        #     attributes where updated, notifications are sent and entries are added to the timeline
        # @example
        #     ticket_params = {
        #         cloud_help_catalog_ticket_priorities_id: 1,
        #         cloud_help_catalog_ticket_categories_id: 1,
        #         cloud_help_catalog_ticket_types_id: 1
        #     }
        #     ticket = CloudHelp::Ticket.new(ticket_params)
        #     if ticket.save
        #         responseWithSuccessful
        #     else
        #         responseWithError(ticket.errors.full_messages.to_sentence)
        #     end
        def save
            if new_record?
                if super
                    timelines.create(
                        action: Ticket::Timeline.actions[:created],
                        description: nil
                    )
                    return true
                else
                    return false
                end
            end
            super
        end

        # @return [Hash] Detailed information about the ticket. Including, *priority*,
        #     *full* *category* *path*, *type*, *creation* *user*, *assignment* *type*
        #     and *workflow* *status*
        # @description Creates a query that selects all ticket information from several tables
        #     and returns it in a hash
        # @example
        #     ticket = CloudHelp::Ticket.find(43)
        #     puts ticket.show
        #     # will print something like: {
        #     #    id:6,
        #     #    created_at:"2020-01-12T17:31:25.005Z",
        #     #    email:"admin@lesli.cloud",
        #     #    subject:"subject",
        #     #    description:"description",
        #     #    tags:"tags",
        #     #    priority:"Medium",
        #     #    type:"Change Request",
        #     #    status:"created",
        #     #    cloud_help_catalog_ticket_priorities_id:2,
        #     #    cloud_help_catalog_ticket_types_id:2,
        #     #    cloud_help_workflow_statuses_id:4,
        #     #    cloud_help_catalog_ticket_categories_id:1,
        #     #    cloud_help_ticket_statuses_id:1,
        #     #    deadline:null,
        #     #    priority_weight:100,
        #     #    category:"Company System",
        #     #    assignment_attributes:{
        #     #        assignment_type:"none"
        #     #    }
        #     #}
        def show(current_user, query)
            ticket_show_response = TicketServices.show(current_user, self, query)
            return ticket_show_response.payload
        end

        # @param help_account [Account] The account associated to *current_user*
        # @return [Hash] Detailed information about all the tickets. Including, *priority*,
        #     *full* *category* *path*, *type*, *creation* *user*, *assignment* *type*
        #     and *workflow* *status*
        # @description Creates a query that selects all the tickets information from several tables
        #     and returns it in a hash
        # @example
        #     tickets_info = CloudHelp::Ticket.index(current_user.account)
        #     puts tickets_info.to_json
        #     # will print something like: [
        #     #    {
        #     #        "id":1,                     "created_at":"2020-01-08T16:23:10.976Z",
        #     #        "priority":"Low",           "type":"Issue",
        #     #        "status":"created",          "category":"Company System",
        #     #        "assignment_type":null,    "subject":"Testing Ticket"
        #     #    },{
        #     #        "id":2,                     "created_at":"2020-01-08T16:43:30.470Z",
        #     #        "priority":"Low",           "type":"Issue",
        #     #        "status":"closed",           "category":"Company System",
        #     #        "assignment_type":"user",  "subject":"Testin"
        #     #    },{
        #     #        "id":3,                     "created_at":"2020-01-09T18:08:27.622Z",
        #     #        "priority":"Low",           "type":"Change Request",
        #     #        "status":"In Progress",      "category":"Company System, Books Module",
        #     #        "assignment_type":null,    "subject":"Testing"
        #     #    }
        #     #]
        def self.index(current_user, query, params)
            ticket_index_response = TicketServices.index(current_user, query, params)
            tickets = ticket_index_response.payload[:tickets]
            Kaminari.paginate_array(tickets).page(query[:pagination][:page]).per(query[:pagination][:perPage])
        end

        def self.count(current_user)
            ticket_count_response = TicketServices.count(current_user)
            return ticket_count_response.payload
        end

        def self.options(current_user, query)
            types = current_user.account.help.ticket_types.select(:id, :name).order(:name)
            categories = Catalog::TicketCategory.index(current_user, {})[:ticket_categories]
            priorities = current_user.account.help.ticket_priorities.order(weight: :asc).select(:id, :name, :weight)
            workspaces = current_user.account.help.ticket_workspaces.select(:id, :name, :default).order(:name)

            ticket_options = {
                types: types,
                categories: categories,
                priorities: priorities,
                workspaces: workspaces
            }

            if query[:filters][:include] && query[:filters][:include] == "statuses"
                statuses = Workflow::Status.joins(
                    :workflow
                ).joins(
                    "inner join cloud_help_workflow_associations chwA on chwA.cloud_help_workflows_id = cloud_help_workflows.id AND chwA.deleted_at is null"
                ).where(
                    "chwA.workflow_for = ?", "ticket"
                ).select(
                    "cloud_help_workflow_statuses.id",
                    "cloud_help_workflows.name as workflow_name",
                    "cloud_help_workflow_statuses.name as status_name",
                ).order(
                    "cloud_help_workflows.id desc",
                    "cloud_help_workflow_statuses.number asc"
                ).map do |status|
                    {
                        id: status.id,
                        value: status.id,
                        text: "#{I18n.t("core.shared.column_enum_status_#{status.status_name}", default: status.status_name)} - (#{status.workflow_name})"
                    }
                end
                
                ticket_options["statuses"] = statuses
            end

            ticket_options
        end

        def self.tickets_with_deadline(current_user, query)
            tickets = []

            tickets = current_user.account.help.tickets
            .joins("left join cloud_help_ticket_assignments chta on chta.cloud_help_tickets_id = cloud_help_tickets.id and chta.users_id = #{current_user.id}")
            .select(:id, :subject, :description, :deadline)
            .where("cloud_help_tickets.deadline is not null")
            .where("cloud_help_tickets.deadline >= ?", query[:filters][:start_date])
            .where("cloud_help_tickets.deadline <= ? ", query[:filters][:end_date])
            .where("cloud_help_tickets.users_id = ? or cloud_help_tickets.user_main_id = ? or chta.users_id = ?", current_user.id, current_user.id, current_user.id)


            return tickets
        end

        def closed?
            return status.completed_successfully? || status.completed_unsuccessfully?
        end

        #######################################################################################
        ##############################  Activities Log Methods   ##############################
        #######################################################################################

        # @return [void]
        # @param current_user [::User] The user that created the ticket
        # @param [CloudHelp::Ticket] The ticket that was created
        # @description Creates an activity for this ticket indicating who created it. And 
        #   also creates an activity with the initial status of the ticket
        # Example
        #   params = {...}
        #   ticket = CloudHelp::Ticket.create(params)
        #   CloudHelp::Ticket.log_activity_create(User.find(1), ticket)
        def self.log_activity_create(current_user, ticket)
            ticket.activities.create(
                user_creator: current_user,
                category: "action_create"
            )
            
            ticket.activities.create(
                user_creator: current_user,
                category: "action_status",
                description: ticket.status.name,
                field_name: "cloud_help_workflow_statuses_id",
                value_to: ticket.status.name
            )
        end

        # @return [void]
        # @param current_user [::User] The user that created the ticket
        # @param ticket [CloudHelp::Ticket] The ticket that was created
        # @param old_attributes[Hash] The data of the record before update
        # @param new_attributes[Hash] The data of the record after update
        # @description Creates an activity for this ticket if someone changed any of this values
        # Example
        #   ticket = CloudHelp::Ticket.find(1)
        #   old_attributes  = ticket.attributes
        #   ticket.update(user_main: User.find(33))
        #   new_attributes = ticket.attributes
        #   CloudHelp::Ticket.log_activity_update(User.find(1), ticket, old_attributes, new_attributes)
        def self.log_activity_update(current_user, ticket, old_attributes, new_attributes)
            # Main employee is a special case because it's a foreign key
            if old_attributes["user_main_id"] != new_attributes["user_main_id"]
                ticket.activities.create(
                    user_creator: current_user,
                    category: "action_update",
                    field_name: "user_main_id",
                    value_from: ::User.with_deleted.find(old_attributes["user_main_id"]).full_name,
                    value_to:   ::User.with_deleted.find(new_attributes["user_main_id"]).full_name
                )
            end

            # workflow status is a spacial case because it's a foreign key
            if old_attributes["cloud_help_workflow_statuses_id"] != new_attributes["cloud_help_workflow_statuses_id"]
                old_status = Workflow::Status.with_deleted.find(old_attributes["cloud_help_workflow_statuses_id"]).name
                new_status = Workflow::Status.with_deleted.find(new_attributes["cloud_help_workflow_statuses_id"]).name
                ticket.activities.create(
                    user_creator: current_user,
                    description: new_status,
                    category: "action_status",
                    field_name: "cloud_help_workflow_statuses_id",
                    value_from: old_status,
                    value_to: new_status
                )
            end

            # ticket type, category and priority are special cases because they are foreign keys
            ["TicketType", "TicketPriority", "TicketCategory"].each do |field|
                if old_attributes["cloud_help_catalog_#{field.underscore.pluralize}_id"] != new_attributes["cloud_help_catalog_#{field.underscore.pluralize}_id"]
                    old_value = nil
                    new_value = nil

                    if old_attributes["cloud_help_catalog_#{field.underscore.pluralize}_id"]
                        old_value = "CloudHelp::Catalog::#{field}".constantize.with_deleted.find(old_attributes["cloud_help_catalog_#{field.underscore.pluralize}_id"]).name
                    end
                    
                    if new_attributes["cloud_help_catalog_#{field.underscore.pluralize}_id"]
                        new_value = "CloudHelp::Catalog::#{field}".constantize.with_deleted.find(new_attributes["cloud_help_catalog_#{field.underscore.pluralize}_id"]).name
                    end
                    
                    ticket.activities.create(
                        user_creator: current_user,
                        category: "action_update",
                        field_name: "cloud_help_catalog_#{field.underscore.pluralize}_id",
                        value_from: old_value,
                        value_to: new_value
                    )
                end
            end

            # SLA is a special case because it's a foreign key
            if old_attributes["cloud_help_slas_id"] != new_attributes["cloud_help_slas_id"]
                old_sla = Sla.with_deleted.find(old_attributes["cloud_help_slas_id"]).name
                new_sla = Sla.with_deleted.find(new_attributes["cloud_help_slas_id"]).name
                ticket.activities.create(
                    user_creator: current_user,
                    description: new_sla,
                    category: "action_update",
                    field_name: "cloud_help_slas_id",
                    value_from: old_sla,
                    value_to: new_sla
                )
            end

            # We remove values that are not tracked in the activities
            old_attributes = old_attributes.except(
                "id", "created_at", "updated_at", "cloud_help_workflow_statuses_id",
                "cloud_help_catalog_ticket_categories_id", "cloud_help_catalog_ticket_priorities_id", "cloud_help_catalog_ticket_types_id", "cloud_help_slas_id"
            )
            old_attributes.each do |key, value|
                if value != new_attributes[key]
                    value_from = value
                    value_to = new_attributes[key]
                    value_from = LC::Date.to_string_datetime(value_from) if value_from.is_a?(Time) || value_from.is_a?(Date)
                    value_to = LC::Date.to_string_datetime(value_to) if value_to.is_a?(Time) || value_to.is_a?(Date)

                    ticket.activities.create(
                        user_creator: current_user,
                        category: "action_update",
                        field_name: key,
                        value_from: value_from,
                        value_to: value_to
                    )
                end
            end
        end

        # @return [void]
        # @param current_user [::User] The user that deleted the ticket
        # @param [CloudHelp::Ticket] The ticket that was deleted
        # @description Creates an activity for this ticket indicating that someone deleted it
        # Example
        #   ticket = CloudHelp::Ticket.find(1)
        #   CloudHelp::Ticket.log_activity_destroy(User.find(1), ticket)
        def self.log_activity_destroy(current_user, ticket)
            ticket.activities.create(
                user_creator: current_user,
                category: "action_destroy"
            )
        end

        def self.log_activity_create_assignment(current_user, ticket, assignment)
            ticket.activities.create(
                user_creator: current_user,
                category: "action_create_assignment",
                description: assignment.user.full_name,
                value_to: assignment.user.full_name
            )
        end

        def self.log_activity_destroy_assignment(current_user, ticket, assignment)
            ticket.activities.create(
                user_creator: current_user,
                category: "action_destroy_assignment",
                description: assignment.user.full_name,
                value_to: assignment.user.full_name
            )
        end

        def assignments_list
            assignments.where(assignment_type: "user").map do |assignment|
                user = assignment.user
                {
                    name: user.full_name,
                    role: user.role.detail.name,
                    email: user.email,
                    users_id: user.id,
                    id: assignment.id
                }
            end
        end

        def global_identifier
            return "#{id} - #{subject}"
        end

        # Custom is_editab_by? implementation
        def is_editable_by?(current_user, bypass_olp: false, bypass_status: false)
            return false unless current_user

            return false if (! bypass_status) && (status.completed_successfully? || status.completed_unsuccessfully? )

            unless bypass_olp
                current_user_olp = current_user.roles.order(object_level_permission: :desc).first.object_level_permission
                reference_olp = 0

                if user_creator && user_creator.roles.size > 0
                    reference_olp = user_creator.roles.order(object_level_permission: :desc).first.object_level_permission
                elsif user_main && user_main.roles.size > 0
                    reference_olp = user_main.roles.order(object_level_permission: :desc).first.object_level_permission
                end

                # Admin, owner or similar roles can modify a ticket
                if current_user_olp >= object_level_permission_threshold && current_user_olp >= reference_olp
                    return true
                end
            end

            # Any assigned user can also modify this ticket
            if assignments.find_by(users_id: current_user.id)
                return true
            end

            return false
        end

        # @return [Hash] Assignment information about this ticket
        # @description Retrievies and returns assignment information about this ticket.
        #     If there is no assigment, returns a hash containing a "none" in the
        #     *assignment_type* attribute
        # @todo Implement support for *team* assigmation type
        # @example 
        #     puts self.assignments_info
        #     #will print something similar to {
        #     #    assignable_name: "john.doe@email.com",
        #     #    assignment_type: "user"
        #     #}
        def assignments_info
            assignments_data = []
            return assignments_data if assignments.empty?

            assignments.each do |assignment|
                if assignment.user
                    assignments_data.push(
                        assignment.attributes.merge({
                            assignable_name: assignment.user.full_name
                        })
                    )
                end
            end

            assignments_data
        end

        private

        # @return [void]
        # @descriptions If there is no deadline, the deadline is set based on priority. I case no deadline nor priority are set,
        #     the system sets a default deadline of 2 weeks from the creation day of the ticket
        # @example
        #     ticket = current_user.account.help.tickets.new(subject: "Ticket 1", category: "bug", user_creator: current_user)
        #     ticket.save! # The set_deadline will trigger here as a before_validation function
        #     puts ticket.deadline # This will print current_date + 2 weeks
        def set_deadline
            return if deadline

            if priority && priority.days_to_deadline
                update!(deadline: LC::Date.now + priority.days_to_deadline.days)
            else
                update!(deadline: LC::Date.now + 2.weeks)
            end
        end
        
        # @return [void]
        # @descriptions Sets a default ticket type for the ticket, if it is not set in the initial params
        # @example
        #     ticket = current_user.account.help.tickets.new(subject: "Ticket 1", category: "bug", user_creator: current_user)
        #     ticket.save! # The set_type will trigger here as a before_validation function
        #     puts ticket.type # This will print the first CloudHelp::Catalog::TicketType created
        def set_type
            return unless account 

            if self.type.blank?
                self.type = self.account.ticket_types.first
            end
        end

        # @return [void]
        # @descriptions Sets a sla for the ticket, if it is not set in the initial params
        # @example
        #     ticket = current_user.account.help.tickets.new(subject: "Ticket 1", category: "bug", user_creator: current_user)
        #     ticket.save! # The set_sla will trigger here as a before_validation function
        #     puts ticket.sla # This will print either the default sla or the one associated with the ticket type
        def set_sla
            return unless account 

            slas = account.slas
            
            selected_sla = slas.joins(:associations).where(
                "cloud_help_sla_associations.cloud_help_catalog_ticket_types_id = ?", type.id
            ).first

            selected_sla = slas.find_by(default: true) unless selected_sla
            
            self.sla = selected_sla
        end

        # @return [void]
        # @descriptions Sets a workspace for the ticket. If it is not set in the initial params
        # @example
        #     ticket = current_user.account.help.tickets.new(subject: "Ticket 1", category: "bug", user_creator: current_user)
        #     ticket.save! # The set_workspace method will trigger here as a before_validation function
        #     puts ticket.workspace # This will print either the default workspace or the one specified by the params
        def set_workspace
            return unless self.account
            return if self.workspace

            self.workspace = self.account.ticket_workspaces.find_by(default: true)
        end


        # @return [void]
        # @description After a *ticket* is updated, this method triggers. It checks for the changes
        #     made and based on them, adds entries to the timeline and notifies users. The possible changes are:
        #     - A change in workflow
        #     - A priority change
        #     - A type change
        #     - A category change
        #     - A deadline added
        # @example
        #     ticket = CloudHelp::Ticket.first
        #     ticket.update(cloud_help_catalog_ticket_priorities_id: 4)
        #     # after the update, this method is executed automatically
        def after_update_actions
            workflow_change = saved_changes["cloud_help_workflow_statuses_id"]
            if workflow_change
                action_register_workflow_change(workflow_change[0], workflow_change[1])
            end
            
            priority_change = saved_changes["cloud_help_catalog_ticket_priorities_id"]
            if priority_change
                action_register_priority_change(priority_change[0], priority_change[1])
            end
            
            type_change = saved_changes["cloud_help_catalog_ticket_types_id"]
            if type_change
                action_register_type_change(type_change[0], type_change[1])
            end
            
            category_change = saved_changes["cloud_help_catalog_ticket_categories_id"]
            if category_change
                action_register_category_change(category_change[0], category_change[1])
            end

            if type_change || category_change
                action_assign_new_workflow
            end

            deadline_change = saved_changes["deadline"]
            if deadline_change
                action_register_deadline_change
            end
        end

        # @return [void]
        # @description If this ticket changes *status*, 
        #     a new entry is recorded to the timeline and a notification is sent to
        #     the subscribers. Both the timeline entry and the notification change
        #     if the ticket changed to a *closed* status or not
        # @example
        #     ticket = CloudHelp::Ticket.first
        #     ticket.update({cloud_help_ticket_workflow_details_id: 4 })
        #     # the *after_update_actions* method will call this method after the update
        def action_register_workflow_change(old_status_id, new_status_id)
            old_workflow_status = Workflow::Status.find(old_status_id)
            new_workflow_status = Workflow::Status.find(new_status_id)

            timeline_action = Ticket::Timeline.actions[:status_changed]
            timeline_description = "#{new_workflow_status.name.humanize}"
            timelines.create( action: timeline_action, description: timeline_description )
        end

        # @return [void]
        # @description If the type of this *ticket* is changed, 
        #     a new entry is recorded to the timeline. Notifications are sent in 
        #     the *action_assign_new_workflow* method.
        # @example
        #     ticket = CloudHelp::Ticket.first
        #     ticket.update({ cloud_help_catalog_ticket_types_id: 1 })
        #     # the *after_update_actions* method will call this method after the update
        def action_register_type_change(old_type, new_type)
            self.set_sla
            self.save!
            new_type = Catalog::TicketType.find(new_type)
            
            # Adding type transfer to timeline
            timelines.create(
                action: Ticket::Timeline.actions[:type_transferred],
                description: "#{new_type.name}"
            )
        end

        # @return [void]
        # @description If the category of this *ticket* is changed, 
        #     a new entry is recorded to the timeline. Notifications are sent in 
        #     the *action_assign_new_workflow* method.
        # @example
        #     ticket = CloudHelp::Ticket.first
        #     ticket.update({cloud_help_catalog_ticket_categories: 1 })
        #     # the *after_update_actions* method will call this method after the update
        def action_register_category_change(old_category, new_category)
            new_category = Catalog::TicketCategory.find(new_category)
            
            # Adding category transfer to timeline
            timelines.create(
                action: Ticket::Timeline.actions[:category_transferred],
                description: "#{new_category.name}"
            )
        end

        # @return [void]
        # @description If the category or the tipe of this *ticket* are changed,
        #     a new workflow detail, associated to the *initial* *status*, is assigned.
        #     If this update fails, a rollback is ussued and a error message is added to
        #     this *ticket*'s *errors* attribute. If the update is successful, a notification is sent
        #     to all subscribers
        # @example
        #     ticket = CloudHelp::Ticket.first
        #     ticket.update({ cloud_help_catalog_ticket_categories: 1 })
        #     # the *after_update_actions* method will call this method after the update
        def action_assign_new_workflow
            set_workflow(true)
            if save
                return true
            else
                raise ActiveRecord::RecordInvalid, self
            end
        end

        # @return [void]
        # @description If this ticket's priority is changed, 
        #     a new entry is recorded to the timeline and a notification is sent to
        #     the subscribers. The messages change depending if the priority weight is
        #     increased or decreased
        # @example
        #     ticket = CloudHelp::Ticket.first
        #     ticket.update({ cloud_help_catalog_ticket_priorities_id: 4 })
        #     # the *after_update_actions* method will call this method after the update
        def action_register_priority_change(old_priority, new_priority)
            new_priority = Catalog::TicketPriority.find(new_priority)

            timelines.create(
                action: Ticket::Timeline.actions[:priority_changed],
                description: "#{new_priority.name} - #{new_priority.weight}"
            )
        end

        # @return [void]
        # @description If this ticket's deadline is changed, 
        #     a new entry is recorded to the timeline and a notification is sent to
        #     the subscribers. Also, an entry is recorded in the *CloudDriver* module, if it
        #     exists. If there is no user assigned, an error message is added to this
        #     *ticket*'s *errors* attribute, and an rollback is issued
        # @example
        #     ticket = CloudHelp::Ticket.first
        #     ticket.update({ deadline: Datetime.now })
        #     # the *after_update_actions* method will call this method after the update
        def action_register_deadline_change
            # Adding deadline to timeline
            timelines.create(
                action: Ticket::Timeline.actions[:deadline_established],
                description: "#{LC::Date.to_string(deadline)}"
            )
        end
    end
end
