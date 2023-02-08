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
    },
    ticket_types: I18n.t('help.catalog/ticket_types')
}

// · initializing
onMounted(() => {
    storeSla.getAssociations()
})

const columns = [{
    field: "id",
    label: translations.ticket_types.column_id
}, {
    field: "name",
    label: translations.ticket_types.column_name,
}, {
    field: "associate",
    label: ""
}]


/**
 * @description This action is used to verify if a type of ticket is associated
 * @param {Object} type The type to be checked
 */
 function submitAssociation(type){
    if(!type.checked){
        storeSla.postAssociation(type)
    }else{
        storeSla.deleteAssociation(type.id)
    }
}


</script>
<template>
    <lesli-table 
        :records="storeSla.associationOptions"
        :columns="columns"
    >
        <template #associate="{ record }">
            <input type="checkbox" v-model="record.checked" @input="submitAssociation(record)">
        </template>
    </lesli-table>
</template>
