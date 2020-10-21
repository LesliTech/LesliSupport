module CloudHelp
    class Dashboard::Component < CloudObject::Dashboard::Component
        belongs_to :dashboard, inverse_of: :components, class_name: "Dashboard", foreign_key: "cloud_help_dashboards_id"
    end
end
