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
        shadowless: {
            type: Boolean,
            default: false
        }
    },

    data() {
        return {
            main_route: '/help/slas',
            translations:{
                main: I18n.t('help.slas'),
                core: I18n.t('core.shared'),
                shared: I18n.t('help.shared'),
                ticket_types: I18n.t('help.catalog/ticket_types')
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
    },

    watch: {
        'data.reload.sla'(){
            if(this.data.reload.sla){
                this.setSla()
                this.data.reload.sla = false
            }
        }
    }
}
</script>
<template>
    <div :class="['card', {'is-shadowless': shadowless}]">
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
                <div class="column is-4">
                    <b-field :label="`${translations.main.view_tab_title_associations} (${translations.ticket_types.view_title_main})`">
                        <b-taglist>
                            <b-tag v-for="association in sla.association_attributes" :key="association.id">
                                {{association.ticket_type_name}}
                            </b-tag>
                        </b-taglist>
                    </b-field>
                </div>
                <div class="column is-2">
                    <b-field :label="translations.main.column_price_per_hour" >
                        <p> {{sla.price_per_hour}}</p>
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
                <label class="label">{{translations.main.column_client_repercussions}}</label>
                <div class="control">
                    <component-rich-text-editor v-model="sla.client_repercussions" type="read">
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
