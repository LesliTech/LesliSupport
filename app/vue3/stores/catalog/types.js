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
export const useTicketTypes = defineStore("help.ticket_types", {
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
            type: {},
            filters: {
                per_page: 10
            }
        }
    },
    actions: {
        /**
         * @description This action is used to get the list of types of tickets
         */
        getTypes(url=this.url.help('catalog/ticket_types')) {
            this.loading = true 
            this.http.get(url.paginate(this.pagination.page, this.filters.per_page)).then(result => {
                this.index = result
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },
        /**
         * @description This action is used to create a new type of ticket
         */
        async postTicketType() {
            this.loading = true 
            return this.http.post(this.url.help('catalog/ticket_types'), this.type).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.loading = false
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
         * @description This action is used to create a update the type of ticket
         */
        updateTicketType() {
            this.loading = true 
            return this.http.put(this.url.help('catalog/ticket_types/:id', this.type.id), this.type).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.loading = false
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
         * @description This action is used to get the information of the ticket type
         * @param {Integer} id the id of the ticket type
         */
        getType(id){
            this.loading = true 
            this.http.get(this.url.help('catalog/ticket_types/:id', id)).then(result => {
                this.type = result
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },
        /**
         * @description This action is used to delete a type
         * @param {Integer} id the id of the type to be deleted
         */
        deleteType(id){
            this.dialog
            .confirmation({
                title: "Delete type",
                text: "Are you sure you want to delete this ticket type?",
                confirmText: "yes",
                cancelText: "no"
            })
            .then(({ isConfirmed }) => {
                if (isConfirmed) {
                    this.loading = true
                    this.http.delete(this.url.help('catalog/ticket_types/:id', id)).then(result => {
                        this.msg.success(I18n.t("core.users.messages_success_operation"))
                        this.loading = false
                    }).catch(error => {
                        this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
                    })
                }
            })
        },
        /**
         * @description This action is used to paginate types from index
         * @param {String} page The actual page showing.
         */
        paginateIndex(page) {
            this.pagination.page = page
            this.getTypes()
        },
        /**
         * @description This action is used to sort the list of types.
         * @param {String} column The column to sort the list of types
         * @param {String} direction The direction to sort the list of types (asc or desc)
         */
        sort(column, direction){
            this.getTypes(this.url.help('catalog/ticket_types').order(column, direction), false)
        },

        /**
         * @description This action is used to fetch with search results.
         * @param {String} string The string to search for.
         */
        search(string) {
            this.pagination.page = 1
            this.getTypes(this.url.help('catalog/ticket_types').search(string))
        },
        /**
        * @description This action is used to reload tickets types
        */
        reloadTypes(){
            this.index.records = []
            this.getTypes()
        },
    }

})

