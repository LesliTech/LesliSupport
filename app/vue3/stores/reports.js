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
        /**
         * @description This action is used to get users for autocomplete selection
        */
        getUsers(){
            this.http.get(this.url.help('tickets/assignments/options')).then(result => {
                this.user_options = result
            }).catch(error => {
                console.log(error)
            })
        },
        /**
         * @description This action is used to join all filters for a report
        */
        updateFilters(){
            const query_filters = []
            for(let key in this.filters){
                if(this.filters[key]){
                    if(this.filters[key] instanceof Date){
                        query_filters.push(`filters[${key}]=${this.filters[key].toISOString()}`)
                    }else{
                        query_filters.push(`filters[${key}]=${this.filters[key]}`)
                    }
                }
            }
            return query_filters
        },
        /**
         * @description This action is used to set filters for all tickets
        */
        generalQueryFilters(){
            return this.updateFilters().join('&')
        },
        /**
         * @description This action is used to set filters for open tickets
        */
        openQueryFilters(){
            const query_filters = this.updateFilters()
            query_filters.push('filters[open]=true')

            return query_filters.join('&')
        },
        /**
         * @description This action is used to set filters tickets with past deadlines
        */
        overdueQueryFilters(){
            const query_filters = this.updateFilters()
            query_filters.push('filters[overdue]=true')

            return query_filters.join('&')
        }

    }
})

