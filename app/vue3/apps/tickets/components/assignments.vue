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
import { useAssignments } from "CloudHelp/stores/tickets/assignment"

// · import vue router composable
import { useRoute } from "vue-router"

// · implement stores
const storeAssignments = useAssignments()

// · initialize/inject plugins
const route = useRoute()

// · 
const translations = {
    users: I18n.t("core.users"),
    shared: I18n.t("core.shared"),
    sla: I18n.t('help.slas')
}

const columns = [{
    field: "name",
    label: "Name"
}, {
    field: "email",
    label: "Email"
}, {
    field: "roles",
    label: "Roles"
}, {
    field: "assigned",
    label: "Assigned"
}]


onMounted(() => {
    storeAssignments.getOptions()
    storeAssignments.ticket_id = route.params.id
})

function submitAssignment(user){
    if(user.checked){
        console.log('assignment')
        storeAssignments.postAssignment(user)
    }else{
        console.log('not assigned')
        storeAssignments.deleteAssignment(user)
    }
}

</script>
<template>
    <h2>Assignments</h2>
    <div class="box">
        <lesli-table 
            :records="storeAssignments.users"
            :columns="columns"
        >
            <template #roles="{ column, value }">
                <span
                    v-for="role in value"
                    :key="role.id"
                    class="tag is-success is-small is-rounded mr-1"
                >
                    {{ role.name }}
                </span>
            </template>

            <template #assigned="{ record, value }">
                <input type="checkbox" v-model="record.checked" @input="submitAssignment(record)">
            </template>

        </lesli-table>
    </div>

</template>
