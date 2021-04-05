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
import componentWorkflowTransition from 'LesliVue/shared/workflows/components/transition.vue'
import componentFormStatus from 'LesliVue/shared/workflows/components/form-status.vue'
import componentSubscription from 'LesliCoreVue/cloud_objects/subscription.vue'
import componentDiscussion from 'LesliCoreVue/cloud_objects/discussion.vue'
import componentAction from 'LesliCoreVue/cloud_objects/action.vue'
import componentFile from 'LesliCoreVue/cloud_objects/file.vue'

import componentActivities from '../components/activities.vue'
import componentTimeline from '../components/timeline.vue'
import componentTitle from '../components/title.vue'
import componentForm from '../components/form.vue'


// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-workflow-transition': componentWorkflowTransition,
        'component-subscription': componentSubscription,
        'component-form-status': componentFormStatus,
        'component-discussion': componentDiscussion,
        'component-activities': componentActivities,
        'component-action': componentAction,
        'component-timeline': componentTimeline,
        'component-title': componentTitle,
        'component-file': componentFile,
        'component-form': componentForm
    },

    props: {
        expandedTabs: {
            type: Boolean,
            default: false
        }
    },

    data() {
        return {
            translations: {
                main: I18n.t('help.tickets'),
                core: I18n.t('core.shared'),
                shared: I18n.t('help.shared'),
                workflow_statuses: I18n.t('help.workflow/statuses')
            },
            ticket_id: null,
            ticket: null,
            new_ticket_status: null,
            active_tab: 0
        }
    },

    mounted() {
        this.ticket_id = this.$route.params.id
        this.getTicket()
        this.setSubscriptions()
        this.setActiveTab()
    },

    methods: {

        setSubscriptions(){
            this.bus.subscribe('update:/help/ticket/workflow', (status)=>{
                this.ticket.cloud_help_ticket_workflow_statuses_id = status.id
                this.ticket.status = status.name
                this.ticket.status_initial = status.initial
                this.ticket.status_final = status.final
                this.ticket.status_name = status.name
                this.ticket.status_number = status.number
            })
        },

        // We publish the ticket so the form can use it
        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket = this.parseBackendData(result.data)
                    this.data.ticket = this.ticket
                    this.data.sla = this.ticket.sla
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        parseBackendData(ticket){
            if(ticket.deadline){
                ticket.deadline = new Date(ticket.deadline)
            }

            if(ticket.tags && ticket.tags.trim().length > 0){
                ticket.tags = ticket.tags.split(',')
            }else{
                ticket.tags = []
            }

            if(ticket.description){
                ticket.description = JSON.parse(ticket.description)
            }else{
                ticket.description = {}
            }

            return ticket
        },

        setActiveTab(){
            let tab = (this.$route.query.tab || '')

            if(tab){
                switch(tab){
                    case 'information':
                        this.active_tab = 0
                    case 'discussions':
                        this.active_tab = 1
                        break
                    case 'files':
                        this.active_tab = 2
                        break
                    case 'timeline':
                        this.active_tab = 3
                        break
                    case 'activities':
                        this.active_tab = 4
                        break
                }
            }
        }
    },

    computed: {
        activeFilesTab(){
            return this.active_tab == 2
        },

        activeDiscussionsTab(){
            return this.active_tab == 1
        },

        activeTimelinesTab(){
            return this.active_tab == 3
        },

        activeActivitiesTab(){
            return this.active_tab == 4
        }
    }
}
</script>
<template>
    <section v-if="ticket" class="application-component">
        <component-title
            v-if="ticket"
            :id="ticket.id"
            :subject="ticket.subject"
            :status="
                object_utils.translateEnum(translations.core, 'column_enum_status', ticket.status, null) ||
                object_utils.translateEnum(translations.workflow_statuses, 'column_enum_status', ticket.status)
            "
        >
            <template v-slot:actions>
                <div class="navbar-item">
                    <component-workflow-transition
                        v-if="['completed_successfully', 'completed_unsuccessfully'].includes(ticket.status_type)"
                        cloud-module="help/ticket"
                        translations-path="help.workflows"
                        :cloud-id="ticket_id"
                        v-model="new_ticket_status"
                        :handle-patch="false"
                    >
                    </component-workflow-transition>
                </div>
                <div class="navbar-item">
                    <div class="buttons">
                        <router-link class="button" to="/">
                            <b-icon icon="list" size="is-small" />
                            <span>{{ translations.core.view_btn_list }}</span>
                        </router-link>
                        <router-link class="button" :to="`/${ticket_id}/edit`" v-if="ticket.editable">
                            <b-icon icon="edit" size="is-small" />
                            <span>{{ translations.core.view_btn_edit }}</span>
                        </router-link>
                    </div>
                </div>
            </template>
        </component-title>
        <component-form-status
            :selected-status="new_ticket_status"
            status-foreign-key="cloud_help_workflow_statuses_id"
            cloud-object-variable="ticket"
        >
        </component-form-status>
        <b-tabs vertical v-model="active_tab">
            <b-tab-item :label="translations.shared.view_tab_title_general_information">
                <component-form v-if="data.ticket" view-type="show" :expanded-tabs="expandedTabs"></component-form>
            </b-tab-item>

            <b-tab-item :label="translations.core.view_btn_discussions">
                <div class="card">
                    <div class="card-header">
                        <div class="card-header-title is-shadowless">
                            <h4 class=" title is-4">
                                {{translations.core.view_text_discussions}}
                            </h4>
                        </div>
                    </div>
                    <div class="card-content">
                        <component-discussion cloud-module="help/ticket" :cloud-id="ticket_id" :active="activeDiscussionsTab"></component-discussion>
                    </div>
                </div>
            </b-tab-item>

            <b-tab-item :label="translations.core.view_btn_files">
                <component-file translations-file-types-path="help.ticket/files" cloud-module="help/ticket" :cloud-id="ticket_id" :active="activeFilesTab">
                </component-file>
            </b-tab-item>

            <b-tab-item :label="translations.main.view_btn_status_timeline">
                <component-timeline :active="activeTimelinesTab"></component-timeline>
            </b-tab-item>

            <b-tab-item :label="translations.core.view_btn_activities">
                <component-activities :ticket-id="ticket_id" :active="activeActivitiesTab"></component-activities>
            </b-tab-item>
        </b-tabs>
    </section>
</template>
