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
export const useTicketPriorities = defineStore("help.ticket_priorities", {
    state: () => {
        return {
            loading: false,
            pagination: {
                page: 1
            },
            index: { 
                pagination: {},
                records: []
            },
            priorities: {},
            priority: {}
        }
    },
    actions: {
        /**
         * @description This action is used to get the list of priorities
         */
        getPriorities(url=this.url.help('catalog/ticket_priorities')) {
            this.loading = true 
            this.http.get(url).then(result => {
                this.priorities = result.ticket_priorities
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },
        /**
         * @description This action is used to create a new priority
         */
        async postTicketPriority() {
            this.loading = true 
            return this.http.post(this.url.help('catalog/ticket_priorities'), this.priority).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.loading = false
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
         * @description This action is used to update a priority
         */
        updatePriority() {
            this.loading = true 
            return this.http.put(this.url.help('catalog/ticket_priorities/:id', this.priority.id), this.priority).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.loading = false
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
         * @description This action is used to get the information of a priority
         * @param {Integer} id the id of the priority
         */
        getPriority(id){
            this.loading = true 
            this.http.get(this.url.help('catalog/ticket_priorities/:id', id)).then(result => {
                this.priority = result
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },
        /**
         * @description This action is used to delete a priority
         * @param {Integer} id the id of the priority to be deleted
         */
        deletePriority(id){
            this.dialog
            .confirmation({
                title: "Delete priority",
                text: "Are you sure you want to delete this priority type?",
                confirmText: "yes",
                cancelText: "no"
            })
            .then(({ isConfirmed }) => {
                if (isConfirmed) {
                    this.loading = true
                    this.http.delete(this.url.help('catalog/ticket_priorities/:id', id)).then(result => {
                        this.msg.success(I18n.t("core.users.messages_success_operation"))
                        this.loading = false
                    }).catch(error => {
                        this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
                    })
                }
            })
        }
    }

})

