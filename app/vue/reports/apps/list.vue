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

            ticket_options: {},

            filters: {
                tickets: {
                    start_date: this.date.todayAtMidnight(),
                    end_date: this.date.todayAtMidnight(),
                    user_assigned_id: null,
                    user_name: '',
                    workspace_id: null
                }
            },
            date_selection_shortcut: null,
            users: [],
            ticket_reports: []
        }
    },

    mounted(){
        this.getUsers()
        this.initializeReportsTable()
        this.getTicketOptions()
    },

    methods: {
        getUsers(){
            let url = this.url.help('tickets/assignments/options')

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.users = result.data
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getTicketOptions(){
            let url = this.url.help('tickets/options').filters({include: 'statuses'})

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.ticket_options = result.data
                    this.getFilteredStatuses('')
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getFilteredStatuses(text){
            text = text.toLowerCase()
            this.filtered_statuses = this.ticket_options.statuses.filter((status) => {
                return status.text.toLowerCase().includes(text)
            })
        },

        initializeReportsTable(){
            this.ticket_reports = [{
                name: this.translations.main.view_text_report_tickets_general
            },{
                name: this.translations.main.view_text_report_tickets_open
            },{
                name: this.translations.main.view_text_report_tickets_overdue
            }]
        },

        reportLink(report, format){
            switch(report.name){
                case this.translations.main.view_text_report_tickets_general:
                    return  `/help/reports/tickets_general.${format}?${this.generalQueryFilters}`
                case this.translations.main.view_text_report_tickets_open:
                    return `/help/reports/tickets_general.${format}?${this.openQueryFilters}`
                case this.translations.main.view_text_report_tickets_overdue:
                    return `/help/reports/tickets_general.${format}?${this.overdueQueryFilters}`
            }
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
    },
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
                                <b-field :label="translations.tickets.column_cloud_help_catalog_ticket_workspaces_id">
                                    <b-select expanded v-model="filters.tickets.workspace_id">
                                        <option :value="null">{{translations.tickets.view_text_filter_all_workspaces}}</option>
                                        <option v-for="workspace in ticket_options.workspaces" :key="workspace.id" :value="workspace.id">
                                            {{workspace.name}}
                                        </option>
                                    </b-select>
                                </b-field>
                            </div>
                            <div class="column is-8"></div>
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
                            <hr>
                            <div class="column is-6 is-offset-3">
                                <b-table :data="ticket_reports">
                                    <template v-slot="props">
                                        <b-table-column field="name" :label="translations.main.view_table_header_report">
                                            {{props.row.name}}
                                        </b-table-column>

                                        <b-table-column field="xlsxl" :label="translations.main.view_table_header_xlsx_file">
                                            <a :href="reportLink(props.row, 'xlsx')" class="button is-outlined is-small">
                                                <span>{{translations.main.view_btn_download}}</span>
                                                <b-icon size="is-small" type="is-success" icon="file-excel"></b-icon>
                                            </a>
                                        </b-table-column>

                                        <b-table-column field="name" :label="translations.main.view_table_header_pdf_file">
                                            <a :href="reportLink(props.row, 'pdf')" class="button is-outlined is-small">
                                                <span>{{translations.main.view_btn_download}}</span>
                                                <b-icon size="is-small" type="is-danger" icon="file-pdf"></b-icon>
                                            </a>
                                        </b-table-column>
                                    </template>
                                </b-table>
                            </div>
                        </div>
                    </b-tab-item>
                </b-tabs>
            </div>
        </div>
    </section>
</template>
