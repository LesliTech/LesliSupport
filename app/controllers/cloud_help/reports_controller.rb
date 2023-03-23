=begin
Copyright (c) 2022, all rights reserved.

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
    class ReportsController < ApplicationLesliController
        helper WickedPdf::WickedPdfHelper::Assets

        def index
        end

        def tickets_general
            respond_to do |format|
                format.xlsx do
                    send_file Reports::TicketService.generate_xlsx(current_user, @query) 
                end

                format.pdf do 

                    filename = "#{I18n.t("help.reports.view_file_template_tickets_report")}_#{Date.today.strftime("%Y%m%d")}"

                    reports_data = Reports::TicketService.get_data(current_user, @query, translate_headers: false)
                    @data = reports_data[:data]
                    @total_hours = reports_data[:total_hours]
                    @title =  Reports::TicketService.create_title(current_user, @query)
                    @company = current_user.account
                    @workspace = @company.help.ticket_workspaces.find_by_id(@query[:filters][:workspace_id]) if @query[:filters][:workspace_id]

                    render pdf: filename, orientation: "Landscape"
                end

            end
        end
    end
end
