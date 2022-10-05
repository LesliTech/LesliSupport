/*
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
*/


// · 
import { defineStore } from "pinia"


// · 
export const useAssignments = defineStore("assignments", {
    state: () => {
        return {
            loading: false,
            users: {},
            ticket_id: null,
        }
    },
    actions: {

        getOptions(){
            let url = this.url.help('tickets/assignments/options')
            this.loading = true
            this.http.get(url).then(result => {
                this.loading = false
                this.users = result
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        postAssignment(user){
            let url = this.url.help(`tickets/:ticket_id/assignments`, {ticket_id: this.ticket_id})

            let data = {
                ticket_assignment: {
                    users_id: user.id,
                    assignment_type: 'user'
                }
            }
            this.http.post(url, data).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
    }
})

