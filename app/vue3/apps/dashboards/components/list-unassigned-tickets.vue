<script setup>
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


// · import vue tools
import { onMounted, inject, ref } from "vue"


// · 
const http = inject("http")
const url = inject("url")
const result = ref([])


// · 
import layoutDashboardComponent from "LesliVue/layout/dashboard-component.vue"


// · 
const props = defineProps({
    component: {
        type: Object, 
        require: true
    }
})

const loading = ref(true)

const translations = {
    core: I18n.t('core.shared'),
    main: I18n.t('help.dashboard/components'),
    tickets: I18n.t('help.tickets')
}

const columns = [{
    field: 'subject',
    label: translations.tickets.column_subject, 
    sort: true
}, {
    field: 'deadline',
    label: translations.tickets.column_deadline, 
    sort: true
}, {
    field: 'status_name',
    label: translations.tickets.column_cloud_help_workflow_statuses_id, 
    sort: true
}]

onMounted(() => {
    http.get(url.help("dashboards/:dashboard/components/:component", {
        dashboard: props.component.cloud_help_dashboards_id,
        component: props.component.id,
        view: "data"
    })).then(resultado => {
        result.value = resultado
    }).finally(() => {
        loading.value = false
    })
})
</script>
<template>
    <layout-dashboard-component :title="translations.main.view_title_unassigned_tickets">
        <lesli-table
            :href="(ticket) => ticket.url"
            :loading="loading"
            :columns="columns"
            :records="result">
        </lesli-table>
    </layout-dashboard-component>
</template>
