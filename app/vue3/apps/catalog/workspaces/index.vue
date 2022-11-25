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
import { useTicketWorkspaces } from "CloudHelp/stores/catalog/workspaces"

// · initialize/inject plugins
const router = useRouter()
const url = inject("url")
const date = inject("date")

// · implement stores
const storeWorkspaces = useTicketWorkspaces()

//·
const translations = {
    main: I18n.t('help.catalog/ticket_workspaces'),
    core: I18n.t('core.shared')
}

// · initializing
onMounted(() => {
    storeWorkspaces.getWorkspaces()
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
    field: "created_at_date",
    label: translations.main.column_created_at,
    sort: true
}]

</script>
<template>
    <section class="application-component">
        <lesli-header :title="translations.main.view_title_main">
            <lesli-button :to="url.help('catalog/ticket_workspaces/new')" icon="add">
                {{ translations.core.view_btn_add }}
            </lesli-button>
        </lesli-header>
        
        <lesli-table 
            :records="storeWorkspaces.workspaces"
            :columns="columns"
            :loading="storeWorkspaces.loading"
            :pagination="storeWorkspaces.index.pagination"
            @paginate="storeWorkspaces.paginateIndex"
            @sort="storeWorkspaces.sort"
            :link="(workspace) => url.help(`catalog/ticket_workspaces/${workspace.id}`).s"
        >
            <template #name="{ value, record }">


                <p  v-if="record.default===true">
                    <span class="icon-text">
                        <span class="icon">
                            <span class="has-text-success material-icons">
                                check_box_icon
                            </span>
                        </span>
                        <span>
                            {{value + ` (Default workspace)`}}
                        </span>
                    </span>
                </p>

                <p v-else>
                    {{value}}
                </p>
            </template>        
        </lesli-table>

    </section>

</template>
