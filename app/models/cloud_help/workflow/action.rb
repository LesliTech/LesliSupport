module CloudHelp
    class Workflow::Action < CloudObject::Workflow::Action
        belongs_to :workflow, class_name: "Workflow", foreign_key: "cloud_help_workflows_id"
        belongs_to :workflow_including_deleted, class_name: "Workflow", foreign_key: "cloud_help_workflows_id", with_deleted: true
        belongs_to :initial_status, class_name: "Workflow::Status", foreign_key: "initial_status_id", optional: true
        belongs_to :final_status, class_name: "Workflow::Status", foreign_key: "final_status_id"

    end
end
