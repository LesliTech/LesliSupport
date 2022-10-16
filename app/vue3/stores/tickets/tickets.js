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
export const useTickets = defineStore("tickets", {
    state: () => {
        return {
            loading: false,
            tickets: [],
            options: {},
            ticket: {
                cloud_help_catalog_ticket_types_id: null,
                cloud_help_catalog_ticket_categories_id: null,
                cloud_help_catalog_ticket_sources_id: null,
                cloud_help_catalog_ticket_priorities_id: null,
                cloud_help_catalog_ticket_workspaces_id: null,
                subject: null,
                description: {},
                deadline: new Date(),
                tags: [],
                hours_worked: 0
            },
            pagination: {
                page: 1
            },
            index: { 
                pagination: {},
                records: []
            },
            filters: {
                cloud_help_catalog_ticket_workspaces_id: null,
                search_type: null,
                user_type: 'own'
            }
        }
    },
    actions: {

        getTickets(url=this.url.help('tickets')) {
            this.loading = true 
            const query_filters = {}

            for (const [key, value] of Object.entries(this.filters)) {
                query_filters[key] = [value]
            }

            this.http.get(url.paginate(this.pagination.page).filter(query_filters)
            ).then(result => {
                this.loading = false
                this.index = result
                this.tickets = result.records
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
            this.http.post(this.url.help('tickets'), this.ticket).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        updateTicket(){
            console.log(this.ticket)
            this.http.put(this.url.help('tickets/:id', this.ticket.id), this.ticket).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        resetTicketStore(){
            this.ticket = {}
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
        /**
        * @description This action is used to reload tickets
        */
        reloadTickets(){
            this.tickets = []
            this.getTickets()
        },

        paginateIndex(page) {
            this.pagination.page = page
            this.getTickets()
        },

        /**
         * @description This action is used to sort the list of leads.
         * @param {String} column The column to sort the list of leads
         * @param {String} direction The direction to sort the list of leads (asc or desc)
         */
        sort(column, direction){
            this.getTickets(this.url.help('tickets').order(column, direction), false)
        },

        /**
         * @description This action is used to fetch with search results.
         * @param {String} string The string to search for.
         */
        search(string) {
            this.getTickets(this.url.help('tickets').search(string))
        },

    }
})

