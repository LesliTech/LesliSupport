<script>
/*
Lesli
Copyright (c) 2019, Lesli Technologies, S. A.
All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.
LesliCloud - Your Smart Business Assistant
Powered by https://www.lesli.tech
Building a better future, one line of code at a time.
@dev      Carlos Hermosilla
@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/
// · Component list
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentChart from 'LesliCoreVue/cloud_objects/workflows/components/chart.vue'
import componentAssociation from 'LesliCoreVue/cloud_objects/workflows/components/association.vue'
import componentAction from 'LesliCoreVue/cloud_objects/workflows/components/action.vue'
export default {
    components: {
        'component-chart': componentChart,
        'component-association': componentAssociation,
        'component-action': componentAction
    },
    data() {
        return {
            main_route: '/crm/workflows',
            translations: {
                shared: I18n.t('deutscheleibrenten.shared'),
                main: I18n.t('deutscheleibrenten.workflows')
            },
            workflow: null,
            workflow_id: null,
            active_tab: 0,
            selected_workflow_status: {},
            cloud_engine: 'crm'
        }
    },
    mounted() {
        this.setMainRoute()
        this.setTranslations()
        this.setWorkflowId()
    },
    methods: {
        
        setWorkflowId(){
            if (this.$route.params.id) {
                this.workflow_id = this.$route.params.id
                this.getWorkflow()
            }
        },
        setMainRoute(){
            if(this.$route.query.module){
                this.cloud_engine = this.$route.query.module
                this.main_route = `/${this.$route.query.module}/workflows`
            }
        },
        setTranslations(){
            let cloud_engine_translations_path = this.getCloudEngineTranslationsPath()
            this.$set(this.translations, 'workflows', I18n.t(`${cloud_engine_translations_path}.workflows`))
        },
        getCloudEngineTranslationsPath(){
            if(this.cloud_engine == 'crm'){
                return 'deutscheleibrenten'
            }
            return this.cloud_engine
        },
        getWorkflow() {
            let url = `${this.main_route}/${this.workflow_id}.json`
            this.http.get(url).then(result => {
                if (result.successful) {
                    this.workflow = result.data
                } else {
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        publishShowWorkflowAssociation(){
            this.bus.publish('show:/module/workflows/association')
        },
        publishShowWorkflowActions(){
            this.bus.publish('show:/module/workflows/action')
        },
        patchWorkflowDefault() {
            let url = `${this.main_route}/${this.workflow_id}`
            let data = {
                workflow: {
                    default: true
                }
            }
            this.http.patch(url, data).then(result => {
                if(result.successful){
                    this.workflow.default = true
                    this.alert(this.translations.main.notification_workflow_set_as_default, 'success')
                } else {
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        deleteWorkflow(){
            let url = `${this.main_route}/${this.workflow_id}`
            this.http.delete(url).then(result => {
                if(result.successful){
                    this.alert(this.translations.main.notification_workflow_deleted, 'success')
                    this.$router.push('/')
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        confirmDeletion() {
            this.$buefy.dialog.confirm({
                title: this.translations.main.conformation_workflow_delete_title,
                message: this.translations.main.confirmation_workflow_delete_description,
                confirmText: this.translations.main.confirmation_workflow_delete_btn_confirm,
                cancelText: this.translations.shared.btn_cancel,
                type: 'is-danger',
                hasIcon: true,
                onConfirm: () => this.deleteWorkflow()
            })
        },
        selectWorkflowStatus(status){
            this.selected_workflow_status = status
        },
        tooltipButtonInitial(status){
            if(status.status_type == 'initial'){
                return this.translations.main.form_tooltip_initial
            }
            return ''
        },
        tooltipButtonCompletedSuccessfully(status){
            if(status.status_type == 'completed_successfully'){
                return this.translations.main.form_tooltip_successful
            }
            return ''
        },
        tooltipButtonCompletedUnsuccessfully(status){
            if(status.status_type == 'completed_unsuccessfully'){
                return this.translations.main.form_tooltip_unsuccessful
            }
            return ''
        },
        tooltipButtonToBeDeleted(status){
            if(status.status_type == 'to_be_deleted'){
                return this.translations.main.form_tooltip_to_be_deleted
            }
            return ''
        }
    },
    computed: {
        selectedStatusTransitions(){
            let next_statuses = []
            if(! this.workflow.statuses[this.selected_workflow_status.id]){
                return next_statuses
            }
            
            if(this.selected_workflow_status.next_statuses){
                let next_statuses_ids = this.selected_workflow_status.next_statuses.split('|')
                next_statuses_ids.forEach((id)=>{
                    next_statuses.push(this.workflow.statuses[id])
                })
            }
            return next_statuses
        },
        orderedWorkflowStatuses(){
            if(! this.workflow.statuses){
                return []
            }
            
            return Object.values(this.workflow.statuses).sort(function(status_1, status_2){
                return (status_1.number || 0) - (status_2.number || 0)
            })
        }
    }
}
</script>
<template>
    <section v-if="workflow" class="application-component">
        <nav class="navbar component-header">
            <div class="navbar-menu">
                <div class="navbar-start">
                    <div class="navbar-item">
                        <h4 class="is-size-3">
                            {{translations.main.list_title}}
                        </h4>
                    </div>
                </div>
            </div>
        </nav>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    {{ workflow.name }} &nbsp;
                    <span v-if="workflow.default" class="has-text-info">
                        ({{translations.main.field_default}})
                    </span>
                </h2>
                <div class="card-header-icon">
                    <span v-if="workflow.default" class="has-text-gray">
                        <i class="fas fa-check-circle"></i>
                        {{translations.main.btn_set_as_default}}
                    </span>
                    <a v-else href="javascript:void(0)" @click="patchWorkflowDefault">
                        <i class="fas fa-check-circle"></i>
                        {{translations.main.btn_set_as_default}}
                    </a>
                    <a role="button" @click="publishShowWorkflowActions">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-paperclip"></i>
                        {{translations.main.btn_workflow_actions}}
                    </a>
                    <a role="button" @click="publishShowWorkflowAssociation">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-globe"></i>
                        {{translations.main.btn_workflow_associations}}
                    </a>
                    <router-link :to="`/${workflow_id}/edit?module=${cloud_engine}`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-edit"></i>
                        {{translations.shared.btn_edit}}
                    </router-link>
                    <router-link :to="`/?module=${cloud_engine}`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        {{translations.shared.btn_return}}
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <b-tabs v-model="active_tab">
                    <b-tab-item :label="translations.main.show_tab_list_view">
                        <div class="columns">
                            <div class="column is-6">
                                <h5 class="title is-5">
                                    {{translations.main.show_statuses_list_title}}
                                </h5>
                                <div class="menu-list workflow-statuses-list is-bg-dark is-hoverable">
                                    <a 
                                        v-for="(status) in orderedWorkflowStatuses"
                                        :key="status.id"
                                        class="list-item"
                                        @click="selectWorkflowStatus(status)"
                                        :class="{'is-active':selected_workflow_status.id == status.id}"
                                    >
                                        {{object_utils.translateEnum(translations.workflows, 'status', status.name)}} - 
                                        <b-tooltip  :label="translations.main.form_tooltip_status_step" type="is-light" position="is-top">
                                            {{status.number}}
                                        </b-tooltip>
                                        <span class="is-pulled-right">
                                            <b-tooltip position="is-top" :label="tooltipButtonInitial(status)" type="is-primary">
                                                <b-button size="is-small" type="is-primary" :outlined="status.status_type != 'initial'" disabled>
                                                    <b-icon size="is-small" icon="play-circle">
                                                    </b-icon>
                                                </b-button>
                                            </b-tooltip>
                                            <b-tooltip position="is-top" :label="tooltipButtonCompletedSuccessfully(status)" type="is-success">
                                                <b-button
                                                    size="is-small" type="is-success"
                                                    :outlined="status.status_type != 'completed_successfully'"
                                                    disabled
                                                >
                                                    <b-icon size="is-small" icon="check-circle">
                                                    </b-icon>
                                                </b-button>
                                            </b-tooltip>
                                            <b-tooltip position="is-top" :label="tooltipButtonCompletedUnsuccessfully(status)" type="is-danger">
                                                <b-button
                                                    size="is-small" type="is-warning"
                                                    :outlined="status.status_type != 'completed_unsuccessfully'"
                                                    disabled
                                                >
                                                    <b-icon size="is-small" icon="check-circle">
                                                    </b-icon>
                                                </b-button>
                                            </b-tooltip>
                                            <b-tooltip position="is-top" :label="tooltipButtonToBeDeleted(status)" type="is-warning">
                                                <b-button
                                                    size="is-small" type="is-danger"
                                                    :outlined="status.status_type != 'to_be_deleted'"
                                                    disabled
                                                >
                                                    <b-icon size="is-small" icon="exclamation-circle">
                                                    </b-icon>
                                                </b-button>
                                            </b-tooltip>
                                        </span>
                                    </a>
                                </div>
                            </div>
                            <div class="column is-6">
                                <h5 class="title is-5">
                                    {{translations.main.show_transition_statuses_list_title}}
                                </h5>
                                <div class="menu-list workflow-statuses-list">
                                    <a v-for="(workflow_status, key) in selectedStatusTransitions" :key="key" class="list-item">
                                        {{object_utils.translateEnum(translations.workflows, 'status', workflow_status.name)}}
                                        <span class="is-pulled-right">
                                            <b-button size="is-small" type="is-primary" :outlined="workflow_status.status_type != 'initial'" disabled>
                                                <b-icon size="is-small" icon="play-circle">
                                                </b-icon>
                                            </b-button>
                                            <b-button
                                                size="is-small" type="is-success"
                                                :outlined="workflow_status.status_type != 'completed_successfully'"
                                                disabled
                                            >
                                                <b-icon size="is-small" icon="check-circle">
                                                </b-icon>
                                            </b-button>
                                            <b-button
                                                size="is-small" type="is-warning"
                                                :outlined="workflow_status.status_type != 'completed_unsuccessfully'"
                                                disabled
                                            >
                                                <b-icon size="is-small" icon="check-circle">
                                                </b-icon>
                                            </b-button>
                                            <b-button
                                                size="is-small" type="is-danger"
                                                :outlined="workflow_status.status_type != 'to_be_deleted'"
                                                disabled
                                            >
                                                <b-icon size="is-small" icon="exclamation-circle">
                                                </b-icon>
                                            </b-button>
                                        </span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </b-tab-item>
                    <b-tab-item  :label="translations.main.form_tab_chart_view">
                        <component-chart
                            v-if="active_tab == 1"
                            class="has-text-centered"
                            :translations-path="`${getCloudEngineTranslationsPath()}.workflows`" 
                            :cloud-module="`${cloud_engine}/workflow`"
                            :workflow="workflow"
                        >
                        </component-chart>
                    </b-tab-item>
                </b-tabs>
                <div class="columns">
                    <div class="column">
                        <small>
                            <span class="has-text-weight-bold">
                                {{translations.shared.text_created_at}}:
                            </span>
                            {{ workflow.created_at }}
                        </small>
                    </div>
                    <div class="column">
                        <div class="field">
                            <div class="actions has-text-right">
                                <b-tooltip
                                    type="is-danger"
                                    position="is-left"
                                    multilined
                                    :active="workflow.deletion_protection"
                                    :label="translations.shared.notification_workflow_deletion_protection"
                                >
                                    <b-button type="is-danger" outlined @click="confirmDeletion()" :disabled="workflow.deletion_protection">
                                        <b-icon size="is-small" icon="trash-alt" />
                                        &nbsp;
                                        {{translations.shared.text_delete}}
                                    </b-button>
                                </b-tooltip>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <component-association :cloud-engine="cloud_engine" :workflow-id="workflow_id" translations-path="deutscheleibrenten.workflow/associations" />
        <component-action :cloud-engine="cloud_engine" :workflow-id="workflow_id" translations-path="deutscheleibrenten.workflow/actions" statuses-translations-path="deutscheleibrenten.workflows" />
    </section>
</template>