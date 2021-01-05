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
    class Sla  < CloudObject::Base
        belongs_to  :account,       class_name: "CloudHelp::Account",           foreign_key: "cloud_help_accounts_id"
        has_many    :associations,  class_name: "CloudHelp::Sla::Association",  foreign_key: "cloud_help_slas_id"
        belongs_to  :user_creator,  class_name: "::User",                       foreign_key: "users_id"
        belongs_to  :user_main,     class_name: "::User",                       foreign_key: "user_main_id", optional: true
        belongs_to  :status,        class_name: "CloudHelp::Workflow::Status",  foreign_key: "cloud_help_workflow_statuses_id"

        has_many :discussions,      foreign_key: "cloud_help_slas_id"
        has_many :actions,          foreign_key: "cloud_help_slas_id"
        has_many :files,            foreign_key: "cloud_help_slas_id"
        has_many :subscribers,      foreign_key: "cloud_help_slas_id"
        has_many :timelines,        foreign_key: "cloud_help_slas_id"
        has_many :activities,       foreign_key: "cloud_help_slas_id"

        has_many :assignments,      foreign_key: "cloud_help_slas_id"

        after_update :verify_default_sla
        after_create :verify_default_sla

=begin
@return [Hash] Detailed information about the sla. Including, *priority*,
    *full* *category* *path*, *type*, *creation* *user*, *assignment* *type*
    and *workflow* *status*
@description Creates a query that selects all sla information from several tables
    and returns it in a hash
@example
    sla = CloudHelp::Sla.find(43)
    puts sla.show
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
    #    cloud_help_catalog_sla_priorities_id:2,
    #    cloud_help_catalog_sla_types_id:2,
    #    cloud_help_workflow_statuses_id:4,
    #    cloud_help_catalog_sla_categories_id:1,
    #    cloud_help_sla_statuses_id:1,
    #    priority_weight:100,
    #    category:"Company System",
    #    assignment_attributes:{
    #        assignment_type:"none"
    #    }
    #}
=end
        def show(current_user, query)
            data = current_user.account.help.slas.joins(
                "inner join cloud_help_workflow_statuses CHWS on cloud_help_slas.cloud_help_workflow_statuses_id = CHWS.id"
            ).joins(
                "inner join cloud_help_workflows CHW on CHWS.cloud_help_workflows_id = CHW.id"
            ).select(
                "cloud_help_slas.id",                           "cloud_help_slas.created_at",
                "cloud_help_slas.name",                         "cloud_help_slas.body",
                "cloud_help_slas.expected_response_time",       "cloud_help_slas.expected_resolution_time",
                "cloud_help_slas.provider_repercussions",       "cloud_help_slas.exceptions",
                "cloud_help_slas.default",                      "CHWS.id as cloud_help_workflow_statuses_id",
                "CHW.id as cloud_help_workflows_id",            "CHWS.name as status",
                "CHWS.status_type as status_type"
            )
            .where("cloud_help_slas.id = #{id}").first.attributes

            data[:editable] = self.is_editable_by?(current_user)
            
            return data
        end

=begin
@param help_account [Account] The account associated to *current_user*
@return [Hash] Detailed information about all the slas. Including, *priority*,
    *full* *category* *path*, *type*, *creation* *user*, *assignment* *type*
    and *workflow* *status*
@description Creates a query that selects all the slas information from several tables
    and returns it in a hash
@example
    slas_info = CloudHelp::Sla.index(current_user.account)
    puts slas_info.to_json
    # will print something like: [
    #    {
    #        "id":1,                     "created_at":"2020-01-08T16:23:10.976Z",
    #        "priority":"Low",           "type":"Issue",
    #        "status":"created",          "category":"Company System",
    #        "assignment_type":null,    "subject":"Testing Sla"
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

            # We filter by search_type, available search_types are 'active' and 'inactive'
            if filters["search_type"]
                filters_query.push("(CHWS.status_type NOT IN ('completed_unsuccessfully', 'completed_successfully'))") if filters["search_type"].eql? "active"
                filters_query.push("(CHWS.status_type IN ('completed_unsuccessfully', 'completed_successfully'))") if filters["search_type"].eql? "inactive"
            end
            
            # We filter by a text string written by the user
            if filters["query"] && !filters["query"].empty?
                query_words = filters["query"].split(" ")
                query_words.each do |query_word|
                    query_word = query_word.strip.downcase

                    # Filtering by SLA name
                    filters_query.push("
                        (LOWER(name) SIMILAR TO '%#{query_word}%')
                    ")
                end
            end

            # We filter by statuses
            if filters["statuses"] && !filters["statuses"].empty?
                statuses_query = filters["statuses"].map do |status|
                    "CHWS.id = '#{status["id"]}'"
                end
                filters_query.push("(#{statuses_query.join(' OR ')})")
            end

            # Executing the query
            slas = current_user.account.help.slas.joins(
                "inner join cloud_help_workflow_statuses CHWS on cloud_help_slas.cloud_help_workflow_statuses_id = CHWS.id"
            ).select(
                "cloud_help_slas.id",                           "cloud_help_slas.created_at",
                "cloud_help_slas.name",                         "cloud_help_slas.body",
                "cloud_help_slas.expected_response_time",       "cloud_help_slas.expected_resolution_time",
                "cloud_help_slas.provider_repercussions",       "cloud_help_slas.exceptions",
                "cloud_help_slas.default",                      "CHWS.id as cloud_help_workflow_statuses_id",
                "CHWS.name as status",                          "cloud_help_slas.users_id",
                "cloud_help_slas.user_main_id"
            )

            # We apply the previous filters in the main query
            unless filters_query.empty?
                slas = slas.where(filters_query.join(" AND "))
            end


            response = {}
            # total count
            response[:total_count] = slas.length if filters["get_total_count"]

            # Adding pagination to slas
            pagination = query[:pagination]
            slas = slas.page(
                pagination[:page]
            ).per(
                pagination[:perPage]
            ).order(
                "#{pagination[:orderColumn]} #{pagination[:order]} NULLS LAST"
            )

            # We format the response
            response[:slas] = slas.map do |sla|
                sla_attributes = sla.attributes
                sla_attributes["editable"] = sla.is_editable_by?(current_user)
                sla_attributes["created_at"] = LC::Date.to_string_datetime(sla_attributes["created_at"])
                
                sla_attributes
            end
            
            response
        end

        def self.options(current_user, query)
        
            sla_options = { }
        
            if query[:filters][:include] && query[:filters][:include] == "statuses"
                statuses = Workflow::Status.joins(
                    :workflow
                ).joins(
                    "inner join cloud_help_workflow_associations CHWA on CHWA.cloud_help_workflows_id = cloud_help_workflows.id AND CHWA.deleted_at is null"
                ).where(
                    "CHWA.workflow_for = ?", "sla"
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
                
                sla_options["statuses"] = statuses
            end
        
            sla_options
        end

        def closed?
            return status.completed_successfully? || status.completed_unsuccessfully?
        end

        #######################################################################################
        ##############################  Activities Log Methods   ##############################
        #######################################################################################

        # @return [void]
        # @param current_user [::User] The user that created the sla
        # @param [CloudHelp::Sla] The sla that was created
        # @description Creates an activity for this sla indicating who created it. And 
        #   also creates an activity with the initial status of the sla
        # Example
        #   params = {...}
        #   sla = CloudHelp::Sla.create(params)
        #   CloudHelp::Sla.log_activity_create(User.find(1), sla)
        def self.log_activity_create(current_user, sla)
            sla.activities.create(
                user_creator: current_user,
                category: "action_create"
            )
            
            sla.activities.create(
                user_creator: current_user,
                category: "action_status",
                description: sla.status.name,
                field_name: "cloud_help_workflow_statuses_id",
                value_to: sla.status.name
            )
        end

        # @return [void]
        # @param current_user [::User] The user that created the sla
        # @param [CloudHelp::Sla] The sla that was created
        # @description Creates an activity for this sla indicating that someone viewed it
        # Example
        #   sla = CloudHelp::Sla.find(1)
        #   CloudHelp::Sla.log_activity_show(User.find(1), sla)
        def self.log_activity_show(current_user, sla)
            sla.activities.create(
                user_creator: current_user,
                category: "action_show"
            )
        end

        # @return [void]
        # @param current_user [::User] The user that created the sla
        # @param sla [CloudHelp::Sla] The sla that was created
        # @param old_attributes[Hash] The data of the record before update
        # @param new_attributes[Hash] The data of the record after update
        # @description Creates an activity for this sla if someone changed any of this values
        # Example
        #   sla = CloudHelp::Sla.find(1)
        #   old_attributes  = sla.attributes
        #   sla.update(user_main: User.find(33))
        #   new_attributes = sla.attributes
        #   CloudHelp::Sla.log_activity_update(User.find(1), sla, old_attributes, new_attributes)
        def self.log_activity_update(current_user, sla, old_attributes, new_attributes)
            # Main employee is a special case because it's a foreign key
            if old_attributes["user_main_id"] != new_attributes["user_main_id"]
                sla.activities.create(
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
                sla.activities.create(
                    user_creator: current_user,
                    description: new_status,
                    category: "action_status",
                    field_name: "cloud_help_workflow_statuses_id",
                    value_from: old_status,
                    value_to: new_status
                )
            end

            # We remove values that are not tracked in the activities
            old_attributes.except!("id", "created_at", "updated_at")
            old_attributes.each do |key, value|
                if value != new_attributes[key]
                    value_from = value
                    value_to = new_attributes[key]
                    value_from = LC::Date.to_string_datetime(value_from) if value_from.is_a?(Time) || value_from.is_a?(Date)
                    value_to = LC::Date.to_string_datetime(value_to) if value_to.is_a?(Time) || value_to.is_a?(Date)

                    sla.activities.create(
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
        # @param current_user [::User] The user that created the sla
        # @param [CloudHelp::Sla] The sla that was created
        # @description Creates an activity for this sla indicating that someone deleted it
        # Example
        #   sla = CloudHelp::Sla.find(1)
        #   CloudHelp::Sla.log_activity_show(User.find(1), sla)
        def self.log_activity_destroy(current_user, sla)
            sla.activities.create(
                user_creator: current_user,
                category: "action_destroy"
            )
        end

        def destroy
            if default
                errors.add(:base, :cannot_delete_default_sla)
                return false
            end

            super
        end

        private

        def verify_default_sla
            if default
                Sla.where.not(id: id).where(account: account).update_all(default: false)
            end
        end

    end
end
