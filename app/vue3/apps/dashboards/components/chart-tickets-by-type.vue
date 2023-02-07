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

const loading = ref(true)
const result = ref([])


// · 
import layoutDashboardComponent from "LesliVue/layout/dashboard-component.vue"
import componentChartBar from "LesliVue/components/charts/bar.vue"


// · 
const props = defineProps({
    component: {
        type: Object, 
        require: true
    }
})


const translations = {
    dashboards: I18n.t('help.dashboard/components')
}



// · 
onMounted(() => {
    http.get(url.help("dashboards/:dashboard/components/:component", {
        dashboard: props.component.cloud_help_dashboards_id,
        component: props.component.id,
        view: "data"
    })).then(resultado => {
        result.value = []
        resultado.forEach(t => {
            result.value.push({
                x: t.type_name,
                y: t.tickets_count
            })
        })
    }).finally(() => {
        loading.value = false
    })
})

</script>
<template>
    <layout-dashboard-component :title="translations.dashboards.view_title_tickets_by_type">
        <component-chart-bar :series="result">
        </component-chart-bar>
    </layout-dashboard-component>
</template>
