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
        }
    },
    actions: {
        getSlas(){
            this.loading = true
            this.http.get(this.url.help('slas').paginate(this.pagination.page)).then(result => {
                this.loading = false
                this.slas = result
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        postSla(){
            this.loading = true
            this.http.post(this.url.help('slas'), {
                sla: this.sla
            }).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                this.loading = false
            }).catch(error => {
                console.log(error)
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },
        fetchSla(id){
            this.sla = {}
            this.http.get(this.url.help('slas/:id', id)).then(result => {
                this.sla = result
            }).catch(error => {
                console.log(error)
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

    }
})

