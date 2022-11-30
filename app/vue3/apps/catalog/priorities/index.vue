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
    field: "created_at_string",
    label: translations.main.column_created_at,
    sort: true
}]

</script>
<template>
    <section class="application-component">
        <lesli-header :title="translations.main.view_title_main">
            <lesli-button @click="storePriorities.reloadPriorities" icon="refresh" :loading="storePriorities.loading">
                {{ translations.core.view_text_btn_reload }} 
            </lesli-button>
            <lesli-button :to="url.help('catalog/ticket_priorities'+`/new`)" icon="add">
                {{ translations.core.view_btn_add }}
            </lesli-button>
        </lesli-header>

        <lesli-toolbar @search="storePriorities.search" :placeholder="translations.main.view_placeholder_text_filter">
            <lesli-select
                :options="[
                    {
                        label: '10',
                        value: 10
                    }, {
                        label: '15',
                        value: 15
                    }, {
                        label: '30',
                        value: 30
                    }, {
                        label: '50',
                        value: 50
                    },
                ]"
                v-model="storePriorities.filters.per_page"
                @change="storePriorities.getPriorities()"
            >
            </lesli-select>
        </lesli-toolbar>
        
        <lesli-table 
            :records="storePriorities.index.records"
            :columns="columns"
            :loading="storePriorities.loading"
            :pagination="storePriorities.index.pagination"
            @paginate="storePriorities.paginateIndex"
            @sort="storePriorities.sort"
            :link="(priority) => url.help(`catalog/ticket_priorities/${priority.id}`).s"
        >
            <template #days_to_deadline="{value}">
                <p v-if="value">
                    {{value}}
                </p>
                <p v-else>
                    N/A
                </p>
            </template>
        
        </lesli-table>

    </section>

</template>
