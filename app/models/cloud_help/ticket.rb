module CloudHelp
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
    class Ticket  < CloudObject::Base
        include ActiveModel::Dirty

        belongs_to :account,    class_name: "CloudHelp::Account",                   foreign_key: "cloud_help_accounts_id"
        belongs_to :user_creator, class_name: "::User",                             foreign_key: "users_id"
        belongs_to :user_main,  class_name: "::User",                               foreign_key: "user_main_id", optional: true
        belongs_to :type,       class_name: "CloudHelp::Catalog::TicketType",       foreign_key: "cloud_help_catalog_ticket_types_id"
        belongs_to :category,   class_name: "CloudHelp::Catalog::TicketCategory",   foreign_key: "cloud_help_catalog_ticket_categories_id", optional: true
        belongs_to :priority,   class_name: "CloudHelp::Catalog::TicketPriority",   foreign_key: "cloud_help_catalog_ticket_priorities_id", optional: true
        belongs_to :source,     class_name: "CloudHelp::Catalog::TicketSource",     foreign_key: "cloud_help_catalog_ticket_sources_id"
        belongs_to :status,     class_name: "CloudHelp::Workflow::Status",          foreign_key: "cloud_help_workflow_statuses_id"
        belongs_to :sla,        class_name: "CloudHelp::Sla",                       foreign_key: "cloud_help_slas_id"

        has_many :discussions,  foreign_key: "cloud_help_tickets_id"
        has_many :actions,      foreign_key: "cloud_help_tickets_id"
        has_many :files,        foreign_key: "cloud_help_tickets_id"
        has_many :subscribers,  foreign_key: "cloud_help_tickets_id"
        has_many :timelines,    foreign_key: "cloud_help_tickets_id"
        has_many :activities,   foreign_key: "cloud_help_tickets_id"

        has_many :assignments, foreign_key: "cloud_help_tickets_id"

        after_update :after_update_actions

=begin
@return [Boolean] Whether this ticket was successfully saved or not. If it was not saved,
    an error is added to the *ticket*'s *errors* attribute
@description saves a ticket based on the params allowed by *CloudHelp::TicketsController*. 
    If the ticket is new, creates an entry in the timeline. Also, depending on which 
    attributes where updated, notifications are sent and entries are added to the timeline
@example
    ticket_params = {
        cloud_help_catalog_ticket_priorities_id: 1,
        cloud_help_catalog_ticket_categories_id: 1,
        cloud_help_catalog_ticket_types_id: 1
    }
    ticket = CloudHelp::Ticket.new(ticket_params)
    if ticket.save
        responseWithSuccessful
    else
        responseWithError(ticket.errors.full_messages.to_sentence)
    end
=end
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

=begin
@return [Hash] Detailed information about the ticket. Including, *priority*,
    *full* *category* *path*, *type*, *creation* *user*, *assignment* *type*
    and *workflow* *status*
@description Creates a query that selects all ticket information from several tables
    and returns it in a hash
@example
    ticket = CloudHelp::Ticket.find(43)
    puts ticket.show
    # will print something like: {
    #    id:6,
    #    created_at:"2020-01-12T17:31:25.005Z",
    #    email:"admin@lesli.cloud",
    #    subject:"subject",
    #    description:"description",
    #    tags:"tags",
    #    priority:"Medium",
    #    type:"Change Request",
    #    status:"created",
    #    cloud_help_catalog_ticket_priorities_id:2,
    #    cloud_help_catalog_ticket_types_id:2,
    #    cloud_help_workflow_statuses_id:4,
    #    cloud_help_catalog_ticket_categories_id:1,
    #    cloud_help_ticket_statuses_id:1,
    #    deadline:null,
    #    priority_weight:100,
    #    category:"Company System",
    #    assignment_attributes:{
    #        assignment_type:"none"
    #    }
    #}
=end
        def show(current_user, query)
            data = Ticket.joins(
                "left join cloud_help_catalog_ticket_priorities chctp on cloud_help_tickets.cloud_help_catalog_ticket_priorities_id = chctp.id"
            ).joins(
                "inner join cloud_help_catalog_ticket_types chctt on cloud_help_tickets.cloud_help_catalog_ticket_types_id = chctt.id"
            ).joins(
                "left join cloud_help_catalog_ticket_categories chctc on cloud_help_tickets.cloud_help_catalog_ticket_categories_id = chctc.id"
            ).joins(
                "inner join cloud_help_workflow_statuses chws on cloud_help_tickets.cloud_help_workflow_statuses_id = chws.id"
            ).joins(
                "inner join cloud_help_workflows chw on chws.cloud_help_workflows_id = chw.id"
            ).joins(
                "left join cloud_help_ticket_assignments chta on cloud_help_tickets.id = chta.cloud_help_tickets_id and chta.deleted_at is null"
            ).joins(
                "inner join users u on cloud_help_tickets.users_id = u.id"
            ).joins(
                "inner join user_details ud on u.id = ud.users_id"
            ).select(
                "cloud_help_tickets.id as id",                      "cloud_help_tickets.created_at as created_at",
                "chctp.name as priority",                           "chctt.name as type",
                "chws.name as status",                              "chctp.id as cloud_help_catalog_ticket_priorities_id",
                "chctt.id as cloud_help_catalog_ticket_types_id",   "chctc.id as cloud_help_catalog_ticket_categories_id",
                "chws.id as cloud_help_workflow_statuses_id",       "chctp.weight as priority_weight",
                "chws.status_type as status_type",                  "chw.id as cloud_help_workflows_id",
                "chws.number as status_number",                     "subject",
                "description",                                      "deadline",
                "tags",                                             "hours_worked",
                " coalesce(nullif(concat(ud.first_name, ' ', ud.last_name), ''), u.email) as user_creator_name"
            )
            .where("cloud_help_tickets.id = #{id}").first.attributes

            data[:category] = category.full_path if category
            data[:assignment_attributes] = assignments_info
            data[:editable] = self.is_editable_by?(current_user)
            data[:sla] = self.sla.show(current_user, query)
            
            return data
        end

=begin
@param help_account [Account] The account associated to *current_user*
@return [Hash] Detailed information about all the tickets. Including, *priority*,
    *full* *category* *path*, *type*, *creation* *user*, *assignment* *type*
    and *workflow* *status*
@description Creates a query that selects all the tickets information from several tables
    and returns it in a hash
@example
    tickets_info = CloudHelp::Ticket.index(current_user.account)
    puts tickets_info.to_json
    # will print something like: [
    #    {
    #        "id":1,                     "created_at":"2020-01-08T16:23:10.976Z",
    #        "priority":"Low",           "type":"Issue",
    #        "status":"created",          "category":"Company System",
    #        "assignment_type":null,    "subject":"Testing Ticket"
    #    },{
    #        "id":2,                     "created_at":"2020-01-08T16:43:30.470Z",
    #        "priority":"Low",           "type":"Issue",
    #        "status":"closed",           "category":"Company System",
    #        "assignment_type":"user",  "subject":"Testin"
    #    },{
    #        "id":3,                     "created_at":"2020-01-09T18:08:27.622Z",
    #        "priority":"Low",           "type":"Change Request",
    #        "status":"In Progress",      "category":"Company System, Books Module",
    #        "assignment_type":null,    "subject":"Testing"
    #    }
    #]
=end
        def self.index(current_user, query)
            # Parsing filters
            filters = query[:filters]
            filters_query = []

            # We filter by search_type, available search_types are 'own' and 'active'
            if filters["search_type"]
                filters_query.push("(chws.status_type != 'completed_unsuccessfully' AND chws.status_type != 'completed_successfully')") if filters["search_type"].eql? "active"
                filters_query.push("(chws.status_type = 'completed_unsuccessfully' OR chws.status_type = 'completed_successfully')") if filters["search_type"].eql? "inactive"
            end

            # We filter by user_type, which can be 'own' or null
            if filters["user_type"].eql? "own"
                filters_query.push("(cloud_help_tickets.users_id = #{current_user.id} OR chta.users_id = #{current_user.id})")
            end
            
            # We filter by a text string written by the user
            if filters["query"] && !filters["query"].empty?
                query_words = filters["query"].split(" ")
                query_words.each do |query_word|
                    query_word = query_word.strip.downcase

                    # first customer
                    filters_query.push("(
                        (LOWER(subject) SIMILAR TO '%#{query_word}%') OR
                        (LOWER(description) SIMILAR TO '%#{query_word}%') OR
                        (LOWER(chctc.name) SIMILAR TO '%#{query_word}%') OR
                        (LOWER(chctt.name) SIMILAR TO '%#{query_word}%') OR
                        (LOWER(chctp.name) SIMILAR TO '%#{query_word}%') OR
                        (LOWER(tags) SIMILAR TO '%#{query_word}%')
                    )")
                end
            end

            # We filter by statuses
            if filters["statuses"] && !filters["statuses"].empty?
                statuses_query = filters["statuses"].map do |status|
                    "chws.id = '#{status["id"]}'"
                end
                filters_query.push("(#{statuses_query.join(' or ')})")
            end

            # Executing the query
            tickets = current_user.account.help.tickets.joins(
                "left join cloud_help_catalog_ticket_priorities chctp on cloud_help_tickets.cloud_help_catalog_ticket_priorities_id = chctp.id"
            ).joins(
                "inner join cloud_help_catalog_ticket_types chctt on cloud_help_tickets.cloud_help_catalog_ticket_types_id = chctt.id"
            ).joins(
                "left join cloud_help_catalog_ticket_categories chctc on cloud_help_tickets.cloud_help_catalog_ticket_categories_id = chctc.id"
            ).joins(
                "inner join cloud_help_workflow_statuses chws on cloud_help_tickets.cloud_help_workflow_statuses_id = chws.id"
            ).joins(
                "left join cloud_help_ticket_assignments chta on chta.cloud_help_tickets_id = cloud_help_tickets.id AND chta.users_id = #{current_user.id}"
            ).joins(
                "left join users UC on UC.id = cloud_help_tickets.users_id"
            ).joins(
                "left join user_details UCD on UCD.users_id = UC.id"
            ).select(
                "id",                                                   "chctp.name as priority",
                "chctt.name as type",                                   "chws.name as status_name",
                "chctc.name as category",                               "user_main_id",
                "subject",                                              "chctc.id as cloud_help_catalog_ticket_categories_id",
                "chctp.id as cloud_help_catalog_ticket_priorities_id",  "chctt.id as cloud_help_catalog_ticket_types_id",
                "created_at",                                           "chctp.weight as priority_weight",
                "UC.id as user_creator_id",                             "CONCAT(UCD.first_name, ' ', UCD.last_name) as user_creator",
                "deadline",                                             "users_id",
                "cloud_help_tickets.cloud_help_workflow_statuses_id"
            )

            # We apply the previous filters in the main query
            unless filters_query.empty?
                tickets = tickets.where(filters_query.join(" AND "))
            end


            response = {}
            # total count
            response[:total_count] = tickets.length

            # Adding pagination to tickets
            pagination = query[:pagination]
            tickets = tickets.page(
                pagination[:page]
            ).per(
                pagination[:perPage]
            ).order(
                "#{pagination[:orderBy]} #{pagination[:order]} NULLS LAST"
            )

            # We format the response
            response[:tickets] = tickets.map do |ticket|
                ticket_attributes = ticket.attributes
                ticket_attributes["editable"] = ticket.is_editable_by?(current_user)
                ticket_attributes["deadline"] = LC::Date.to_string(ticket_attributes["deadline"])
                ticket_attributes["created_at"] = LC::Date.to_string_datetime(ticket_attributes["created_at"])
                ticket_attributes["assignment_type"] = Ticket::Assignment.assignment_types.key(ticket[:assignment_type])

                if ticket[:cloud_help_catalog_ticket_categories_id]
                    ticket_attributes["category"] = Catalog::TicketCategory.with_deleted.find(ticket[:cloud_help_catalog_ticket_categories_id]).full_path
                end
                
                if ticket.assignments.length > 0
                    users = []
                    ticket.assignments.order(id: :asc).each do |assigment|
                        users.push(assigment.user.full_name)
                    end
                    ticket_attributes["assignables"] = users
                end
                ticket_attributes
            end
            
            response
        end

        def self.options(current_user, query)
            types = current_user.account.help.ticket_types.select(:id, :name).order(:name)
            categories = Catalog::TicketCategory.tree(current_user.account)[:ticket_categories]
            priorities = current_user.account.help.ticket_priorities.order(weight: :asc).select(:id, :name, :weight)

            ticket_options = {
                types: types,
                categories: categories,
                priorities: priorities
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
            today = LC::Date.now
            filter_year = query[:filters][:year] || today.strftime("%Y")
            filter_month = query[:filters][:month] || today.strftime("%m")
            filter_day = query[:filters][:day]

            tickets = current_user.account.help.tickets
            .select(:id, :subject, :description, :deadline)
            .where("cloud_help_tickets.deadline is not null")
            .where("extract('year' from cloud_help_tickets.deadline) = ?", filter_year)
            .where("extract('month' from cloud_help_tickets.deadline) = ?", filter_month)

            tickets = tickets.where("extract('day' from cloud_help_tickets.deadline) = ?", filter_day) if filter_day

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
                old_status = CloudHelp::Workflow::Status.with_deleted.find(old_attributes["cloud_help_workflow_statuses_id"]).name
                new_status = CloudHelp::Workflow::Status.with_deleted.find(new_attributes["cloud_help_workflow_statuses_id"]).name
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
                old_sla = CloudHelp::Sla.with_deleted.find(old_attributes["cloud_help_slas_id"]).name
                new_sla = CloudHelp::Sla.with_deleted.find(new_attributes["cloud_help_slas_id"]).name
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
        def is_editable_by?(current_user)
            return false unless current_user

            return false if (status.completed_successfully? || status.completed_unsuccessfully? )

            current_user_olp = current_user.roles.order(object_level_permission: :desc).first.object_level_permission

            reference_olp = 0

            if user_creator
                reference_olp = user_creator.roles.order(object_level_permission: :desc).first.object_level_permission
            elsif user_main
                reference_olp = user_main.roles.order(object_level_permission: :desc).first.object_level_permission
            end

            # Admin, owner or similar roles can modify a ticket
            if current_user_olp >= object_level_permission_threshold && current_user_olp >= reference_olp
                return true
            end

            # Any assigned user can also modify this ticket
            if assignments.find_by(users_id: current_user.id)
                return true
            end

            return false
        end

        def set_sla
            slas = Sla.where(account: account)
            
            selected_sla = slas.joins(:associations).where(
                "cloud_help_sla_associations.cloud_help_catalog_ticket_types_id = ?", type.id
            ).first

            selected_sla = slas.find_by(default: true) unless selected_sla
            
            self.sla = selected_sla
        end

        private

=begin
@return [Hash] Assignment information about this ticket
@description Retrievies and returns assignment information about this ticket.
    If there is no assigment, returns a hash containing a "none" in the
    *assignment_type* attribute
@todo Implement support for *team* assigmation type
@example 
    puts self.assignments_info
    #will print something similar to {
    #    assignable_name: "john.doe@email.com",
    #    assignment_type: "user"
    #}
=end
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

=begin
@return [void]
@description After a *ticket* is updated, this method triggers. It checks for the changes
    made and based on them, adds entries to the timeline and notifies users. The possible changes are:
    - A change in workflow
    - A priority change
    - A type change
    - A category change
    - A deadline added
@example
    ticket = CloudHelp::Ticket.first
    ticket.update(cloud_help_catalog_ticket_priorities_id: 4)
    # after the update, this method is executed automatically
=end
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

=begin
@return [void]
@description If this ticket changes *status*, 
    a new entry is recorded to the timeline and a notification is sent to
    the subscribers. Both the timeline entry and the notification change
    if the ticket changed to a *closed* status or not
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({cloud_help_ticket_workflow_details_id: 4 })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_workflow_change(old_status_id, new_status_id)
            old_workflow_status = Workflow::Status.find(old_status_id)
            new_workflow_status = Workflow::Status.find(new_status_id)

            timeline_action = Ticket::Timeline.actions[:status_changed]
            timeline_description = "#{new_workflow_status.name.humanize}"
            timelines.create( action: timeline_action, description: timeline_description )
        end

=begin
@return [void]
@description If the type of this *ticket* is changed, 
    a new entry is recorded to the timeline. Notifications are sent in 
    the *action_assign_new_workflow* method.
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({ cloud_help_catalog_ticket_types_id: 1 })
    # the *after_update_actions* method will call this method after the update
=end
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

=begin
@return [void]
@description If the category of this *ticket* is changed, 
    a new entry is recorded to the timeline. Notifications are sent in 
    the *action_assign_new_workflow* method.
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({cloud_help_catalog_ticket_categories: 1 })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_category_change(old_category, new_category)
            new_category = Catalog::TicketCategory.find(new_category)
            
            # Adding category transfer to timeline
            timelines.create(
                action: Ticket::Timeline.actions[:category_transferred],
                description: "#{new_category.name}"
            )
        end

=begin
@return [void]
@description If the category or the tipe of this *ticket* are changed,
    a new workflow detail, associated to the *initial* *status*, is assigned.
    If this update fails, a rollback is ussued and a error message is added to
    this *ticket*'s *errors* attribute. If the update is successful, a notification is sent
    to all subscribers
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({ cloud_help_catalog_ticket_categories: 1 })
    # the *after_update_actions* method will call this method after the update
=end
        def action_assign_new_workflow
            set_workflow(true)
            if save
                return true
            else
                raise ActiveRecord::RecordInvalid, self
            end
        end

=begin
@return [void]
@description If this ticket's priority is changed, 
    a new entry is recorded to the timeline and a notification is sent to
    the subscribers. The messages change depending if the priority weight is
    increased or decreased
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({ cloud_help_catalog_ticket_priorities_id: 4 })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_priority_change(old_priority, new_priority)
            new_priority = Catalog::TicketPriority.find(new_priority)

            timelines.create(
                action: Ticket::Timeline.actions[:priority_changed],
                description: "#{new_priority.name} - #{new_priority.weight}"
            )
        end

=begin
@return [void]
@description If this ticket's deadline is changed, 
    a new entry is recorded to the timeline and a notification is sent to
    the subscribers. Also, an entry is recorded in the *CloudDriver* module, if it
    exists. If there is no user assigned, an error message is added to this
    *ticket*'s *errors* attribute, and an rollback is issued
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({ deadline: Datetime.now })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_deadline_change
            # Adding deadline to timeline
            timelines.create(
                action: Ticket::Timeline.actions[:deadline_established],
                description: "#{LC::Date.to_string(deadline)}"
            )
        end
    end
end
