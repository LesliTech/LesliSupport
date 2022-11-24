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
import { onMounted, inject } from "vue"
import { useRouter } from 'vue-router'


// · import lesli stores
import { useTicketPriorities } from "CloudHelp/stores/catalog/priorities"

// · initialize/inject plugins
const router = useRouter()
const url = inject("url")
const date = inject("date")

// · implement stores
const storePriorities = useTicketPriorities()

//·
const translations = {
    main: I18n.t('help.catalog/ticket_priorities'),
    core: I18n.t('core.shared')
}

// · initializing
onMounted(() => {
    storePriorities.getPriorities()
})

const columns = [{
    field: "id",
    label: translations.main.column_id,
    sort: true
}, {
    field: "name",
    label: translations.main.column_name,
    sort: true
}, {
    field: "weight",
    label: translations.main.column_weight,
    sort: true
}, {
    field: "days_to_deadline",
    label: translations.main.column_days_to_deadline,
    sort: true
}, {
    field: "created_at",
    label: translations.main.column_created_at
}]

</script>
<template>
    <section class="application-component">
        <lesli-header :title="translations.main.view_title_main">
            <lesli-button :to="url.help('catalog/ticket_priorities'+`/new`)" icon="add">
                {{ translations.core.view_btn_add }}
            </lesli-button>
        </lesli-header>
        
        <lesli-table 
            :records="storePriorities.priorities"
            :columns="columns"
            :loading="storePriorities.loading"
            :pagination="storePriorities.index.pagination"
            @paginate="storePriorities.paginateIndex"
            @sort="storePriorities.sort"
            :link="(priority) => url.help(`catalog/ticket_priorities/${priority.id}`).s"
        >
        
        </lesli-table>

    </section>

</template>
