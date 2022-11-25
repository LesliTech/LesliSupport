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
import { onMounted, computed } from "vue"
import { useRouter, useRoute } from 'vue-router'

// . import components
import workspaceForm from './components/workspace-form.vue'

// · import lesli stores
import { useTicketWorkspaces } from "CloudHelp/stores/catalog/workspaces"

// · initialize/inject plugins
const route = useRoute()
const router = useRouter()

// · implement stores
const storeWorkspaces = useTicketWorkspaces()

//·
const translations = {
    main: I18n.t('help.catalog/ticket_workspaces'),
    core: I18n.t('core.shared')
}

/**
 * @description This function is used to delete a workspace
 */
const onDelete = () => {
    storeWorkspaces.deleteWorkspace(route.params.id)
    router.push(url.help('catalog/ticket_workspaces').toString())
}

// · initializing
onMounted(() => {
    storeWorkspaces.getWorkspace(route.params.id)
})


</script>
<template>

    <section class="application-component">
        <lesli-header
            :title="translations.main.view_title_edit"
        >
            <button class="button is-fullwidth has-text-centered is-danger" @click="onDelete">
                {{translations.core.view_tab_title_delete_section}}
            </button>
            <lesli-button :to="url.help('catalog/ticket_workspaces')" icon="list">
                {{translations.main.view_title_main}}
            </lesli-button>
        </lesli-header>
        <div class="box">
            <workspace-form is-editable></workspace-form>
        </div>
    </section>

</template>
