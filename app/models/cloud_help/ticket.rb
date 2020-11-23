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
        belongs_to :category,   class_name: "CloudHelp::Catalog::TicketCategory",   foreign_key: "cloud_help_catalog_ticket_categories_id"
        belongs_to :priority,   class_name: "CloudHelp::Catalog::TicketPriority",   foreign_key: "cloud_help_catalog_ticket_priorities_id"
        belongs_to :source,     class_name: "CloudHelp::Catalog::TicketSource",     foreign_key: "cloud_help_catalog_ticket_sources_id"
        belongs_to :status,     class_name: "CloudHelp::Workflow::Status",          foreign_key: "cloud_help_workflow_statuses_id"

        has_many :discussions,  foreign_key: "cloud_help_tickets_id"
        has_many :actions,      foreign_key: "cloud_help_tickets_id"
        has_many :files,        foreign_key: "cloud_help_tickets_id"
        has_many :subscribers,  foreign_key: "cloud_help_tickets_id"
        has_many :timelines,    foreign_key: "cloud_help_tickets_id"
        has_many :activities,   foreign_key: "cloud_help_tickets_id"


        has_one :detail, inverse_of: :ticket, autosave: true, foreign_key: "cloud_help_tickets_id"
        has_many :assignments, foreign_key: "cloud_help_tickets_id"  

        accepts_nested_attributes_for :detail, update_only: true

        after_update :after_update_actions

=begin
@return [Boolean] Whether this ticket was successfully saved or not. If it was not saved,
    an error is added to the *ticket*'s *errors* attribute
@description saves a ticket based on the params allowed by *CloudHelp::TicketsController*. 
    If the ticket is new, creates an entry in the timeline. Also, depending on which 
    attributes where updated, notifications are sent and entries are added to the timeline
@example
    ticket_params = {
        detail_attributes: {
            cloud_help_catalog_ticket_priorities_id: 1,
            cloud_help_catalog_ticket_categories_id: 1,
            cloud_help_catalog_ticket_types_id: 1
        }
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
    puts ticket.detailed_info
    # will print something like: {
    #    id:6,
    #    created_at:"2020-01-12T17:31:25.005Z",
    #    detail_attributes:{
    #        email:"admin@lesli.cloud",
    #        subject:"subject",
    #        description:"description",
    #        tags:"tags",
    #        priority:"Medium",
    #        type:"Change Request",
    #        status:"created",
    #        cloud_help_catalog_ticket_priorities_id:2,
    #        cloud_help_catalog_ticket_types_id:2,
    #        cloud_help_ticket_workflows_id:4,
    #        cloud_help_catalog_ticket_categories_id:1,
    #        cloud_help_ticket_statuses_id:1,
    #        deadline:null,
    #        priority_weight:100,
    #        category:"Company System"
    #    },
    #    assignment_attributes:{
    #        assignment_type:"none"
    #    }
    #}
=end
        def show(current_user, query)
            data = Ticket.joins(
                "inner join cloud_help_catalog_ticket_priorities CHCTP on cloud_help_tickets.cloud_help_catalog_ticket_priorities_id = CHCTP.id"
            ).joins(
                "inner join cloud_help_catalog_ticket_types CHCTT on cloud_help_tickets.cloud_help_catalog_ticket_types_id = CHCTT.id"
            ).joins(
                "inner join cloud_help_catalog_ticket_categories CHCTC on cloud_help_tickets.cloud_help_catalog_ticket_categories_id = CHCTC.id"
            ).joins(
                "inner join cloud_help_workflow_statuses CHWS on cloud_help_tickets.cloud_help_workflow_statuses_id = CHWS.id"
            ).joins(
                "inner join cloud_help_workflows CHW on CHWS.cloud_help_workflows_id = CHW.id"
            ).joins(
                "left join cloud_help_ticket_assignments CHTA on cloud_help_tickets.id = CHTA.cloud_help_tickets_id"
            ).select(
                "cloud_help_tickets.id as id",                      "cloud_help_tickets.created_at as created_at",
                "CHCTP.name as priority",                           "CHCTT.name as type",
                "CHWS.name as status",                              "CHCTP.id as cloud_help_catalog_ticket_priorities_id",
                "CHCTT.id as cloud_help_catalog_ticket_types_id",   "CHCTC.id as cloud_help_catalog_ticket_categories_id",
                "CHWS.id as cloud_help_workflow_statuses_id",       "CHCTP.weight as priority_weight",
                "CHWS.status_type as status_type",                  "CHW.id as cloud_help_workflows_id",
                "CHWS.number as status_number"
            )
            .where("cloud_help_tickets.id = #{id}").first.attributes

            data[:category] = category.full_path
            data[:detail_attributes] = detail.attributes
            data[:assignment_attributes] = assignments_info
            data[:editable] = self.is_editable_by?(current_user)
            
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
    tickets_info = CloudHelp::Ticket.detailed_info(current_user.account)
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


                
                filters_query.push("(cloud_help_tickets.users_id = #{current_user.id} OR CHTA.users_id = #{current_user.id})") if filters["search_type"].eql? "own"
                filters_query.push("(CHWS.status_type != 'completed_unsuccessfully' AND CHWS.status_type != 'completed_successfully')") if filters["search_type"].eql? "active"
                filters_query.push("(CHWS.status_type = 'completed_unsuccessfully' OR CHWS.status_type = 'completed_successfully')") if filters["search_type"].eql? "inactive"
            end
            
            # We filter by a text string written by the user
            if filters["query"] && !filters["query"].empty?
                query_words = filters["query"].split(" ")
                query_words.each do |query_word|
                    query_word = query_word.strip.downcase

                    # first customer
                    filters_query.push("
                        (LOWER(CHTD.subject) SIMILAR TO '%#{query_word}%') OR
                        (LOWER(CHTD.description) SIMILAR TO '%#{query_word}%') OR
                        (LOWER(CHCTC.name) SIMILAR TO '%#{query_word}%') OR
                        (LOWER(CHCTT.name) SIMILAR TO '%#{query_word}%') OR
                        (LOWER(CHCTP.name) SIMILAR TO '%#{query_word}%')
                    ")
                end
            end

            # We filter by statuses
            if filters["statuses"] && !filters["statuses"].empty?
                statuses_query = filters["statuses"].map do |status|
                    "CHWS.id = '#{status["id"]}'"
                end
                filters_query.push("(#{statuses_query.join(' or ')})")
            end

            # Executing the query
            tickets = current_user.account.help.tickets.joins(
                "inner join cloud_help_ticket_details CHTD on cloud_help_tickets.id = CHTD.cloud_help_tickets_id"
            ).joins(
                "inner join cloud_help_catalog_ticket_priorities CHCTP on cloud_help_tickets.cloud_help_catalog_ticket_priorities_id = CHCTP.id"
            ).joins(
                "inner join cloud_help_catalog_ticket_types CHCTT on cloud_help_tickets.cloud_help_catalog_ticket_types_id = CHCTT.id"
            ).joins(
                "inner join cloud_help_catalog_ticket_categories CHCTC on cloud_help_tickets.cloud_help_catalog_ticket_categories_id = CHCTC.id"
            ).joins(
                "inner join cloud_help_workflow_statuses CHWS on cloud_help_tickets.cloud_help_workflow_statuses_id = CHWS.id"
            ).joins(
                "left join cloud_help_ticket_assignments CHTA on CHTA.cloud_help_tickets_id = cloud_help_tickets.id AND CHTA.users_id = #{current_user.id}"
            ).joins(
                "left join users UC on UC.id = cloud_help_tickets.users_id"
            ).joins(
                "left join user_details UCD on UCD.users_id = UC.id"
            ).select(
                "id",                                                   "CHCTP.name as priority",
                "CHCTT.name as type",                                   "CHWS.name as status_name",
                "CHCTC.name as category",                               "user_main_id",
                "subject",                                              "CHCTC.id as cloud_help_catalog_ticket_categories_id",
                "CHCTP.id as cloud_help_catalog_ticket_priorities_id",  "CHCTT.id as cloud_help_catalog_ticket_types_id",
                "created_at",                                           "CHCTP.weight as priority_weight",
                "UC.id as user_creator_id",                             "CONCAT(UCD.first_name, ' ', UCD.last_name) as user_creator",
                "deadline",                                             "users_id"
            )

            # We apply the previous filters in the main query
            unless filters_query.empty?
                tickets = tickets.where(filters_query.join(" AND "))
            end


            response = {}
            # total count
            response[:total_count] = tickets.length if filters["get_total_count"]

            # Adding pagination to tickets
            pagination = query[:pagination]
            tickets = tickets.page(
                pagination[:page]
            ).per(
                pagination[:perPage]
            ).order(
                "#{pagination[:orderColumn]} #{pagination[:order]} NULLS LAST"
            )

            # We format the response
            response[:tickets] = tickets.map do |ticket|
                ticket_attributes = ticket.attributes
                ticket_attributes["editable"] = ticket.is_editable_by?(current_user)
                ticket_attributes["deadline"] = LC::Date.to_string(ticket_attributes["deadline"])
                ticket_attributes["created_at"] = LC::Date.to_string_datetime(ticket_attributes["created_at"])
                ticket_attributes["assignment_type"] = Ticket::Assignment.assignment_types.key(ticket[:assignment_type])
                ticket_attributes["category"] = Catalog::TicketCategory.find(ticket[:cloud_help_catalog_ticket_categories_id]).full_path
                
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
            types = current_user.account.help.ticket_types.select(:id, :name)
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
                    "inner join cloud_help_workflow_associations CHWA on CHWA.cloud_help_workflows_id = cloud_help_workflows.id AND CHWA.deleted_at is null"
                ).where(
                    "CHWA.workflow_for = ?", "ticket"
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
        # @param [CloudHelp::Ticket] The ticket that was created
        # @description Creates an activity for this ticket indicating that someone viewed it
        # Example
        #   ticket = CloudHelp::Ticket.find(1)
        #   CloudHelp::Ticket.log_activity_show(User.find(1), ticket)
        def self.log_activity_show(current_user, ticket)
            ticket.activities.create(
                user_creator: current_user,
                category: "action_show"
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
        #   old_attributes  = ticket.attributes.merge({detail_attributes: ticket.detail.attributes})
        #   ticket.update(user_main: User.find(33))
        #   new_attributes = ticket.attributes.merge({detail_attributes: ticket.detail.attributes})
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
                    old_value = "CloudHelp::Catalog::#{field}".constantize.with_deleted.find(old_attributes["cloud_help_catalog_#{field.underscore.pluralize}_id"]).name
                    new_value = "CloudHelp::Catalog::#{field}".constantize.with_deleted.find(new_attributes["cloud_help_catalog_#{field.underscore.pluralize}_id"]).name
                    ticket.activities.create(
                        user_creator: current_user,
                        category: "action_update",
                        field_name: "cloud_help_catalog_#{field.underscore.pluralize}_id",
                        value_from: old_value,
                        value_to: new_value
                    )
                end
            end

            # Details are a special case but only because they are nested
            old_attributes = old_attributes["detail_attributes"] || {}
            new_attributes = new_attributes["detail_attributes"] || {}
            old_attributes.except!("id", "cloud_help_tickets_id", "created_at", "updated_at")

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
        # @param current_user [::User] The user that created the ticket
        # @param [CloudHelp::Ticket] The ticket that was created
        # @description Creates an activity for this ticket indicating that someone deleted it
        # Example
        #   ticket = CloudHelp::Ticket.find(1)
        #   CloudHelp::Ticket.log_activity_show(User.find(1), ticket)
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

        # Custom is_editab_by? implementation
        def is_editable_by?(current_user)
            return false unless current_user

            current_user_olp = User.joins(:role)
                .joins(:role_detail)
                .where("users.id = ?", current_user.id)
                .select("role_details.object_level_permission")
                .first.object_level_permission

            reference_olp = 0

            if user_creator
                reference_olp = user_creator.role.detail.object_level_permission
            elsif user_main
                reference_olp = user_main.role.detail.object_level_permission
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
    ticket.update(detail_attributes: {cloud_help_catalog_ticket_priorities_id: 4})
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

            deadline_change = detail.saved_changes["deadline"]
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
    ticket.update({ detail_attributes: { cloud_help_ticket_workflow_details_id: 4 } })
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
    ticket.update({ detail_attributes: { cloud_help_catalog_ticket_types_id: 1 } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_type_change(old_type, new_type)
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
    ticket.update({ detail_attributes: { cloud_help_catalog_ticket_categories: 1 } })
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
    ticket.update({ detail_attributes: { cloud_help_catalog_ticket_categories: 1 } })
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
    ticket.update({ detail_attributes: { cloud_help_catalog_ticket_priorities_id: 4 } })
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
    ticket.update({ detail_attributes: { deadline: Datetime.now } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_deadline_change
            # Adding deadline to timeline
            timelines.create(
                action: Ticket::Timeline.actions[:deadline_established],
                description: "#{LC::Date.to_string(detail.deadline)}"
            )
        end 
    end
end
