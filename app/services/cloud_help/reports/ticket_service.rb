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

            def self.general(current_user, query)
                filename =  translate_file_name("view_text_report_filename_tickets_general", "help.reports")
                filename = translate_file_name("view_text_report_filename_tickets_open", "help.reports") if query[:filters][:open]
                filename = translate_file_name("view_text_report_filename_tickets_overdue", "help.reports") if query[:filters][:overdue]

                file_headers = {
                    id: I18n.t("help.tickets.column_id"),
                    created_at: I18n.t("help.tickets.column_created_at"),
                    user_creator: I18n.t("help.tickets.column_users_id"),
                    subject: I18n.t("help.tickets.column_subject"),
                    deadline: I18n.t("help.tickets.column_deadline"),
                    ticket_type_name: I18n.t("help.tickets.column_cloud_help_catalog_ticket_types_id"),
                    ticket_priority_name: I18n.t("help.tickets.column_cloud_help_catalog_ticket_priorities_id"),
                    ticket_category_name: I18n.t("help.tickets.column_cloud_help_catalog_ticket_categories_id"),
                    user_assigned: I18n.t("help.tickets.column_user_main_id"),
                    status_name: I18n.t("help.tickets.column_cloud_help_workflow_statuses_id"),
                    status_type: I18n.t("core.workflow/statuses.column_status_type"),
                    hours_worked: I18n.t("help.tickets.column_hours_worked")
                }

                data = current_user.account.help.tickets
                .joins("left join cloud_help_ticket_assignments chta on chta.cloud_help_tickets_id = cloud_help_tickets.id")
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
                    "cloud_help_tickets.id",
                    "cloud_help_tickets.created_at",
                    "cloud_help_tickets.users_id",
                    :subject,
                    :deadline,
                    :hours_worked
                ).order("user_assigned_name asc")
                .order(id: :asc)

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

                data = data.map do |ticket|
                    {
                        file_headers[:id] => ticket.id,
                        file_headers[:created_at] => LC::Date.to_string_datetime(ticket.created_at),
                        file_headers[:user_creator] => ticket.user_creator_name,
                        file_headers[:subject] => ticket.subject,
                        file_headers[:deadline] => LC::Date.to_string(ticket.deadline),
                        file_headers[:ticket_type_name] => ticket.ticket_type_name,
                        file_headers[:ticket_category_name] => ticket.ticket_category_name,
                        file_headers[:ticket_priority_name] => ticket.ticket_priority_name,
                        file_headers[:user_assigned] => ticket.user_assigned_name,
                        file_headers[:status_name] => translate_status(ticket.status_name),
                        file_headers[:status_type] => translate_enum("status_type", ticket.status_type, "help.workflow/statuses"),
                        file_headers[:hours_worked] => ticket.hours_worked
                    }
                end

                data = Docm::Parser::Xlsx.parse(data)
                assigned_user = current_user.account.users.find_by_id(query[:filters][:user_assigned_id])

                title = filename
                title = "#{title}: #{assigned_user.full_name}" if assigned_user
                dates = []
                dates.push(LC::Date.to_string(query[:filters][:start_date])) if query[:filters][:start_date]
                dates.push(LC::Date.to_string(query[:filters][:end_date])) if query[:filters][:end_date]

                title = "#{title} #{dates.join(" - ")}"

                return Docm::Generator::Xlsx.generate(
                    filename,
                    [[filename, data]],
                    style_data: CloudHelp::Reports::StyleService.tickets_general,
                    title: {text: title, colspan: 12}
                )

            end
        end
    end
end
