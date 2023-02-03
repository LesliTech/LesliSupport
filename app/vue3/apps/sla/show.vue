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
import slaForm from './components/sla-form.vue'
import associations from './components/associations.vue'

import ComponentDiscussions from "LesliVue/cloud-objects/discussion.vue"
import ComponentFiles from "LesliVue/cloud-objects/file.vue"
import ComponentWorkflowStatusDropdown from "LesliVue/shared/workflows/components/workflow-status-dropdown.vue"

// · import lesli stores
import { useSlas } from "CloudHelp/stores/sla"

// · initialize/inject plugins
const route = useRoute()

// · implement stores
const storeSla = useSlas()

//·
const translations = {
    main: I18n.t('help.slas'),
    core: I18n.t('core.shared'),
    shared: I18n.t('help.shared'),
    workflow_statuses: I18n.t('help.workflow/statuses')
}

/**
 * @description This function is called when the user updates the status of the sla.
 */
const onUpdatedStatus = () => {
    storeSla.fetchSla(route.params.id)
}

// · initializing
onMounted(() => {
    storeSla.getAssociationsOptions()
})

</script>
<template>

    <section class="application-component">
        <lesli-loading v-if="storeSla.loading"></lesli-loading>
        <lesli-header
            v-else
            :title="storeSla.sla.name"
        >
            <lesli-button :to="url.help('slas')" icon="list">
                {{translations.main.view_title_main}}
            </lesli-button>
        </lesli-header>

        <lesli-tabs v-model="tab">
            <lesli-tab-item :title="translations.shared.view_tab_title_general_information" icon="info">
                <sla-form is-editable></sla-form>
            </lesli-tab-item>

            <lesli-tab-item :title="translations.core.view_btn_discussions" icon="forum">
                <component-discussions 
                    cloud-module="help" 
                    cloud-object="slas" 
                    :cloud-object-id="storeSla.sla.id"
                    :onlyDiscussions="true"
                >
                </component-discussions>
            </lesli-tab-item>
            <lesli-tab-item :title="translations.core.view_btn_files" icon="attach_file">
                <component-files
                    cloud-module="help" 
                    cloud-object="slas"
                    :cloud-object-id="storeSla.sla.id"
                    :accepted-files="['images', 'documents', 'plaintext']"
                ></component-files>

            </lesli-tab-item>
            <lesli-tab-item :title="translations.main.view_tab_title_associations" icon="settings">
                <associations></associations>
            </lesli-tab-item>

        </lesli-tabs>
    </section>

</template>
