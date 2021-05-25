module CloudHelp
  class Sla::Subscriber < CloudObject::Subscriber
    belongs_to :cloud_object, class_name: "CloudHelp::Sla", foreign_key: "cloud_help_slas_id"
  end
end
