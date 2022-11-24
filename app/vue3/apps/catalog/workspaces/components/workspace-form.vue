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
import { inject } from "vue"

// · import lesli stores
import { useTicketWorkspaces } from "CloudHelp/stores/catalog/workspaces"

// · import vue router composable
import { useRouter, useRoute } from "vue-router"

// · implement stores
const storeWorkspaces = useTicketWorkspaces()

// · initialize/inject plugins
const router = useRouter()
const url = inject("url")
const route = useRoute()

// · defining props
const props = defineProps({
    isEditable: {
        type: Boolean,
        required: false,
        default: false,
    },
})

// · 
const translations = {
    main: I18n.t('help.catalog/ticket_workspaces'),
    core: I18n.t('core.shared'),
    shared: I18n.t('help.shared')
}

/**
 * @description This function is used to update the workspace information
 */
const onUpdate = () => {
    storeWorkspaces.updateWorkspace()
}

/**
 * @description This function is used to create a new workspace
 */
const onCreate = () => {
    storeWorkspaces.postTicketWorkspace().then(() => {
        router.push(url.help('catalog/ticket_workspaces').toString())
    })
}

/**
 * Checking if the form is for a new workspace or for editing existing one
*/
if (props.isEditable){
    storeWorkspaces.workspace = {}
    storeWorkspaces.getWorkspace(route.params.id)
} else {
    storeWorkspaces.workspace = {}
}

</script>
<template>
    <form class="information"
        v-if="!storeWorkspaces.loading"
        @submit.prevent="isEditable ? onUpdate() : onCreate()"
    >
        <!-- Workspace name -->
        <div class="columns">
            <div class="column is-8">
                <div class="field">
                    <label class="label">
                        {{translations.main.column_name}}<sup class="has-text-danger">*</sup>
                    </label>
                    <div class="control is-expanded">
                        <input class="input" v-model="storeWorkspaces.workspace.name" required type="text">
                    </div>
                </div>
            </div>
        </div>

        <!-- Workspace is default? -->
        <div class="columns">
            <div class="column is-4">
                <label class="label">
                    {{translations.main.column_default}}<sup class="has-text-danger">*</sup>
                </label>
                <div class="control">
                    <input class="input" type="text" v-model="storeWorkspaces.workspace.default" required>
                </div>
            </div>
        </div>

        <!-- Save button -->
        <div class="field is-horizontal is-expanded">
            <div class="field-label is-normal">
            </div>
            <div class="field-body">
                <div class="field">
                    <div class="control">
                        <lesli-button icon="save" :loading="storeWorkspaces.loading">
                            {{ translations.core.view_btn_save }}
                        </lesli-button>                 
                    </div>
                </div>
            </div>
        </div>
    </form>

</template>
