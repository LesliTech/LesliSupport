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
    class ReportsController < ApplicationLesliController
        helper WickedPdf::WickedPdfHelper::Assets

        def privileges
            {
                new: [],
                edit: [],
                index: [],
                show: [],
                destroy: []
            }
        end

        def index
        end

        def tickets_general
            respond_to do |format|
                format.xlsx do
                    send_file Reports::TicketService.generate_xlsx(current_user, @query) 
                end

                format.pdf do
                    filename = "#{I18n.t("help.reports.view_file_template_tickets_report")}_#{Date.today.strftime("%Y%m%d")}.pdf"

                    reports_data = Reports::TicketService.get_data(current_user, @query, translate_headers: false)
                    @data = reports_data[:data]
                    @total_hours = reports_data[:total_hours]
                    @title =  Reports::TicketService.create_title(current_user, @query)
                    @company = current_user.account
                    @workspace = @company.help.ticket_workspaces.find_by_id(@query[:filters][:workspace_id]) if @query[:filters][:workspace_id]

                    pdf = WickedPdf.new.pdf_from_string(
                        render_to_string(
                            Reports::TicketService.pdf_template_path,
                            layout: Reports::TicketService.pdf_layout_path
                        ),
                        footer: {
                            content: render_to_string(
                                Reports::TicketService.pdf_footer_path,
                                layout: Reports::TicketService.pdf_layout_path
                            )
                        },
                        header: {
                            content: render_to_string(
                                Reports::TicketService.pdf_header_path,
                                layout: Reports::TicketService.pdf_layout_path
                            )
                        },
                        margins: Reports::TicketService.pdf_margins
                    )

                    send_data(pdf, filename: filename)
                end
            end
        end
    end
end
