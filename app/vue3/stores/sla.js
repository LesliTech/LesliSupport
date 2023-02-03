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
export const useSlas = defineStore("help.sla", {
    state: () => {
        return {
            loading: false,
            slas: {},
            sla:{},
            pagination: {
                page: 1
            },
            index: { 
                pagination: {},
                records: []
            },
            associationOptions: {},
            associations: []
        }
    },
    actions: {
        /**
        * @description This action is used to get the list of slas
        */
        getSlas(){
            this.loading = true
            this.http.get(this.url.help('slas').paginate(this.pagination.page)).then(result => {
                this.loading = false
                this.index = result
                this.slas = result.records
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
        * @description This action is used to post a new sla
        */
        async postSla(){
            this.loading = true
            return this.http.post(this.url.help('slas'), {
                sla: this.sla
            }).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.loading = false
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
        * @description This action is used to get SLA information
        * @param {Integer} id The id of the sla
        */
        fetchSla(id){
            this.sla = {}
            this.http.get(this.url.help('slas/:id', id)).then(result => {
                this.sla = result
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
         * @description This action is used to paginate slas from index
         * @param {String} page The actual page showing.
         */
        paginateIndex(page) {
            this.pagination.page = page
            this.getSlas()
        },
        /**
        * @description This action is used to update SLA information
        */
        updateSla(){
            this.loading = true
            this.http.put(this.url.help('slas/:id', this.sla.id), {
                sla: this.sla
            }).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.loading = false
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))

            })
        },
        /**
        * @description This action is used to get associaiton options
        */
        getAssociationsOptions () {
            this.loading = true
            this.http.get(this.url.help('slas/associations/options')).then(result => {
                this.associationOptions = result.ticket_types
                this.loading = false
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })

        },
        /**
        * @description This action is used to post a new association
        * @param {Object} type The type that is going to be associated to the sla
        */
        postAssociation(type){
            let url = this.url.help(`slas/:sla_id/associations`, {sla_id: this.sla.id})
            let data = {
                sla_association: {
                    cloud_help_catalog_ticket_types_id: type.id
                }
            }
            this.http.post(url, data).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.associations.push(result)
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        /**
        * @description This action is used to delete an association
        * @param {String} association_id The id of the association that is being deleted
        */
        deleteAssociation(type_id){
            let association_deleted = this.associations.find( type =>
                type_id == type.cloud_help_catalog_ticket_types_id
            )

            let url = this.url.help(`slas/:sla_id/associations/:id`, {sla_id: this.sla.id, id: association_deleted.id})
            this.http.delete(url).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.associations = this.associations.filter((association) =>{
                    return association.id !== association_deleted.id
                })
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
        * @description This action is used to get the associations for a sla
        */
        getAssociations(){
            this.loading = true
            let url = this.url.help(`slas/:sla_id/associations`, {sla_id: this.sla.id})
            this.http.get(url).then(result => {
                this.associations = result
                this.markAssociation()
                this.loading = false
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        /**
        * @description This action is used to mark association for a sla
        */
        markAssociation(){
            this.associations.forEach((association)=>{
                const type = this.associationOptions.find((type)=>{
                    return association.cloud_help_catalog_ticket_types_id == type.id
                })
                type['checked'] = true
            })
        }

    }
})

