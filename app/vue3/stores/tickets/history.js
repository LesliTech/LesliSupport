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
export const useHistory = defineStore("histories", {
    state: () => {
        return {
            loading: false,
            histories: {},
            history: ''
        }
    },
    actions: {

        getHistories(ticketId) {
            this.loading = true
            this.http.get(this.url.help(`tickets/${ticketId}/histories`)).then(result => {
                this.loading = false
                this.histories = result
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        createHistory(ticketId){
            let data = {
                ticket_history: {
                    content: this.history
                }
            }

            this.http.post(this.url.help(`tickets/${ticketId}/histories`), data).then(result => {
                    this.resetHistoryForm()
                    this.histories.push(result)
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(()=>{
                this.submitting_form = false
            })
        },

        resetHistoryForm(){
            this.history = ''
        }

    }
})

