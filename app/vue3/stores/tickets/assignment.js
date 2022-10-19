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
import { useTickets } from "./tickets"


// · 
export const useAssignments = defineStore("core.assignments", {
    state: () => {
        return {
            loading: false,
            users: {},
            ticket_id: null,
            ticket: {},
            storeTickets: useTickets()
        }
    },
    actions: {
        /**
         * @description This action is used to fetch the users that can be assigned to tickets
         */
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

        /**
         * @description This action is used to post a new assignment of a ticket
         * @param {Object} user The user that is going to be assigned to the ticket
         */
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

        /**
         * @description This action is used to delete an assignment
         * @param {String} assignment_id The id of the assignment that is being deleted
         */
        deleteAssignment(assignment_id){
            let url = this.url.help(`tickets/:ticket_id/assignments/:id`, {ticket_id: this.storeTickets.ticket.id, id: assignment_id})
            this.http.delete(url).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.storeTickets.ticket.assignment_attributes = this.storeTickets.ticket.assignment_attributes.filter((assignment)=>{
                    return assignment.id != assignment_id
                })
            }).catch(error => {
                console.log(error)
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
         * @description This action is used to fetch the information of the actual ticket
         * @param {Integer} id id of the ticket.
         */
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
                this.markAssignables()
            })
        },
        /**
         * @description This action is used to mark as assigned the users that are already assigned
         */
        markAssignables(){
            this.users_table = []
            this.ticket.assignment_attributes.forEach((assignment)=>{
                const user = this.users.find((user)=>{
                    return user.id == assignment.users_id
                })
                user['checked'] = true
                user['assignment_id'] = assignment.id
            })
        }
    }
})

