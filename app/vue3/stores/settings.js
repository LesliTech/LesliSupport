/*
Copyright (c) 2023, all rights reserved.

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
export const useSettings = defineStore("help.account.settings", {
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
            settings : {
                role_assignment: null 
            },
            options : {}
        }
    },
    actions: {
        /**
        * @description This action is used to get the options for the settings
        */
        getOptions(){
            this.loading = true

            this.http.get(this.url.help('settings/options')).then(result => {
                this.options = result.roles
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },
        /**
        * @description This action is used to get the actual values for the account settings
        */
        getSettings(){
            this.loading = true
            this.http.get(this.url.help('settings')).then(result => {
                result.forEach((setting)=>{
                    if (setting.key === "tickets_assignments_role"){
                        this.settings.role_assignment = setting.value
                    }
                })
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        },
        /**
        * @description This action is used to get the actual values for the account settings
        */
        postSettings() {
            this.loading = true
            this.http.post(this.url.help('settings'), { 
                settings: {  
                    key: "tickets_assignments_role", 
                    value: this.settings.role_assignment 
                }
            }).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }).finally(() => {
                this.loading = false
            })
        }
        

    }
})

