<script>
/*
Copyright (c) 2021, all rights reserved.

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


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import DatePicker from 'v-calendar/lib/components/date-picker.umd'
import componentUserAutocomplete from 'LesliVue/components/forms/users-autocomplete.vue'

export default {
    components: {
        'vc-date-picker': DatePicker,
        'component-users-autocomplete': componentUserAutocomplete
    },

    data(){
        return {
            translations: {
                core: I18n.t('core.shared'),
                main: I18n.t('help.reports'),
                tickets: I18n.t('help.tickets')
            },

            filters: {
                tickets: {
                    start_date: this.date.todayAtMidnight(),
                    end_date: this.date.todayAtMidnight(),
                    user_assigned_id: null,
                    user_name: ''
                }
            },
            date_selection_shortcut: null,
            support_role: 'support',
            users: []
        }
    },

    mounted(){
        this.getUsers()
    },

    methods: {
        getUsers(){
            this.http.get(`/administration/users/list.json?role=${this.support_role}`).then(result => {
                if (result.successful) {
                    this.users = result.data
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        selectUser(user){
            if(user){
                this.filters.tickets.user_assigned_id = user.id
            }else{
                this.filters.tickets.user_assigned_id = null
            }
        },

        setManualDateRange(){
            this.date_selection_shortcut = null
        },

        calculateQueryFilters(){
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

            return query_filters
        }
    },

    watch: {
        date_selection_shortcut(){
            if(this.date_selection_shortcut){
                switch(this.date_selection_shortcut){
                    case 'daily':
                        this.filters.tickets.start_date = this.date.todayAtMidnight()
                        this.filters.tickets.end_date = this.date.todayAtMidnight()
                        break
                    case 'monthly':
                        this.filters.tickets.start_date = this.date.beginningOfMonth()
                        this.filters.tickets.end_date = this.date.endOfMonth()
                        break
                    case 'weekly':
                        this.filters.tickets.start_date = this.date.beginningOfWeek(lesli.settings.datetime.start_week_on)
                        this.filters.tickets.end_date = this.date.endOfWeek(lesli.settings.datetime.start_week_on)
                        break
                    case 'clear':
                        this.filters.tickets.start_date = null
                        this.filters.tickets.end_date = null
                        break
                }
            }
        }
    },

    computed: {
        filteredUsers(){
            return this.users.filter((user) => {
                return (user.name || '').toLowerCase().includes((this.filters.tickets.user_name || '').toLowerCase())
            })
        },

        generalQueryFilters(){
            return this.calculateQueryFilters().join('&')
        },

        openQueryFilters(){
            let query_filters = this.calculateQueryFilters()
            query_filters.push('filters[open]=true')

            return query_filters.join('&')
        },

        overdueQueryFilters(){
            let query_filters = this.calculateQueryFilters()
            query_filters.push('filters[overdue]=true')

            return query_filters.join('&')
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="translations.main.view_title_reports">
        </component-header>


        <div class="card">
            <div class="card-content">
                <b-tabs>
                    <b-tab-item :label="translations.tickets.view_title_main">
                        <div class="columns is-multiline">
                            <div class="column is-4">
                                <b-field
                                    :label="translations.tickets.column_user_main_id"
                                    :message="translations.main.view_text_column_ticket_user_main_id_description"
                                >
                                    <b-autocomplete
                                        :placeholder="translations.core.view_placeholder_select_option"
                                        v-model="filters.tickets.user_name"
                                        keep-first
                                        field="name"
                                        @select="selectUser"
                                        :data="filteredUsers"
                                    >
                                    </b-autocomplete>
                                </b-field>
                            </div>
                            <div class="column is-2">
                                <b-field :label="translations.main.view_input_date_range">
                                    <b-select expanded v-model="date_selection_shortcut">
                                        <option :value="null">
                                            {{translations.main.column_enum_date_selection_shortcut_manual}}
                                        </option>
                                        <option value="daily">
                                            {{translations.main.column_enum_date_selection_shortcut_daily}}
                                        </option>
                                        <option value="weekly">
                                            {{translations.main.column_enum_date_selection_shortcut_weekly}}
                                        </option>
                                        <option value="monthly">
                                            {{translations.main.column_enum_date_selection_shortcut_monthly}}
                                        </option>
                                        <option value="clear">
                                            {{translations.main.column_enum_date_selection_shortcut_clear}}
                                        </option>
                                    </b-select>
                                </b-field>
                            </div>
                            <div class="column is-3">
                                <b-field :message="translations.main.view_text_tickets_date_range_required_only_in_general">
                                    <template v-slot:label>
                                        {{translations.main.view_input_start_date}}
                                    </template>
                                    <vc-date-picker
                                        v-model="filters.tickets.start_date"
                                        :locale="date.vcDatepickerConfig()"
                                        :popover="{ visibility: 'focus' }"
                                        @input="setManualDateRange"
                                    >
                                        <template v-slot="{ inputValue, inputEvents }">
                                            <input
                                                class="input is-default"
                                                v-on="inputEvents"
                                                :value="inputValue"
                                                :placeholder="translations.core.view_text_select_date"
                                            />
                                        </template>
                                    </vc-date-picker>
                                </b-field>
                            </div>
                            <div class="column is-3">
                                <b-field>
                                    <template v-slot:label>
                                        {{translations.main.view_input_end_date}}
                                    </template>
                                    <vc-date-picker
                                        v-model="filters.tickets.end_date"
                                        :locale="date.vcDatepickerConfig()"
                                        :popover="{ visibility: 'focus' }"
                                        @input="setManualDateRange"
                                    >
                                        <template v-slot="{ inputValue, inputEvents }">
                                            <input
                                                class="input is-default"
                                                v-on="inputEvents"
                                                :value="inputValue"
                                                :placeholder="translations.core.view_text_select_date"
                                            />
                                        </template>
                                    </vc-date-picker>
                                </b-field>
                            </div>
                            <div class="column is-12">
                                <div class="buttons">
                                    <a
                                        v-if="filters.tickets.start_date && filters.tickets.end_date"
                                        class="button is-info is-light has-text-dark"
                                        :href="`/help/reports/tickets_general.xlsx?${generalQueryFilters}`"
                                        target="_blank"
                                    >
                                        <b-icon icon="file-download"></b-icon>
                                        <span >{{translations.main.view_text_report_tickets_general}}</span>
                                    </a>
                                    <button v-else disabled class="button is-info is-light has-text-dark" >
                                        <b-icon icon="file-download"></b-icon>
                                        <span >{{translations.main.view_text_report_tickets_general}}</span>
                                    </button>

                                    <a
                                        class="button is-info is-light has-text-dark"
                                        :href="`/help/reports/tickets_general.xlsx?${openQueryFilters}`"
                                        target="_blank"
                                    >
                                        <b-icon icon="file-download"></b-icon>
                                        <span >{{translations.main.view_text_report_tickets_open}}</span>
                                    </a>
                                    <a
                                        class="button is-info is-light has-text-dark"
                                        :href="`/help/reports/tickets_general.xlsx?${overdueQueryFilters}`"
                                        target="_blank"
                                    >
                                        <b-icon icon="file-download"></b-icon>
                                        <span >{{translations.main.view_text_report_tickets_overdue}}</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </b-tab-item>
                </b-tabs>
            </div>
        </div>
    </section>
</template>
