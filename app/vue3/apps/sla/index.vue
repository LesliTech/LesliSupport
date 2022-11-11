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
import { useSlas } from "CloudHelp/stores/sla"

// · initialize/inject plugins
const router = useRouter()

// · implement stores
const storeSla = useSlas()

//·
const translations = {
    sla: I18n.t('help.slas'),
    core: {
        shared: I18n.t('core.shared')
    }
}

// · initializing
onMounted(() => {
    storeSla.getSlas()
})

const columns = [{
    field: "id",
    label: "ID"
}, {
    field: "name",
    label: "Name",
}, {
    field: "default",
    label: "Default"
}, {
    field: "status",
    label: "Status",
}, {
    field: "expected_response_time",
    label: "Response Time (Hrs)",
}, {
    field: "expected_resolution_time",
    label: "Resolution Time (Hrs)"
}]

</script>
<template>
    <section class="application-component">

        <lesli-header :title="translations.sla.view_title_main">
            <lesli-button :to="url.help('slas/new')" icon="add">
                {{ translations.core.shared.view_btn_add }}
            </lesli-button>
        </lesli-header>

        <lesli-table 
            :records="storeSla.slas"
            :columns="columns"
            :link="(sla) => url.help(`slas/${sla.id}`).s"
            :pagination="storeSla.index.pagination"
            @paginate="storeSla.paginateIndex"
        >
        </lesli-table>

    </section>
</template>
