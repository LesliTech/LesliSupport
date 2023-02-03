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
import { inject, onMounted, ref, onUnmounted } from "vue"

// · import lesli stores
import { useSlas } from "CloudHelp/stores/sla"

import editorRichText from "LesliVue/components/editors/richtext.vue"

// · import vue router composable
import { useRouter, useRoute } from "vue-router"

// · implement stores
const storeSla = useSlas()

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
    main: I18n.t('help.slas'),
    core: I18n.t('core.shared'),
    shared: I18n.t('help.shared')
}

/**
 * @description This function is used to update the sla information
 */
const onUpdate = () => {
    storeSla.updateSla()
}

/**
 * @description This function is used to create a new sla
 */
const onCreate = () => {
    storeSla.postSla().then(()=>{
        router.push(url.help('slas').s)
    })
}

/**
 * Checking if the form is for a new sla or for editing existing one
*/
if (props.isEditable){
    storeSla.sla = {}
    storeSla.fetchSla(route.params.id)
} else {
    storeSla.sla = {}
}

</script>
<template>
    <form class="information"
        v-if="!storeSla.loading"
        @submit.prevent="isEditable ? onUpdate() : onCreate()"
    >
        <div class="columns">
            <div class="column is-8">
                <div class="field">
                    <label class="label">
                        {{translations.main.column_name}}<sup class="has-text-danger">*</sup>
                    </label>
                    <div class="control is-expanded">
                        <input class="input" v-model="storeSla.sla.name" required type="text">
                    </div>
                </div>
            </div>

            <div class="column">
                <div class="field">
                    <label class="label">
                        {{translations.main.column_default}}
                    </label>
                    <input type="checkbox" v-model="storeSla.sla.default">
                </div>
            </div>
        </div>

        <div class="columns">
            <div class="column is-4">
                <label class="label">
                    {{translations.main.column_expected_response_time}}<sup class="has-text-danger">*</sup>
                </label>
                <div class="control">
                    <input class="input" type="number" v-model="storeSla.sla.expected_response_time" required>
                </div>
            </div>

            <div class="column is-4">
                <label class="label">
                    {{translations.main.column_expected_resolution_time}}<sup class="has-text-danger">*</sup>
                </label>
                <div class="control">
                    <input class="input" type="number" v-model="storeSla.sla.expected_resolution_time" required>
                </div>
            </div>

            <div class="column is-4">
                <label class="label">
                    {{translations.main.column_price_per_hour}}<sup class="has-text-danger">*</sup>
                </label>
                <div class="control">
                    <input class="input" type="number" v-model="storeSla.sla.price_per_hour" required>
                </div>
            </div>
        </div>

        <div class="columns">
            <div class="column">
                <div class="field">
                    <label class="label">{{translations.main.column_body}}</label>
                    <div class="control">
                        <editor-rich-text mode="small" v-model="storeSla.sla.body">
                        </editor-rich-text>
                    </div>
                </div>
            </div>
        </div>

        <div class="columns">
            <div class="column">
                <div class="field">
                    <label class="label">{{translations.main.column_client_repercussions}}</label>
                    <div class="control">
                        <editor-rich-text mode="small" v-model="storeSla.sla.client_repercussions">
                        </editor-rich-text>
                    </div>
                </div>
            </div>
        </div>

        <div class="columns">
            <div class="column">
                <div class="field">
                    <label class="label">{{translations.main.column_provider_repercussions}}</label>
                    <div class="control">
                        <editor-rich-text mode="small" v-model="storeSla.sla.provider_repercussions">
                        </editor-rich-text>
                    </div>
                </div>
            </div>
        </div>

        <div class="columns">
            <div class="column">
                <div class="field">
                    <label class="label">{{translations.main.column_exceptions}}</label>
                    <div class="control">
                        <editor-rich-text mode="small" v-model="storeSla.sla.exceptions">
                        </editor-rich-text>
                    </div>
                </div>
            </div>
        </div>

        <div class="field is-horizontal is-expanded">
            <div class="field-label is-normal">
            </div>
            <div class="field-body">
                <div class="field">
                    <div class="control">
                        <lesli-button icon="save" :loading="storeSla.loading">
                            {{ translations.core.view_btn_save }}
                        </lesli-button>                 
                    </div>
                </div>
            </div>
        </div>
    </form>

</template>
