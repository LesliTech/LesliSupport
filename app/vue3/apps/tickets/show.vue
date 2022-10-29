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
import { useRouter, useRoute } from 'vue-router'

// . import components
import formTicket from './components/ticket-form.vue'
import slaInfo from './components/sla-info.vue'
import internalComments from './components/internal-comments.vue'
import assignments from './components/assignments.vue'

import ComponentDiscussions from "LesliVue/cloud-objects/discussion.vue"
import ComponentFiles from "LesliVue/cloud-objects/file.vue"
import ComponentWorkflowStatusDropdown from "LesliVue/shared/workflows/components/workflow-status-dropdown.vue"


// · import lesli stores
import { useTickets } from "CloudHelp/stores/tickets/tickets"

// · initialize/inject plugins
const route = useRoute()

// · implement stores
const storeTickets = useTickets()

//·
const translations = {
    main: I18n.t('help.tickets'),
    sla: I18n.t('help.slas'),
    core: {
        shared: I18n.t('core.shared')
    },
    shared: I18n.t('help.shared')
}
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
    storeTickets.fetchTicket(route.params.id)
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
            :title="storeTickets.ticket.id+' - '+storeTickets.ticket.subject+' - '+storeTickets.ticket.status"
        >
            <component-workflow-status-dropdown
                    v-if="storeTickets.ticket.id"
                    @on-updated-status="onUpdatedStatus()"
                    cloudObject="/tickets"
                    cloudModule="help"
                    :cloudObjectId="storeTickets.ticket.id"
            >
            </component-workflow-status-dropdown>
            <button class="button is-fullwidth has-text-centered is-danger" @click="storeTickets.deleteTicket">
                {{translations.shared.view_tab_title_delete_section}}
            </button>
            <lesli-button :to="url.root(props.appMountPath)" icon="list">
                {{translations.main.view_title_main}}
            </lesli-button>
        </lesli-header>

        <lesli-tabs v-model="tab">
            <lesli-tab-item :title="translations.shared.view_tab_title_general_information" icon="info">
                <form-ticket is-editable></form-ticket>
            </lesli-tab-item>

            <lesli-tab-item :title="translations.main.view_tab_title_assignments" icon="group">
                <assignments></assignments>
            </lesli-tab-item>

            <lesli-tab-item :title="translations.core.shared.view_btn_discussions" icon="forum">
                <component-discussions 
                    cloud-module="help" 
                    cloud-object="tickets" 
                    :cloud-object-id="storeTickets.ticket.id"
                    :onlyDiscussions="true"
                >
                </component-discussions>
            </lesli-tab-item>
            <lesli-tab-item :title="this.translations.core.shared.view_btn_files" icon="attach_file">
                <component-files
                    cloud-module="help" 
                    cloud-object="tickets"
                    :cloud-object-id="storeTickets.ticket.id"
                ></component-files>

            </lesli-tab-item>

            <lesli-tab-item :title="translations.main.view_tab_title_histories" icon="comment">
                <internal-comments></internal-comments>
            </lesli-tab-item>

            <lesli-tab-item :title="translations.main.view_tab_title_sla" icon="article">
                <sla-info></sla-info>
            </lesli-tab-item>
        </lesli-tabs>
    </section>

</template>
