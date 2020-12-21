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
    class SlasController < ApplicationController
        before_action :set_sla, only: [:update, :destroy]

=begin
@return [HTML|JSON] HTML view for listing all SLAs or a Json that contains a list 
    of all SLAs associated to this *account*
@description Retrieves and returns all SLAs associated to a *CloudHelp::Account*. 
    The account is obtained directly from *current_user*. The HTTP request has to specify
    whether the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/help/slas`);
=end
        def index
            respond_to do |format|
                format.html {}
                format.json do 
                    slas = current_user.account.help.slas.select(
                        :id,
                        :name,
                        :expected_response_time,
                        :expected_resolution_time,
                        :default,
                        :created_at,
                        :updated_at
                    )
                    responseWithSuccessful(slas)
                end
            end
        end

=begin
@return [HTML|Json] HTML view showing the requested SLA or a Json that contains the
    information of the SLA. If there is an error, an explanation message is sent
@description Retrieves and returns the requested SLA. The id of the 
    SLA is within the *params* attribute of the controller. The HTTP request has to specify
    whether the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let sla_id = 1;
    this.http.get(`127.0.0.1/help/slas/${sla_id}`);
=end
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    set_sla
                    if @sla
                        responseWithSuccessful(@sla)
                    else
                        responseWithError(I18n.t('cloud_help.controllers.slas.errors.not_found'))
                    end
                end
            end
        end

=begin
@return [HTML] HTML view for creating a new SLA
@description returns an HTML view with a form so users can create a new SLA
@example
    # Executing this controller's action from javascript's frontend
    this.url.go('/help/slas/new')
=end
        def new
        end

=begin
@return [HTML] HTML view for editing the SLA
@description returns an HTML view with a form so users edit an existing SLA
@example
    # Executing this controller's action from javascript's frontend
    let sla_id = 3;
    this.url.go(`/help/slas/${slas_id}/edit`)
=end
        def edit
        end

=begin
@controller_action_param :name [String] The name of the new SLA
@controller_action_param :body [String] A short description of the SLA
@controller_action_param :expected_resolution_time [Integer] The expected resolution time, in hours
@controller_action_param :expected_response_time [Integer] The expected response time, in hours
@controller_action_param :provider_repercussions [String] An HTML text indicataion the repercussions
    of not fulfilling the SLA expected dates
@controller_action_param :exceptions [String] An HTML text indicating which ocassions will be exceptions
    to the SLA
@controller_action_param :default [Boolean] Wheter this SLA is default or not. A default SLA will be
    assigned to new workflows once created
@return [Json] Json that contains whether the creation of the SLA was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new SLA associated to the *current_user*'s *account*
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        sla: {
            name: "Default SLA",
            body: "Template for a default SLA",
            expected_response_time: 72,
            expected_resolution_time: 240
        }
    };
    this.http.post('127.0.0.1/help/slas', data);
=end
        def create
            sla = Sla.new(sla_params)
            sla.cloud_help_accounts_id = current_user.account.id

            if sla.save
                responseWithSuccessful(sla)
            else
                responseWithError(sla.errors.full_messages.to_sentence)
            end
        end

=begin
@controller_action_param :name [String] The name of the SLA
@controller_action_param :body [String] A short description of the SLA
@controller_action_param :expected_resolution_time [Integer] The expected resolution time, in hours
@controller_action_param :expected_response_time [Integer] The expected response time, in hours
@controller_action_param :provider_repercussions [String] An HTML text indicataion the repercussions
    of not fulfilling the SLA expected dates
@controller_action_param :exceptions [String] An HTML text indicating which ocassions will be exceptions
    to the SLA
@controller_action_param :default [Boolean] Wheter this SLA is default or not. A default SLA will be
    assigned to new workflows once created
@return [Json] Json that contains wheter the SLA was successfully updated or not. 
    If it it not successful, it returns an error message
@description Updates an existing SLA associated to the *current_user*'s *account*.
@example
    # Executing this controller's action from javascript's frontend
    let sla_id = 4;
    let data = {
        sla: {
            name: "Default SLA",
            body: "<span>This is the body, and can be HTML</span>",
            exceptions: "<p>Exceptions can also be <b>HTML</b></p>",
            provider_repercussions: "<div>And provider repercussions can also be like this</div>"
        }
    };
    this.http.put(`127.0.0.1/help/slas/${sla_id}`, data);
=end
        def update
            if @sla.update(sla_params)
                responseWithSuccessful(@sla)
            else
                responseWithError(@sla.errors.full_messages.to_sentence)
            end
        end

=begin
@return [Json] Json that contains wheter the SLA was successfully deleted or not. 
    If it it not successful, it returns an error message
@description Deletes an existing *SLA* associated to the *current_user*'s *account*.
    If there is an existing *ticket* associated to the *SLA* and it is not in a 
    *final* *state*, it cannot be deleted
@example
    # Executing this controller's action from javascript's frontend
    let sla_id = 4;
    this.http.delete(`127.0.0.1/help/slas/${sla_id}`);
=end
        def destroy
            unless @sla
                return responseWithError(I18n.t('cloud_help.controllers.slas.errors.not_found'))
            end
            if @sla.destroy
                responseWithSuccessful
            else
                responseWithError(@sla.errors.full_messages.to_sentence)
            end
        end

        private

=begin
@return [void]
@description Sets the variable @sla. The variable contains the *SLA* 
    to be handled by the controller action that called this method
@example
    #suppose params[:id] = 1
    puts @sla # will display nil
    set_sla
    puts @sla # will display an instance of CloudHelp:Sla
=end
        def set_sla
            @sla = Sla.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

=begin
@return [Parameters] Allowed parameters for the SLA
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    Allowed params are :name, :body, :expected_resolution_time, :expected_response_time,
    :provider_repercussions, :exceptions, :default
@example
    # supose params contains {
    #    sla: {
    #       id: 5,
    #       name: "Default SLA",
    #       body: "Template for a default SLA",
    #       expected_response_time: 72,
    #       expected_resolution_time: 240,
    #       expected_closing_time: 445,
    #       injectect_sql: "delete * from users;"
    #    }
    #}
    filtered_params = sla_params
    puts filtered_params
    # will remove the id, expected_closing_time, and injected_sql fields and only print {
    #   name: "Default SLA",
    #   body: "Template for a default SLA",
    #   expected_response_time: 72,
    #   expected_resolution_time: 240,
    #   expected_closing_time: 445,
    #}
=end
        def sla_params
            params.fetch(:sla, {}).permit(
                :name,
                :body,
                :expected_resolution_time,
                :expected_response_time,
                :provider_repercussions,
                :exceptions,
                :default
            )
        end
    end
end
