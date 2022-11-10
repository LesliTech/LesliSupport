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
export const useReports = defineStore("help.report", {
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
            user: "",
            user_options: {},
            query_filters: [],
            date_select_shortcut: null,
            filters: {
                user_assigned_id: null,
                end_date: null,
                start_date: null,
            }
        }
    },
    actions: {
        getUsers(){

            this.http.get(this.url.help('tickets/assignments/options')).then(result => {
                this.user_options = result
            }).catch(error => {
                console.log(error)
            })
        },

        updateFilters(){
            let query_filters = []

            for(let key in this.filters.tickets){
                if(this.filters.tickets[key]){
                    if(this.filters.tickets[key] instanceof Date){
                        query_filters.push(`filters[${key}]=${this.filters.tickets[key].toISOString()}`)
                    }else{
                        query_filters.push(`filters[${key}]=${this.filters.tickets[key]}`)
                    }
                }
            }
        }

    }
})

