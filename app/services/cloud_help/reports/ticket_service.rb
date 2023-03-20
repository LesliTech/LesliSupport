=begin
Copyright (c) 2021, all rights reserved.

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
    module Reports
        class TicketService
            include ::Reports::Helper

            def self.generate_xlsx(current_user, query)
                report_data = self.get_data(current_user, query)
                data = Docm::Parser::Xlsx.parse(report_data[:data])
                total_hours = report_data[:total_hours]
                assigned_user = current_user.account.users.find_by_id(query[:filters][:user_assigned_id])

                filename =  translate_file_name("view_text_report_filename_tickets_general", "help.reports")
                filename = translate_file_name("view_text_report_filename_tickets_open", "help.reports") if query[:filters][:open]
                filename = translate_file_name("view_text_report_filename_tickets_overdue", "help.reports") if query[:filters][:overdue]

                title = self.create_title(current_user, query)

                summary_text = "#{I18n.t("help.tickets.view_text_total_hours_worked")}: #{total_hours}"
                if report_data[:workspace]
                    summary_text = "#{I18n.t("help.tickets.column_cloud_help_catalog_ticket_workspaces_id")}: #{report_data[:workspace]} - #{summary_text}"
                end
                
                colspan = query[:filters][:simplified] ? 9 : 12
                stylesheet = query[:filters][:simplified] ? Reports::StyleService.tickets_general_simplified : Reports::StyleService.tickets_general

                return Docm::Generator::Xlsx.generate(
                    filename,
                    [[filename, data]],
                    style_data: stylesheet,
                    title: {text: title, colspan: colspan },
                    summary: {text: summary_text, colspan: colspan}
                )
            end

            def self.generate_pdf(current_user, query)
                pdf = WickedPdf.new.pdf_from_string(
                    render_to_string(
                        self.pdf_template_path,
                        layout: self.pdf_layout_path
                    ),
                    footer: {
                        content: render_to_string(
                            self.pdf_footer_path,
                            layout: self.pdf_layout_path
                        )
                    },
                    header: {
                        content: render_to_string(
                            self.pdf_header_path,
                            layout: self.pdf_layout_path
                        )
                    },
                    margins: self.pdf_margins
                )
            end

            def self.create_title(current_user, query)
                title = translate_file_name("view_text_report_filename_tickets_general", "help.reports")
                title = translate_file_name("view_text_report_filename_tickets_open", "help.reports") if query[:filters][:open]
                title = translate_file_name("view_text_report_filename_tickets_overdue", "help.reports") if query[:filters][:overdue]
                assigned_user = current_user.account.users.find_by_id(query[:filters][:user_assigned_id])
                title = "#{title}: #{assigned_user.full_name}" if assigned_user
                dates = []
                dates.push(LC::Date.to_string(query[:filters][:start_date])) if query[:filters][:start_date]
                dates.push(LC::Date.to_string(query[:filters][:end_date])) if query[:filters][:end_date]

                title = "#{title} #{dates.join(" - ")}"

                return title
            end

            def self.get_data(current_user, query, translate_headers: true)

                file_headers = {
                    id: I18n.t("help.tickets.column_id"),
                    created_at: I18n.t("help.tickets.column_created_at"),
                    creation_time: I18n.t("help.tickets.column_creation_time"),
                    user_creator: I18n.t("help.tickets.column_users_id"),
                    subject: I18n.t("help.tickets.column_subject"),
                    description: I18n.t("help.tickets.column_description"),
                    deadline: I18n.t("help.tickets.column_deadline"),
                    ticket_type_name: I18n.t("help.tickets.column_cloud_help_catalog_ticket_types_id"),
                    ticket_priority_name: I18n.t("help.tickets.column_cloud_help_catalog_ticket_priorities_id"),
                    ticket_category_name: I18n.t("help.tickets.column_cloud_help_catalog_ticket_categories_id"),
                    user_assigned: I18n.t("help.tickets.column_user_main_id"),
                    status_name: I18n.t("help.tickets.column_cloud_help_workflow_statuses_id"),
                    hours_worked: I18n.t("help.tickets.column_hours_worked")
                }

                # Get the names of the initial and final status 
                initial_status = CloudHelp::Workflow::Status.find_by(status_type:'initial').name
                final_status = CloudHelp::Workflow::Status.find_by(status_type:'completed_successfully').name


                data = current_user.account.help.tickets
                .joins("left join cloud_help_ticket_assignments chta on chta.cloud_help_tickets_id = cloud_help_tickets.id and chta.deleted_at is null")
                .joins("left join users ua on chta.users_id = ua.id")
                .joins("left join user_details uad on ua.id = uad.users_id")
                .joins("inner join users uc on cloud_help_tickets.users_id = uc.id")
                .joins("left join user_details uac on uc.id = uac.users_id")
                .joins(:status)
                .joins("left join cloud_help_catalog_ticket_types chctt on chctt.id = cloud_help_tickets.cloud_help_catalog_ticket_types_id")
                .joins("left join cloud_help_catalog_ticket_categories chctc on chctc.id = cloud_help_tickets.cloud_help_catalog_ticket_categories_id")
                .joins("left join cloud_help_catalog_ticket_priorities chctp on chctp.id = cloud_help_tickets.cloud_help_catalog_ticket_priorities_id")
                .select(
                    "concat(uad.first_name, ' ', uad.last_name) as user_assigned_name",
                    "concat(uac.first_name, ' ', uac.last_name) as user_creator_name",
                    "chctt.name as ticket_type_name",
                    "chctc.name as ticket_category_name",
                    "chctp.name as ticket_priority_name",
                    "cloud_help_workflow_statuses.name as status_name",
                    "cloud_help_workflow_statuses.status_type as status_type",
                    "cloud_help_workflow_statuses.number as status_number",
                    "cloud_help_tickets.created_at",
                    "cloud_help_tickets.users_id",
                    "cloud_help_tickets.description",
                    :subject,
                    :deadline,
                    :hours_worked,
                    :id,
                    :started_at,
                    :finished_at
                )

                if query[:filters][:workspace_id]
                    data = data.where("cloud_help_tickets.cloud_help_catalog_ticket_workspaces_id = ?", query[:filters][:workspace_id])
                end

                if query[:filters][:user_assigned_id]
                    data = data.where("ua.id = ?", query[:filters][:user_assigned_id])
                end

                if query[:filters][:start_date]
                    start_date = LC::Date.datetime(query[:filters][:start_date]).beginning_of_day
                    data = data.where("cloud_help_tickets.created_at >= ?", start_date)
                end

                if query[:filters][:end_date]
                    end_date = LC::Date.datetime(query[:filters][:end_date]).end_of_day
                    data = data.where("cloud_help_tickets.created_at < ?", end_date)
                end

                if query[:filters][:open] || query[:filters][:overdue]
                    data = data.where(
                        "cloud_help_workflow_statuses.status_type not in (?)",
                        ["completed_successfully", "completed_unsuccessfully"]
                    )
                end

                if query[:filters][:overdue]
                    data = data.where("cloud_help_tickets.deadline <= ?", LC::Date.now)
                end

                if query[:filters][:group_by_status]
                    data = data.order(status_number: :desc)
                end

                data = data.order("user_assigned_name asc").order(id: :asc)

                total_hours = 0.0

                data = data.map do |ticket|
                    total_hours = total_hours + (ticket.hours_worked || 0)

                    # Parse description from tickets to get only the text without HTML tags
                    ticket.description = Nokogiri::HTML(ticket.description).text

                    if translate_headers
                        row = {
                            file_headers[:id] => ticket.id,
                            file_headers[:created_at] => LC::Date.to_string(ticket.created_at),
                            file_headers[:creation_time] => LC::Date.to_string_time(ticket.created_at),
                            file_headers[:user_creator] => ticket.user_creator_name,
                            file_headers[:subject] => ticket.subject,
                            file_headers[:deadline] => LC::Date.to_string(ticket.deadline),
                            file_headers[:ticket_type_name] => ticket.ticket_type_name,
                            file_headers[:ticket_category_name] => ticket.ticket_category_name,
                            file_headers[:ticket_priority_name] => ticket.ticket_priority_name,
                            file_headers[:user_assigned] => ticket.user_assigned_name,
                            file_headers[:status_name] => translate_status(ticket.status_name),
                            file_headers[:hours_worked] => ticket.hours_worked,
                            file_headers[:description] => ticket.description,
                            file_headers[:start_date] => LC::Date.to_string_datetime(ticket.started_at),
                            file_headers[:end_date] => LC::Date.to_string_datetime(ticket.finished_at)

                        }
                        if query[:filters][:simplified]
                            row.delete(file_headers[:creation_time])
                            row.delete(file_headers[:ticket_priority_name])
                            row.delete(file_headers[:user_assigned])
                        end
                    else
                        row = {
                            id: ticket.id,
                            created_at: LC::Date.to_string(ticket.created_at),
                            creation_time: LC::Date.to_string_time(ticket.created_at),
                            user_creator: ticket.user_creator_name,
                            subject: ticket.subject,
                            deadline: LC::Date.to_string(ticket.deadline),
                            ticket_type_name: ticket.ticket_type_name,
                            ticket_category_name: ticket.ticket_category_name,
                            ticket_priority_name: ticket.ticket_priority_name,
                            user_assigned: ticket.user_assigned_name,
                            status_name: translate_status(ticket.status_name),
                            hours_worked: ticket.hours_worked,
                            description: ticket.description,
                            start_date: LC::Date.to_string_datetime(ticket.started_at),
                            end_date: LC::Date.to_string_datetime(ticket.finished_at)
                        }
                    end

                    row
                end

                result = {
                    data: data,
                    total_hours: total_hours
                }

                if query[:filters][:workspace_id]
                    workspace = current_user.account.help.ticket_workspaces.find_by_id(query[:filters][:workspace_id])
                    result[:workspace] = workspace.name if workspace
                end

                return result
            end

            protected

            def self.pdf_template_path
                return "cloud_help/reports/tickets/show"
            end

            def self.pdf_footer_path
                return "cloud_help/reports/tickets/footer"
            end

            def self.pdf_layout_path
                return "cloud_help/layout"
            end

            def self.pdf_header_path
                return "cloud_help/reports/tickets/header"
            end

            def self.pdf_margins
                return {
                    top: "1cm",
                    botton: "1cm"
                }
            end
        end
    end
end
