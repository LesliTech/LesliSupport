module CloudHelp
=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Model for ticket subscriber. Each record contains a reference to a user, and
    to an event. If a user is subscribed to multiple events, multiple records are created.
    This class inherits all its functionality from the *CloudObject::Subscriber* class
=end
    class Ticket::Subscriber < CloudObject::Subscriber
        belongs_to :cloud_object, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'

=begin
@attribute [Enumerable<Symbol>] event
    @return [:ticket_created, :ticket_closed, :comment_created, :action_created, :file_created, :activity_created, :workflow_updated, :priority_updated, :type_category_updated, :assignment_updated, :deadline_updated ]
=end
        enum event: [
            :ticket_created,
            :ticket_closed,
            :comment_created,
            :action_created,
            :file_created,
            :activity_created,
            :workflow_updated,
            :priority_updated,
            :type_category_updated,
            :assignment_updated,
            :deadline_updated
        ]
    end
end
