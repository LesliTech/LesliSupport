module CloudHelp
    class Dashboard < CloudObject::Dashboard
        belongs_to :account, class_name: "Account", foreign_key: "cloud_help_accounts_id"
        
        has_many :components, inverse_of: :dashboard, autosave: true, class_name: "Dashboard::Component", foreign_key: "cloud_help_dashboards_id", dependent: :destroy
        accepts_nested_attributes_for :components, allow_destroy: true
    end
end
