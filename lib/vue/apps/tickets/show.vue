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
import { onMounted, computed, inject } from "vue"
import { useRouter, useRoute } from "vue-router"


// . import components
import formTicket from "./components/form.vue"
// import slaInfo from './components/sla-info.vue'
// import internalComments from './components/internal-comments.vue'
// import assignments from './components/assignments.vue'


//import ComponentDiscussions from "Lesli/cloudobjects/components/discussion.vue"
//import ComponentFiles from "Lesli/cloudobjects/components/file.vue"
//import ComponentWorkflowStatusDropdown from "Lesli/shared/workflows/components/workflow-status-dropdown.vue"
//import ComponentActions from "Lesli/cloudobjects/components/action.vue"


// · import lesli stores
import { useTickets } from "LesliSupport/vue/stores/tickets"


// · initialize/inject plugins
const route = useRoute()
const router = useRouter()
const url = inject("url")


// · implement stores
const storeTickets = useTickets()


//·
const translations = {
    tickets: i18n.t("lesli_support.tickets"),
    lesli: {
        shared: i18n.t("lesli.shared")
    },


    main: I18n.t('help.tickets'),
    sla: I18n.t('help.slas'),
    core: {
        shared: I18n.t('core.shared')
    },
    shared: I18n.t('help.shared')
}


//·
const props = defineProps({
    editable: {
        type: Boolean,
        required: false,
        default: false,
    },
    appMountPath: {
        type: String,
        required: false,
        default: "help/tickets",
    }
})


//· 
onMounted(() => {
    storeTickets.fetchTicket(route.params.id)
})


//· 
const onUpdatedStatus = () => {
    storeTickets.getTicket(route.params.id)
}


//·
const onDelete = () => {
    storeTickets.deleteTicket().then(()=>{
        router.push(url.root(`${props.appMountPath}`).s)
    })
}

</script>
<template>
    <lesli-application-container>
        <lesli-header :title="`${storeTickets.ticket.subject} (${storeTickets.ticket.status || 'open'})`">
            <lesli-link button icon="list" :to="url.support('tickets')">
                {{ translations.lesli.shared.button_list }}
            </lesli-link>
            <lesli-link v-if="!props.editable" button warning :to="url.support('tickets/:id/edit', route.params.id)" icon="edit">
                {{ translations.lesli.shared.button_edit }}
            </lesli-link>
            <lesli-link v-if="props.editable" button info :to="url.support('tickets/:id', route.params.id)" icon="visibility">
                {{ translations.lesli.shared.button_show }}
            </lesli-link>
            <lesli-button danger @click="onDelete" icon="delete">
                {{ translations.lesli.shared.button_delete }}
            </lesli-button>
        </lesli-header>

        <lesli-tabs v-model="tab">
            <lesli-tab-item title="Information" icon="info" paddingless>
                <form-ticket :path="props.appMountPath" :editable="props.editable"></form-ticket>
            </lesli-tab-item>
            <lesli-tab-item title="Discussions" icon="forum">
                <component-discussions 
                    cloud-module="help" 
                    cloud-object="tickets" 
                    :cloud-object-id="storeTickets.ticket.id"
                    :onlyDiscussions="false">
                </component-discussions>
            </lesli-tab-item>
        </lesli-tabs>
        <!-- 
        <lesli-tab-item :title="translations.tickets.tab_assignments" icon="group">
            <assignments></assignments>
        </lesli-tab-item>
        <lesli-tab-item :title="translations.lesli.shared.view_files" icon="attach_file">
            <component-files
                cloud-module="help" 
                cloud-object="tickets"
                :cloud-object-id="storeTickets.ticket.id"
                :accepted-files="['images', 'documents', 'plaintext']">
            </component-files>
        </lesli-tab-item>

        <lesli-tab-item :title="translations.main.view_tab_title_histories" icon="comment">
            <internal-comments></internal-comments>
        </lesli-tab-item>

        <lesli-tab-item :title="translations.lesli.shared.view_quick_actions" icon="playlist_add_check">
            <component-actions
                cloud-module="help" 
                cloud-object="tickets"
                :cloud-object-id="storeTickets.ticket.id">
            </component-actions>
        </lesli-tab-item>

        <lesli-tab-item :title="translations.main.view_tab_title_sla" icon="article" v-if="storeTickets.ticket.sla">
            <sla-info></sla-info>
        </lesli-tab-item>
        -->
    </lesli-application-container>
</template>
