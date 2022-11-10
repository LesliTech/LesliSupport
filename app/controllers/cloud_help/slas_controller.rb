require_dependency "cloud_help/application_controller"

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
    class SlasController < ApplicationLesliController

        before_action :set_sla, only: [:update, :destroy, :images]

        def privileges
            {
                index: [],
                show: [
                    "CloudHelp::Sla::Discussions#index",
                    "CloudHelp::Sla::Files#index",
                    "CloudHelp::Sla::Files#options",
                    "CloudHelp::Sla::Activities#index"
                ],
                new: [],
                destroy: []
            }
        end

=begin
@return [HTML|JSON] HTML view for listing all slas or a Json that contains a list 
    of all slas associated to this *account*
@description Retrieves and returns all slas associated to a *CloudHelp::Account*. 
    The account is obtained directly from *current_user*. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/help/slas`);
=end
        def index
            respond_to do |format|
                format.html { }
                format.json do
                    slas = Sla.index(current_user, @query)
                    respond_with_successful(slas) 
                end
            end
        end

=begin
@return [HTML|Json] HTML view showing the requested sla or a Json that contains the
    information of the sla. If there is an error, an explanation message is sent
@description Retrieves and returns the requested sla. The id of the 
    sla is within the *params* attribute of the controller. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let sla_id = 1;
    this.http.get(`127.0.0.1/help/slas/${sla_state_id}`);
=end
        def show
            respond_to do |format|
                format.html { }
                format.json do
                    set_sla
                    respond_with_successful(@sla.show(current_user, @query))
                end
            end
        end

=begin
@return [HTML] HTML view for creating a new sla
@description returns an HTML view with a form so users can create a new sla
@example
    # Executing this controller's action from javascript's frontend
    this.url.go('/help/slas/new')
=end
        def new
        end

=begin
@return [HTML] HTML view for editing the sla
@description returns an HTML view with a form so users edit an existing sla
@example
    # Executing this controller's action from javascript's frontend
    let sla_id = 3;
    this.url.go(`/help/sla_states/${sla_id}/edit`)
=end
        def edit
        end

=begin
@controller_action_param :detail_attributes [Hash] The fields of the detail 
    record associated to this sla
@controller_action_param :detail_attributes.id: [Integer] The id of the detail of
    of this sla. Since each sla has only one detail, this attribute is optiona
@controller_action_param :detail_attributes.subject [String] The subject of the sla
@controller_action_param :detail_attributes.description [String] A description of the issue.
    Can be an HTML string
@controller_action_param :tags [String], A small list of words, separated by commas
@controller_action_param :deadline [Datetime] The date set as this sla's deadline
@controller_action_param :cloud_help_catalog_sla_types_id [Integer] The id of the type
    associated to this sla
@controller_action_param :cloud_help_catalog_sla_priorities_id [Integer] The id of the priority
    associated to this sla
@controller_action_param :cloud_help_catalog_sla_categories_id [Integer] The id of the category
    associated to this sla
@controller_action_param :cloud_help_sla_workflow_details_id [Integer] The id of the
    workflow_detail associated to this sla. The workflow detail must be a detail of the
    workflow associated to this sla's type and category
@return [Json] Json that contains wheter the creation of the sla was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new sla associated to the *current_user*'s *account*. After creating
    a sla, *current_user* is *subscribed* to all of this sla's events, and a notification
    is sent via web about the new sla's creation
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        sla:{
            detail_attributes:{
                cloud_help_catalog_sla_types_id:2,
                cloud_help_catalog_sla_categories_id:1,
                cloud_help_catalog_sla_priorities_id:2,
                subject:I would like a button to print my record,
                description:`
                    <div>In the <em>show screen</em>, 
                    I would like you to add a button to print the record 
                    I'm creating, istead of having to navigate to the 
                    <strong>options menu</strong>. It would save me some time</div>
                `
            }
        }
    }
    this.http.post('127.0.0.1/help/slas', data);
=end
        def create
            sla = Sla.new(sla_params)
            sla.account = current_user.account.help
            sla.user_creator = current_user
            sla.set_workflow

            if sla.save
                Sla.log_activity_create(current_user, sla)

                respond_with_successful(sla)
            else
                responseWithError(sla.errors.full_messages.to_sentence)
            end
        end

=begin
@controller_action_param :detail_attributes [Hash] The fields of the detail 
    record associated to this sla
@controller_action_param :detail_attributes.id: [Integer] The id of the detail of
    of this sla. Since each sla has only one detail, this attribute is optiona
@controller_action_param :detail_attributes.subject [String] The subject of the sla
@controller_action_param :detail_attributes.description [String] A description of the issue.
    Can be an HTML string
@controller_action_param :tags [String], A small list of words, separated by commas
@controller_action_param :deadline [Datetime] The date set as this sla's deadline
@controller_action_param :cloud_help_catalog_sla_types_id [Integer] The id of the type
    associated to this sla
@controller_action_param :cloud_help_catalog_sla_priorities_id [Integer] The id of the priority
    associated to this sla
@controller_action_param :cloud_help_catalog_sla_categories_id [Integer] The id of the category
    associated to this sla
@controller_action_param :cloud_help_sla_workflow_details_id [Integer] The id of the
    workflow_detail associated to this sla. The workflow detail must be a detail of the
    workflow associated to this sla's type and category
@return [Json] Json that contains wheter the creation of the sla was successful or not. 
    If it is not successful, it returns an error message
@description Updates an existing sla associated to the *current_user*'s *account*. 
    Depending on the attributes updated, notifications are sent to the *users* that are
    subscribed. For example, if the priority changes from *Low* to *High*, a
    *sla_escalated* notification is sent to all subscribers.
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        sla:{
            detail_attributes:{
                cloud_help_catalog_sla_types_id:2,
                cloud_help_catalog_sla_categories_id:1,
                cloud_help_catalog_sla_priorities_id:2,
                subject:I would like a button to print my record,
                description:`
                    <div>In the <em>show screen</em>, 
                    I would like you to add a button to print the record 
                    I'm creating, istead of having to navigate to the 
                    <strong>options menu</strong>. It would save me some time</div>
                `
            }
        }
    }
    this.http.post('127.0.0.1/help/slas', data);
=end
        def update
            return respond_with_not_found unless @sla
            return respond_with_unauthorized unless @sla.is_editable_by?(current_user)

            old_attributes = @sla.attributes

            if @sla.update(sla_params)
                new_attributes = @sla.attributes
                Sla.log_activity_update(current_user, @sla, old_attributes, new_attributes)
                Workflow::Action.execute_actions(current_user, @sla, old_attributes, new_attributes)

                respond_with_successful(@sla.show(current_user, @query))
            else
                respond_with_error(@sla.errors.full_messages.to_sentence)
            end
        end

=begin
@description Retrieves a list of *sla* *types*, *sla* *categories* and *sla*
    *priorities* needed to create a new sla.
@example
    # Executing this controller's action from javascript's frontend
    this.http.get('127.0.0.1/help/slas/options').then(response => {
        if( response.successful ){
            console.log(JSON.stringify(response.data))
            # This will print something similar to
            #{
            #    "types":[
            #        {"id":1,"name":"Issue"},
            #        {"id":2,"name":"Change Request"}
            #    ],
            #    "categories":[
            #        {
            #            "id":1,"name":"Company System",
            #            "ancestry":null,"has_children":true,
            #            "active":true,"children_active":false,
            #            "depth":0
            #        },{
            #            "id":2,"name":"Books Module",
            #            "ancestry":"1","has_children":false,
            #            "active":false,"children_active":false,
            #            "depth":1
            #        }
            #    ],
            #    "priorities":[
            #        {"id":1,"name":"Low","weight":10},
            #        {"id":2,"name":"Medium","weight":100},
            #        {"id":3,"name":"High","weight":1000}
            #    ]
            #}
        }
    });
=end
        def options
            respond_with_successful(Sla.options(current_user, @query))
        end

        # @return [Json] Json that contains wheter the sla was successfully deleted or not. 
        #     If it it not successful, it returns an error message
        # @description Deletes an existing *sla* associated to the *current_user*'s *account*.
        # @example
        #     # Executing this controller's action from javascript's frontend
        #     let sla_id = 4;
        #     this.http.delete(`127.0.0.1/help/slas/${sla_id}`);
        def destroy
            return respond_with_not_found unless @sla
            return respond_with_unauthorized unless @sla.is_editable_by?(current_user)

            if @sla.destroy
                respond_with_successful

                Sla.log_activity_destroy(current_user, @sla)
            else
                respond_with_error(@sla.errors.full_messages.to_sentence)
            end
        end

        private

=begin
@return [void]
@description Sets the variable @sla. The variable contains the *sla*
    to be handled by the controller action that called this method
@example
    #suppose params[:id] = 1
    puts @sla # will display nil
    set_sla_state
    puts @sla # will display an instance of CloudHelp:Sla
=end
        def set_sla
            sla_id = params[:id] unless params[:id].blank?
            @sla = current_user.account.help.slas.find(sla_id)
        end
        
=begin
@return [Parameters] Allowed parameters for the sla
@description Sanitizes the parameters received from an HTTP call to only allow the
    specified ones. Allowed params are (:id, :subject, :description, :tags, :deadline, 
    :cloud_help_catalog_sla_types_id, :cloud_help_catalog_sla_priorities_id, 
    :cloud_help_catalog_sla_categories_id, :cloud_help_sla_worklfow_details_id)
@example
    # supose params contains {
    #    "sla": {
    #        "id": 5,
    #        "name": "My sla",
    #        "tags": "Important, Company"
    #    }
    #}
    filtered_params = sla_state_params
    puts filtered_params
    # will remove the id and only print {
    #    "tags": "Important, Company"
    #}
=end
        def sla_params
            params.require(:sla).permit(
                :cloud_help_workflow_statuses_id,
                :name,
                :expected_response_time,
                :expected_resolution_time,
                :price_per_hour,
                :body,
                :provider_repercussions,
                :client_repercussions,
                :exceptions,
                :default,
                :user_main_id
            )
        end

    end
end
