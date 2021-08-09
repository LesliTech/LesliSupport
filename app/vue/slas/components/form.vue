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
import componentRichTextEditor from 'LesliCoreVue/components/forms/richtext-editor.vue'

// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentAssociations from './associations.vue'

// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-rich-text-editor': componentRichTextEditor,
        'component-associations': componentAssociations
    },

    props: {
        viewType: {
            type: String,
            default: 'new'
        },
        appMountPath: {
            type: String,
            required: true
        }
    },

    data() {
        return {
            main_route: '/help/slas',
            submitting: false,
            deleting: false,
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
        this.setSubscriptions()
    },

    beforeDestroy(){
        this.deleteSubscriptions()
    },

    methods: {
        setSla(){
            this.sla_id = this.$route.params.id
            this.sla = this.data.sla
        },
        
        setSubscriptions(){
            this.bus.subscribe('update:/help/sla/workflow', (status)=>{
                this.sla.cloud_help_sla_workflow_statuses_id = status.id
                this.sla.status = status.name
                this.sla.status_type = status.status_type
            })
        },

        deleteSubscriptions(){
            this.bus.$off('update:/help/sla/workflow')
        },

        submitSla(event){
            if (event) { event.preventDefault() }

            if(this.viewType == 'new'){
                this.postSla()
            }else if(this.viewType == 'edit'){
                this.putSla()
            }
        },

        postSla(event) {
            if(event){
                e.preventDefault()
            }

            let data = {
                sla: this.sla
            }
            let url = `${this.main_route}.json`
            this.submitting = true

            this.http.post(url, data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_success_sla_created, 'success')
                    this.$router.push(`${this.appMountPath}/${result.data.id}`)
                } else {
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        putSla(event) {
            if(event){
                event.preventDefault()
            }

            let data = {
                sla: this.sla
            }
            let url = `${this.main_route}/${this.sla_id}.json`
            this.submitting = true

            this.http.put(url, data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_success_sla_updated, 'success')
                    this.reloadSlaActivities()
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })

        },

        deleteSla() {
            let url = `${this.main_route}/${this.sla_id}.json`
            this.deleting = true

            this.http.delete(url).then(result => {
                this.deleting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_success_sla_destroyed, 'success')
                    this.$router.push(`${this.appMountPath}/`)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        reloadSlaActivities(){
            this.data.reload.activities = true
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-content subtabs">
            <b-tabs>
                <b-tab-item :label="translations.shared.view_tab_title_general_information">
                    <form @submit="submitSla">
                        <div class="columns is-multiline">
                            <div class="column is-10">
                                <b-field>
                                    <template v-slot:label>
                                        {{translations.main.column_name}}<sup class="has-text-danger">*</sup>
                                    </template>
                                    <b-input v-model="sla.name" required></b-input>
                                </b-field>
                            </div>
                            <div class="column is-2">
                                <b-field :label="translations.main.column_default">
                                    <b-checkbox v-model="sla.default"></b-checkbox>
                                </b-field>
                            </div>
                            <div class="column is-3">
                                <b-field :message="translations.main.column_expected_response_time_description" >
                                    <template v-slot:label>
                                        {{translations.main.column_expected_response_time}}<sup class="has-text-danger">*</sup>
                                    </template>
                                    <b-input v-model="sla.expected_response_time" required type="number" min="0" step="1"></b-input>
                                </b-field>
                            </div>
                            <div class="column is-3">
                                <b-field :message="translations.main.column_expected_resolution_time_description" >
                                    <template v-slot:label>
                                        {{translations.main.column_expected_resolution_time}}<sup class="has-text-danger">*</sup>
                                    </template>
                                    <b-input v-model="sla.expected_resolution_time" required type="number" min="0" step="1"></b-input>
                                </b-field>
                            </div>
                            <div class="column is-3">
                                <b-field :message="translations.main.column_price_per_hour" >
                                    <template v-slot:label>
                                        {{translations.main.column_price_per_hour}}<sup class="has-text-danger">*</sup>
                                    </template>
                                    <b-input v-model="sla.price_per_hour" required type="number" min="0" step="0.01"></b-input>
                                </b-field>
                            </div>
                        </div>

                        <div class="field">
                            <label class="label">{{translations.main.column_body}}</label>
                            <div class="control">
                                <component-rich-text-editor v-model="sla.body" type="full">
                                </component-rich-text-editor>
                            </div>
                        </div>

                        <div class="field">
                            <label class="label">{{translations.main.column_client_repercussions}}</label>
                            <div class="control">
                                <component-rich-text-editor v-model="sla.client_repercussions" type="full">
                                </component-rich-text-editor>
                            </div>
                        </div>

                        <div class="field">
                            <label class="label">{{translations.main.column_provider_repercussions}}</label>
                            <div class="control">
                                <component-rich-text-editor v-model="sla.provider_repercussions" type="full">
                                </component-rich-text-editor>
                            </div>
                        </div>

                        <div class="field">
                            <label class="label">{{translations.main.column_exceptions}}</label>
                            <div class="control">
                                <component-rich-text-editor v-model="sla.exceptions" type="full">
                                </component-rich-text-editor>
                            </div>
                        </div>

                        <div class="field has-text-right">
                            <b-button v-if="viewType != 'show'" type="is-primary" native-type="submit" :disabled="submitting" expanded class="submit-button">
                                <span v-if="submitting">
                                    <i class="fas fa-circle-notch fa-spin"></i>
                                    &nbsp; {{translations.core.view_btn_saving}}
                                </span>
                                <span v-else>
                                    <i class="fas fa-save"></i>
                                    &nbsp; {{translations.core.view_btn_save}}
                                </span>
                            </b-button>
                        </div>
                    </form>
                </b-tab-item>
                <b-tab-item :label="translations.main.view_tab_title_associations" v-if="viewType != 'new'">
                    <component-associations v-if="sla_id" :sla-id="sla_id"></component-associations>
                </b-tab-item>
                <b-tab-item :label="translations.shared.view_tab_title_delete_section" v-if="viewType == 'edit' && ! sla.default">
                    <span class="has-text-danger">
                        {{translations.main.view_text_delete_confirmation}}
                    </span>
                    <br>
                    <br>
                    <!---------------------------------- START DELETE BUTTON ---------------------------------->
                    <b-field v-if="viewType != 'new'">
                        <b-button type="is-danger" @click="deleteSla" expanded class="submit-button" :disabled="deleting">
                            <span v-if="deleting">
                                <i class="fas fa-spin fa-circle-notch"></i> {{translations.core.view_btn_deleting}}
                            </span>
                            <span v-else>
                                <i class="fas fa-trash-alt"></i> {{translations.core.view_btn_delete}}
                            </span>
                        </b-button>
                    </b-field>
                    <!----------------------------------  END DELETE BUTTON  ---------------------------------->
                </b-tab-item>
            </b-tabs>
        </div>
    </div>
</template>
