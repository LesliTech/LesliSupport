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
import dayjs from 'dayjs'


// · 
export const useTickets = defineStore("help.tickets", {
    state: () => {
        return {
            loading: false,
            loading_options: false,
            tickets: [],
            options: {},
            tags: [],
            workspaces_options: 0,
            ticket: {
                cloud_help_catalog_ticket_types_id: null,
                cloud_help_catalog_ticket_categories_id: null,
                cloud_help_catalog_ticket_sources_id: null,
                cloud_help_catalog_ticket_priorities_id: null,
                cloud_help_catalog_ticket_workspaces_id: null,
                subject: null,
                description: '',
                deadline: new Date(),
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
                search_type: 'active',
                user_type: null,
                per_page: 10
            }
        }
    },
    actions: {
        /**
         * @description This action is used to get the list of tickets
         */
        getTickets(url=this.url.help('tickets')) {
            this.tickets = []
            this.loading = true 
            const query_filters = {}

            //Format filters to send them in the query string
            for (const [key, value] of Object.entries(this.filters)) {
                query_filters[key] = [value]
            }

            this.http.get(url.paginate(this.pagination.page, this.filters.per_page).filter(query_filters)
            ).then(result => {
                this.index = result
                this.tickets = result.records
                this.tickets.forEach((ticket)  =>{
                    ticket.deadline = new Date(ticket.deadline)
                })
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },

        /**
         * @description This action is used to get options for selectors in ticket form
         */
        getOptions(ticket_id=null){
            this.loading = true
            this.options = {}
            this.http.get(this.url.help('tickets/options')).then(result => {
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

                this.workspaces_options = Object.keys(this.options.workspaces).length

            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
                /* If a ticket id is given, fetch the info from the ticket corresponding */
                if(ticket_id){
                    this.fetchTicket(ticket_id)
                }
            })
            
        },

        /**
         * @description This action is used to post a new ticket
         */
        postTicket() {
            //Veriy if tags in tickets were selected 
            let selected_tags = null
            if (this.tags.length > 0) {
                selected_tags = this.tags.map(tag => tag.name).join(',')
            } else{
                selected_tags = null
            }

            //If there is only one option to workspaces set the value to this option
            if (this.workspaces_options == 1){
                this.ticket.cloud_help_catalog_ticket_workspaces_id = this.options.workspaces[0].value
            }

            this.http.post(this.url.help('tickets'), {
                ticket: {
                    ...this.ticket,
                    tags: selected_tags
                }
            }).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        /**
         * @description This action is used to update a ticket
         */
        updateTicket(){

            //Veriy if tags in tickets were selected 
            let selected_tags = null
            if (this.tags.length > 0) {
                selected_tags = this.tags.map(tag => tag.name).join(',')
            } else{
                selected_tags = null
            }

            this.http.put(this.url.help('tickets/:id', this.ticket.id), {
                ticket: {
                    ...this.ticket,
                    tags: selected_tags
                }
                
            }).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        /**
         * @description This action is used to fetch a ticket.
         * @param {Integer} id The id of the ticket.
         */
        fetchTicket(id){

            this.loading = true
            this.ticket = {}
            const url = this.url.help('tickets/:id', id)

            this.http.get(url).then(result => {
                this.ticket = result

                // Get the list of tags from a ticket and parse to a format used by the input tag component
                this.tags = []
                if (this.ticket.tags != null) {
                    this.ticket.tags.split(',').forEach((tag)=>{
                        this.tags.push({name: tag})
                    })
                }

                this.ticket.deadline= dayjs(this.ticket.deadline).format('YYYY-MM-DD') //Change date format to show in date selector

            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },

        /**
         * @description This action is used to delete a ticket
         */
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

        /**
         * @description This action is used to paginate tickets from index
         * @param {String} page The actual page showing.
         */
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
        }
    }
})

