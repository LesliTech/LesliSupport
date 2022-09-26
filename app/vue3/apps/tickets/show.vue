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
import { useRouter } from 'vue-router'

// . import components
import formTicket from './components/form.vue'
import ComponentDiscussions from "LesliVue/cloud-objects/discussion.vue"
import ComponentFiles from "LesliVue/cloud-objects/file.vue"
import ComponentWorkflowStatusDropdown from "LesliVue/shared/workflows/components/workflow-status-dropdown.vue"


// · import lesli stores
import { useTickets } from "CloudHelp/stores/tickets/tickets"


// · implement stores
const storeTickets = useTickets()

//·
const translations = {
    main: I18n.t('help.tickets'),
    core: {
        shared: I18n.t('core.shared')
    }
}

// · initializing
onMounted(() => {
    storeTickets.getTickets()
})

/**
 * @description This function is called when the user updates the status of the project.
 */
const onUpdatedStatus = () => {
    storeTickets.fetchTicket(route.params.id)
}


</script>
<template>

    <section class="application-component">
        <lesli-header 
            :title="storeTickets.ticket.id"
        >
            <!-- <component-workflow-status-dropdown
                    v-if="storeTickets.ticket.id"
                    cloud-module="help"
                    cloud-object="/tickets"
                    :cloud-object-id="storeTickets.ticket.id"
                    @on-updated-status="onUpdatedStatus"
            >
            </component-workflow-status-dropdown> -->
            <button class="button is-fullwidth has-text-centered is-danger" @click="storeTickets.deleteTicket">
                Delete
            </button>
        </lesli-header>
        <lesli-tabs v-model="tab">
            <lesli-tab-item title="Information" icon="info">
                <form-ticket is-editable></form-ticket>
            </lesli-tab-item>
            <lesli-tab-item title="Discussions" icon="forum">
                <component-discussions 
                    cloud-module="help" 
                    cloud-object="/tickets" 
                    :cloud-object-id="storeTickets.ticket.id"
                >
                </component-discussions>
            </lesli-tab-item>
            <lesli-tab-item title="Files" icon="attach_file">
                <component-files
                    cloud-module="help" 
                    cloud-object="/tickets"
                    :cloud-object-id="storeTickets.ticket.id"
                ></component-files>

            </lesli-tab-item>

            <lesli-tab-item title="Timeline" icon="timeline">

            </lesli-tab-item>
            <lesli-tab-item title="Activities log" icon="article">

            </lesli-tab-item>
            <lesli-tab-item title="Internal comments" icon="comment">

            </lesli-tab-item>
        </lesli-tabs>
    </section>

</template>
