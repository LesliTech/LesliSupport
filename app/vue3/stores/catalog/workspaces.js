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
export const useTicketWorkspaces = defineStore("help.ticket_workspaces", {
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
            workspaces: {},
            workspace: {}
        }
    },
    actions: {
        /**
         * @description This action is used to get the list of workspaces
         */
        getWorkspaces(url=this.url.help('catalog/ticket_workspaces')) {
            console.log(url)
            this.loading = true 
            this.http.get(url).then(result => {
                this.workspaces = result.records
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },
        /**
         * @description This action is used to create a new workspace
         */
        async postTicketWorkspace() {
            this.loading = true 
            return this.http.post(this.url.help('catalog/ticket_workspaces'), {
                ticket_workspace: this.workspace
            }).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.loading = false
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
         * @description This action is used to update a workspace
         */
        updateWorkspace() {
            this.loading = true 
            return this.http.put(this.url.help('catalog/ticket_workspaces/:id', this.workspace.id), this.workspace).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.loading = false
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
         * @description This action is used to get the information of a workspace
         * @param {Integer} id the id of the workspace
         */
        getWorkspace(id){
            this.loading = true 
            this.http.get(this.url.help('catalog/ticket_workspaces/:id', id)).then(result => {
                this.workspace = result
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },
        /**
         * @description This action is used to delete a workspace
         * @param {Integer} id the id of the workspace to be deleted
         */
        deleteWorkspace(id){
            this.dialog
            .confirmation({
                title: "Delete workspace",
                text: "Are you sure you want to delete this workspace?",
                confirmText: "yes",
                cancelText: "no"
            })
            .then(({ isConfirmed }) => {
                if (isConfirmed) {
                    this.loading = true
                    this.http.delete(this.url.help('catalog/ticket_workspaces/:id', id)).then(result => {
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

