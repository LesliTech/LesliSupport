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
require_dependency "cloud_help/application_controller"

module CloudHelp
    class Sla::AssociationsController < ApplicationController
        before_action :set_sla, only: [:create, :destroy]

        # @return [HTML|JSON] HTML view for listing all associations of an sla or a Json that contains a list of 
        #     all associations that beloing to a certain SLA 
        # @description Retrieves and returns all sla associations that belong to the SLA specified by the param :sla_id.
        # This is only possible if the SLA belongs to the account specified by current_user. 
        # The account is obtained directly from *current_user*. The HTTP request has to specify
        #     wheter the HTML or the JSON text should be rendered
        # @example
        #     # Executing this controller's action from javascript's frontend
        #     let sla_id: 1;
        #     this.http.get(`127.0.0.1/help/slas/${sla_id}/associations.json`);
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    set_sla
                    return respond_with_not_found unless @sla

                    respond_with_successful(@sla.associations_list) 
                end
            end
        end

        # @controller_action_param :cloud_help_catalog_ticket_types_id [Integer] The id of the ticket type that is going to be added as an association
        # @return [Json] Json that contains wheter the creation of the association was successful or not. 
        #     If it is not successful, it returns an error message
        # @description Creates a new association for the SLA specified by the param :sla_id. This is only possible if the SLA belongs to the account specified
        # by current_user and if current_user has the correct privileges.
        # @example
        #     # Executing this controller's action from javascript's frontend
        #     let data = {
        #         sla_association: {
        #             cloud_help_catalog_ticket_types_id: 3
        #         }
        #     };
        #     let sla_id = 3;
        #     this.http.post(`127.0.0.1/help/slas/${this.sla_id}/associations`, data);
        def create
            return respond_with_not_found unless @sla
            return respond_with_unauthorized unless @sla.is_editable_by?(current_user)

            association = Sla::Association.new(sla_association_params)
            association.sla = @sla

            if association.save
                respond_with_successful(association)

                Sla.log_activity_create_association(current_user, @sla, association)
            else
                respond_with_error(association.errors.full_messages.to_sentence)
            end
        end

        # @return [Json] Json that contains wheter the sla association was successfully destroyed or not. 
        #     If it it not successful, it returns an error message
        # @description Deletes an existing *SLA* *association*. This is only possible if the SLA belongs to the account specified
        # by current_user and if current_user has the correct privileges.
        # @example
        #     # Executing this controller's action from javascript's frontend
        #     let sla_id = 4;
        #     let association_id = 5;
        #     this.http.delete(`127.0.0.1/help/slas/${sla_id}/associations/${association_id}`);
        def destroy
            return respond_with_not_found unless @sla
            return respond_with_unauthorized unless @sla.is_editable_by?(current_user)

            association = @sla.associations.find_by(id: params[:id])
            return respond_with_not_found unless association

            if association.destroy
                respond_with_successful
                Sla.log_activity_destroy_association(current_user, @sla, association)
            else
                respond_with_error(association.errors.full_messages.to_sentence)
            end
        end

        def options
            respond_with_successful(Sla::Association.options(current_user, @query))
        end

        private

        # @return [void]
        # @description Sets the variable @sla. The variable contains the *sla*
        #     to be handled by the controller action that called this method. If no SLA
        #     is found, the nil is used instead. This verifies also that the SLA is within the
        #     current_users's account
        # @example
        #     #suppose params[:sla_id] = 1
        #     puts @sla # will display nil
        #     set_sla
        #     puts @sla # will display an instance of CloudHelp:Sla
        def set_sla
            @sla = Sla.find_by(
                id: params[:sla_id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

        # @return [Parameters] Allowed parameters for the sla
        # @description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
        #     Allowed params are :cloud_help_catalog_ticket_types_id
        # @example
        #     # supose params contains {
        #     #    "sla_association": {
        #     #        "id": 5,
        #     #        "cloud_help_catalog_ticket_types_id": 6
        #     #    }
        #     #}
        #     filtered_params = sla_association_params
        #     puts filtered_params
        #     # will remove all extra fields and only print {
        #     #    "cloud_help_catalog_ticket_types_id": 6
        #     #}
        def sla_association_params
            params.fetch(:sla_association, {}).permit(
                :cloud_help_catalog_ticket_types_id
            )
        end
    end
end
