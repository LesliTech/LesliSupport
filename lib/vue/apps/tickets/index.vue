<script setup>
/*
Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · import vue tools
import { onMounted, inject } from "vue"
import { useRouter } from "vue-router"


// · import lesli stores
import { useTickets } from "LesliSupport/vue/stores/tickets"
import { useLesliMsg } from "/Users/ldonis/code/Lesli/lesli-vue/source/composables/msg/msg.js"

const msg = useLesliMsg()

// · initialize/inject plugins
const router = useRouter()
const date = inject("date")
const url = inject("url")


// · implement stores
const storeTickets = useTickets()


// · translations
const translations = {
    tickets: i18n.t("lesli_support.tickets"),
    lesli: i18n.t("lesli")
}


// ·
const columns = [{
    field: "id",
    label: translations.tickets.column_id,
    sort: true
}, {
    field: "subject",
    label: translations.tickets.column_subject,
    sort: true
}, {
    field: "deadline",
    label: translations.tickets.column_deadline,
    sort: true
}, {
    field: "status_name",
    label: translations.tickets.column_status,
    align: "center",
    sort: true
},{
    field: "priority_name",
    label: translations.tickets.column_priority,
    align: "center",
    sort: true
}, {
    field: "user_name",
    label: translations.tickets.column_creator,
    sort: true
}]


// · initializing
onMounted(() => {
    storeTickets.getTickets()
})
</script>
<template>
    <lesli-application-container>
        <lesli-header title="Tickets">
            <lesli-button @click="storeTickets.reloadTickets" icon="refresh" :loading="storeTickets.loading">
                {{ translations.lesli.shared.button_reload }}
            </lesli-button>
            <lesli-link button solid :to="url.support('tickets/new')" icon="add">
                {{ translations.lesli.shared.button_add_new }}
            </lesli-link>
        </lesli-header>
        <lesli-toolbar 
            @search="storeTickets.search" 
            :placeholder="translations.lesli.shared.toolbar_search">
            <lesli-select
                :options="[{
                    label: translations.tickets.view_all_tickets,
                    value: null
                }, {
                    label: translations.tickets.view_own_tickets,
                    value: 'own'
                }]"
                v-model="storeTickets.filters.user_type"
                @change="storeTickets.getTickets()">
            </lesli-select>
            <lesli-select
                :options="[{
                    label: translations.tickets.view_all_tickets,
                    value: null
                }, {
                    label: translations.tickets.view_active_tickets,
                    value: 'active'
                }, {
                    label: translations.tickets.view_inactive_tickets,
                    value: 'inactive'
                }]"
                v-model="storeTickets.filters.search_type"
                @change="storeTickets.getTickets()">
            </lesli-select>
        </lesli-toolbar>

        <lesli-table 
            :columns="columns"
            :records="storeTickets.index.records" 
            :loading="storeTickets.index.loading"
            :pagination="storeTickets.index.pagination"
            :link="(ticket) => url.support('tickets/:id', ticket.id)">
        </lesli-table>
    </lesli-application-container>
</template>
