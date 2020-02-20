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
@description Model for SLAs (Service Level Agreements). A SLA is associated to a *ticket*,
    based on its *type*/*category*. However, it is not a direct association, rather, it is associated
    through a the *ticket*'s *workflow*

=end
    class Sla < ApplicationRecord

        belongs_to  :account,       class_name: "CloudHelp::Account",           foreign_key: "cloud_help_accounts_id"
        has_many    :associations,  class_name: "CloudHelp::Sla::Association",  foreign_key: "cloud_help_slas_id"

        # @todo See a way to sumarize these parts into one call
        after_update :verify_default_sla
        after_create :verify_default_sla

=begin
@return [Boolean] Wheter the SLA was updated or not
@description Attempts to updated this SLA.
    However, if there is a *ticket* associated to this *SLA*, and the ticket is not
    in a *final* *state*, it will not be updated, and an error will be added to the 
    *errors* parameter
@example
    my_sla = CloudHelp::Sla.first
    if my_sla.update(expected_response_time: 500)
        puts "SLA successfully updated"
    else
        puts "SLA was not updated"
        puts my_sla.errors.full_messages.to_sentence
    end
=end
        def update(params)
            ticket_count = Sla.joins(
                "inner join cloud_help_sla_associations CHSA on CHSA.cloud_help_slas_id = cloud_help_slas.id"
            ).joins(
                "
                    inner join cloud_help_tickets CHT on 
                        CHSA.cloud_help_catalog_ticket_types_id = CHT.cloud_help_catalog_ticket_types_id and
                        CHSA.cloud_help_catalog_ticket_categories_id = CHT.cloud_help_catalog_ticket_categories_id 
                "
            ).joins(
                "inner join cloud_help_workflow_statuses CHWS on CHT.cloud_help_workflow_statuses_id = CHWS.id"
            ).where(
                "CHWS.final = false"
            ).where(
                "cloud_help_slas.id = #{id}"
            ).count

            if ticket_count > 0
                errors.add(:base, :cannot_modify_while_ticket_in_progress)
                return false
            end

            super
        end

=begin
@return [Boolean] Wheter the SLA was deleted or not
@description Attempts to delete this SLA.
    However, if there is a *ticket* associated to this *SLA*, it 
    will not be deleted and an error will be added to the *errors* parameter
@example
    my_sla = CloudHelp::Sla.first
    if my_sla.destroy
        puts "SLA successfully destroyed"
    else
        puts "SLA was not destroyed"
        puts my_sla.errors.full_messages.to_sentence
    end
=end
        def destroy
            begin
                if default
                    errors.add(:base, :cannot_delete_default)
                    return false
                end
                super
            rescue ActiveRecord::InvalidForeignKey
                errors.add(:base, :foreign_key_prevents_destruction)
                false
            end
        end

protected

=begin
@return [void]
@description Checks if the *default* field of the SLA changed.
    If it changed to true, sets the previously *default* sla as *not* *default*. If it changed
    to false, checks if there is another SLA marked as true. After these verifications, if there
    is no *default* *SLA*, triggers a rollback and adds an error message to the *errors* param
@example
    my_sla = CloudHelp::Sla.first
    if my_sla.update(default: true)
        puts "SLA successfully updated as default"
    else
        puts "SLA was not updated as default"
        puts my_sla.errors.full_messages.to_sentence
    end
=end
        def verify_default_sla
            default_change = saved_changes["default"]
            return unless default_change
            
            puts default_change.to_json
            if default_change[1]
                # default changed from false to true
                raise ActiveRecord::RecordInvalid, self unless Sla.where(
                    default: true, account: account
                ).where.not(
                    id: id
                ).update(
                    default: false
                )
            else
                # default changed from true to false
                unless Sla.where(default: true, account: account).where.not(id: id).count > 0
                    errors.add(:base, :cannot_remove_default)
                    raise ActiveRecord::RecordInvalid, self
                end
            end
        end
    end
end
