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
import { useTickets } from "CloudHelp/stores/tickets/tickets"

// · initialize/inject plugins
const router = useRouter()
const url = inject("url")

// · implement stores
const storeTickets = useTickets()

//·
const translations = {
    main: I18n.t('help.tickets'),
    core: {
        shared: I18n.t('core.shared')
    }
}

// · defining props
const props = defineProps({
    appMountPath: {
        type: String,
        required: false,
        default: "help/tickets",
    }
})

// · initializing
onMounted(() => {
    storeTickets.getTickets()
    storeTickets.getOptions()
})

const columns = [{
    field: "id",
    label: translations.main.column_id,
    sort: true
}, {
    field: "subject",
    label: translations.main.column_subject,
    sort: true
}, {
    field: "workspace",
    label: translations.main.column_cloud_help_catalog_ticket_workspaces_id
}, {
    field: "deadline_text",
    label: translations.main.column_deadline
}, {
    field: "status_name",
    label: translations.main.column_cloud_help_workflow_statuses_id,
    sort: true
}, {
    field: "type",
    label: translations.main.column_cloud_help_catalog_ticket_types_id
}, {
    field: "category",
    label: translations.main.column_cloud_help_catalog_ticket_categories_id
}, {
    field: "priority",
    label: translations.main.column_cloud_help_catalog_ticket_priorities_id
}, {
    field: "user_creator",
    label: translations.main.column_users_id
}, {
    field: "assignables",
    label: translations.main.column_user_main_id
}]

function showTicket(ticket) {
    router.push(url.root(props.appMountPath +`/${ticket.id}`).s)
}


function extractInitials(name){
    return name.split(" ").map((word)=>{
        if(word){
            return word[0].toUpperCase()
        }else{
            return ''
        }
    }).join("")
}


</script>
<template>
    <section class="application-component">

        <lesli-header :title="translations.main.view_title_main">
            <lesli-button :to="url.root(props.appMountPath+`/new`)" icon="add">
                {{ translations.core.shared.view_btn_add }}
            </lesli-button>
            <lesli-button @click="storeTickets.reloadTickets" icon="refresh">
                {{ translations.core.shared.view_text_btn_reload }} 
            </lesli-button>
        </lesli-header>

        <lesli-toolbar @search="storeTickets.search" :placeholder="translations.main.view_placeholder_text_filter">
            <lesli-select
                :options="[
                    {
                        label: translations.main.view_text_filter_everyones_tickets,
                        value: null
                    },
                    {
                        label: translations.main.view_text_filter_own_tickets,
                        value: 'own'
                    }
                ]"
                v-model="storeTickets.filters.user_type"
                @change="storeTickets.getTickets()"
            >
            </lesli-select>
            <lesli-select
                :options="[
                    {
                        label: translations.main.view_text_filter_all_tickets,
                        value: null
                    }, {
                        label: translations.main.view_text_filter_active_tickets,
                        value: 'active'
                    }, {
                        label: translations.main.view_text_filter_inactive_tickets,
                        value: 'inactive'
                    },
                ]"
                v-model="storeTickets.filters.search_type"
                @change="storeTickets.getTickets()"
            >
            </lesli-select>
        </lesli-toolbar>

        <lesli-table 
            :records="storeTickets.tickets"
            :columns="columns"
            :loading="storeTickets.loading"
            :pagination="storeTickets.index.pagination"
            @paginate="storeTickets.paginateIndex"
            @sort="storeTickets.sort"
            @click="showTicket"
        >
            <template #assignables="{ column, value }">
                <span
                    v-for="user in value"
                    :key="user"
                    class="tag is-success is-small is-rounded mr-1"
                >
                    {{ extractInitials(user) }}
                </span>

            </template>

        </lesli-table>

    </section>
</template>
