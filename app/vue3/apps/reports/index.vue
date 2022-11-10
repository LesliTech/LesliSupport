<script setup>
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


// · import vue tools
import { onMounted, inject, watch } from "vue"
import { useRouter } from 'vue-router'

import dayjs from "dayjs"

// · import lesli stores
import { useReports } from "CloudHelp/stores/reports"

// · initialize/inject plugins
const router = useRouter()
const url = inject("url")
const date = inject("date")

// · implement stores
const storeReports = useReports()

//·
const translations = {
    core: I18n.t('core.shared'),
    main: I18n.t('help.reports'),
    tickets: I18n.t('help.tickets')
}

// · initializing
onMounted(() => {
    storeReports.getUsers()

})


const columns = [{
    field: "name",
    label: "name"
}, {
    field: "excel",
    label: "Excel",
}, {
    field: "pdf",
    label: "pdf"
}]

const ticket_reports = [
    {
        name: translations.main.view_text_report_tickets_general
    },{
        name: translations.main.view_text_report_tickets_open
    },{
        name: translations.main.view_text_report_tickets_overdue
    }
]


/**
 * @description This function is used to generate the link to download the report
 * @param {Object} report the name of the report
 * @param {String} format the format of the report
*/
function reportLink(report, format){
    switch(report.name){
        case translations.main.view_text_report_tickets_general:
            return  `/help/reports/tickets_general.${format}?${storeReports.generalQueryFilters()}`
        case translations.main.view_text_report_tickets_open:
            return `/help/reports/tickets_general.${format}?${storeReports.openQueryFilters()}`
        case translations.main.view_text_report_tickets_overdue:
            return `/help/reports/tickets_general.${format}?${storeReports.overdueQueryFilters()}`
    }
}

/**
 * Set user id to filters when selecting a user in autocomplete
*/
function selectUser(){
    if (storeReports.user){
        storeReports.filters.user_assigned_id = storeReports.user.id
    }
}

/**
 * Set date based on the selected option
*/
watch(() => storeReports.date_select_shortcut, () => {
    if(storeReports.date_select_shortcut){
        switch(storeReports.date_select_shortcut){
            case 'daily':
                storeReports.filters.end_date = dayjs().startOf('day').format('YYYY-MM-DD')
                break
            case 'monthly':
                storeReports.filters.start_date = dayjs().startOf('month').format('YYYY-MM-DD')
                storeReports.filters.end_date = dayjs().endOf('month').format('YYYY-MM-DD')
                break
            case 'weekly':
                storeReports.filters.start_date = dayjs().startOf('week').format('YYYY-MM-DD')
                storeReports.filters.end_date = dayjs().endOf('week').format('YYYY-MM-DD')
                break
            case 'clear':
                storeReports.filters.start_date = null
                storeReports.filters.end_date = null
                break
        }
    }
})



</script>
<template>
    <section class="application-component">
        <lesli-header :title="translations.main.view_title_reports">
        </lesli-header>

        <h6>{{translations.tickets.view_title_main}}</h6>

        <div class="columns">

            <div class="column is-3">
                <label class="label">
                    {{translations.tickets.column_user_main_id}}
                </label>
                <div class="control">
                    <lesli-autocomplete
                        v-model="storeReports.user"
                        :placeholder="translations.core.view_placeholder_select_option"
                        :options="storeReports.user_options"
                        :selectBy="option => option.name"
                        @select="selectUser()"
                        >
                    </lesli-autocomplete>
                </div>
            </div>

            <div class="column is-3">
                <label class="label">
                    {{translations.main.view_input_date_range}} 
                </label>
                <div class="control">
                    <lesli-select
                        v-model="storeReports.date_select_shortcut"
                        :options="[
                            {
                                label: translations.main.column_enum_date_selection_shortcut_daily,
                                value: 'daily',
                            },
                            {
                                label: translations.main.column_enum_date_selection_shortcut_weekly,
                                value: 'weekly',
                            },
                            {
                                label: translations.main.column_enum_date_selection_shortcut_monthly,
                                value: 'monthly',
                            }
                        ]"  
                    ></lesli-select>
                </div>
            </div>

            <div class="column is-3">
                <label class="label">
                    {{translations.main.view_input_start_date}}
                </label>
                <div class="control">
                    <input class="input" type="date" v-model="storeReports.filters.start_date">
                </div>
            </div>

            <div class="column is-3">
                <label class="label">
                    {{translations.main.view_input_end_date}}
                </label>
                <div class="control">
                    <input class="input" type="date" v-model="storeReports.filters.end_date">
                </div>
            </div>
        </div>

        <lesli-table 
            :records="ticket_reports"
            :columns="columns"
        >
            <template #excel="{ record }">
                <a :href="reportLink(record, 'xlsx')" class="button is-outlined is-small">
                    <span>{{translations.main.view_btn_download}}</span>
                </a>
            </template>

            <template #pdf="{ record }">
                <a :href="reportLink(record, 'pdf')" class="button is-outlined is-small">
                    <span>{{translations.main.view_btn_download}}</span>
                </a>
            </template>
        </lesli-table>

    </section>

</template>
