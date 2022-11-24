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
import { useTicketTypes } from "CloudHelp/stores/catalog/types"

// · initialize/inject plugins
const router = useRouter()
const url = inject("url")
const date = inject("date")

// · implement stores
const storeTypes = useTicketTypes()

//·
const translations = {
    main: I18n.t('help.catalog/ticket_types'),
    core: I18n.t('core.shared')
}

// · initializing
onMounted(() => {
    storeTypes.getTypes()
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
    field: "created_at",
    label: translations.main.column_created_at
}]

</script>
<template>
    <section class="application-component">
        <lesli-header :title="translations.main.view_title_main">
            <lesli-button :to="url.help('catalog/ticket_types/new')" icon="add">
                {{ translations.core.view_btn_add }}
            </lesli-button>
        </lesli-header>
        
        <lesli-table 
            :records="storeTypes.types"
            :columns="columns"
            :loading="storeTypes.loading"
            :pagination="storeTypes.index.pagination"
            @paginate="storeTypes.paginateIndex"
            @sort="storeTypes.sort"
            :link="(type) => url.help(`catalog/ticket_types/${type.id}`).s"
        >
        
        </lesli-table>

    </section>

</template>
