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
import { onMounted } from "vue"

// · import lesli stores
import { useHistory } from "CloudHelp/stores/tickets/history"

// · import vue router composable
import { useRoute } from "vue-router"

// · implement stores
const storeHistories = useHistory()

// · initialize/inject plugins
const route = useRoute()

// · 
const translations = {
    shared: I18n.t("core.shared"),
    histories: I18n.t('help.ticket/histories')
}

const columns = [{
    field: "created_at",
    label: "Created at",
}, {
    field: "user_creator_name",
    label: "Creator",
}, {
    field: "content",
    label: "Comment"
}]

onMounted(() => {
    storeHistories.getHistories(route.params.id)
})


</script>
<template>

    <h2>{{translations.histories.view_title_main}}</h2>
    <lesli-table 
        :records="storeHistories.histories"
        :columns="columns"
    >
        <template #options="{ record, value }">
            <a class="dropdown-item" >
                <span class="material-icons">
                    delete
                </span>
                <span>
                    Delete
                </span>
            </a>
        </template>
    </lesli-table>

</template>
