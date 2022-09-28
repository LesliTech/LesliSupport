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


        }
    },
    actions: {

        getTickets() {
            this.getUsers()
            this.loading = true 
            this.http.get(this.url.help('tickets')).then(result => {
                this.loading = false
                this.tickets = result.tickets
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        getOptions(){
            this.loading = true 
            this.http.get(this.url.help('tickets/options')).then(result => {
                this.loading = false
                
                this.options.types = result.types.map((type)=> {
                    return {
                        label: type.name,
                        value: type.id
                    }
                } )

                this.options.categories = result.categories.map((category)=> {
                    return {
                        label: category.name,
                        value: category.id
                    }
                } )

                this.options.priorities = result.priorities.map((priority)=> {
                    return {
                        label: priority.name,
                        value: priority.id
                    }
                })

                this.options.workspaces = result.workspaces.map((workspace)=> {
                    return {
                        label: workspace.name,
                        value: workspace.id
                    }
                })
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
            
        },

        postTicket() {
            this.receiverUsers.map(user => user.email),

            this.http.post(this.url.help('tickets'), this.ticket).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        updateTicket(){
            this.http.put(this.url.help('tickets'), this.ticket).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        resetTicketStore(){
            this.ticket = { }
        },

        fetchTicket(id=null){
            this.loading = true

            let url = this.url.help('tickets')

            if (id) { url = this.url.help('tickets/:id', id)}

            this.http.get(url).then(result => {
                this.ticket = result
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },

        deleteTicket(){
            this.dialog
                .confirmation({
                    title: "Delete ticket",
                    text: "Are you sure you want to delete this ticket?",
                    confirmText: "yes",
                    cancelText: "no"
                })
                .then(({ isConfirmed }) => {
                    if (isConfirmed) {
                        this.http.delete(this.url.help('tickets/:id', this.ticket.id)).then(result => {
                            this.msg.success(I18n.t("core.users.messages_success_operation"))
                        }).catch(error => {
                            this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
                        })
                    }
                })
        },

        getUsers() {
            this.loading = true
            this.http.get(this.url.admin('users/list')).then(result => {
                this.users = result
            }).catch(error => {
                this.msg.danger(error)
                console.log(error)
            }).finally(() => {
                this.loading = false
            })
        },



    }
})

