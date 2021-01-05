<script>
/*
Copyright (c) 2020, all rights reserved.

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


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentRichTextEditor from 'LesliCoreVue/components/forms/richtext-editor.vue'


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-rich-text-editor': componentRichTextEditor
    },

    props: {
        viewType: {
            type: String,
            default: 'new'
        }
    },

    data() {
        return {
            main_route: '/help/slas',
            translations:{
                main: I18n.t('help.slas'),
                core: I18n.t('core.shared'),
                shared: I18n.t('help.shared')
            },
            sla_id: null,
            sla: {}
        }
    },
    mounted() {
        this.setSla()
    },

    methods: {
        setSla(){
            this.sla_id = this.$route.params.id
            this.sla = this.data.sla
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-content subtabs">
            <div class="columns is-multiline">
                <div class="column is-10">
                    <b-field :label="translations.main.column_name">
                        <p>{{sla.name}}</p>
                    </b-field>
                </div>
                <div class="column is-2">
                    <b-field :label="translations.main.column_default">
                        <p v-if="sla.default">
                            <b>{{translations.core.view_text_yes}}</b>
                        </p>
                        <p v-else>
                            {{translations.core.view_text_no}}
                        </p>
                    </b-field>
                </div>
                <div class="column is-3">
                    <b-field :label="translations.main.column_expected_response_time">
                        <p> {{sla.expected_response_time}}</p>
                    </b-field>
                </div>
                <div class="column is-3">
                    <b-field :label="translations.main.column_expected_resolution_time" >
                        <p> {{sla.expected_resolution_time}}</p>
                    </b-field>
                </div>
            </div>

            <div class="field">
                <label class="label">{{translations.main.column_body}}</label>
                <div class="control">
                    <component-rich-text-editor v-model="sla.body" type="read">
                    </component-rich-text-editor>
                </div>
            </div>

            <div class="field">
                <label class="label">{{translations.main.column_provider_repercussions}}</label>
                <div class="control">
                    <component-rich-text-editor v-model="sla.provider_repercussions" type="read">
                    </component-rich-text-editor>
                </div>
            </div>

            <div class="field">
                <label class="label">{{translations.main.column_exceptions}}</label>
                <div class="control">
                    <component-rich-text-editor v-model="sla.exceptions" type="read">
                    </component-rich-text-editor>
                </div>
            </div>
        </div>
    </div>
</template>
