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
import componentSubscription from 'LesliVue/cloud_objects/subscription.vue'
import componentDiscussion from 'LesliVue/cloud_objects/discussion.vue'
import componentActions from 'LesliVue/cloud_objects/action.vue'
import componentFile from 'LesliVue/cloud_objects/file.vue'


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
        'component-actions': componentActions,
        'component-timeline': componentTimeline,
        'component-title': componentTitle,
        'component-file': componentFile,
        'component-form': componentForm
    },

    props: {
        expandedTabs: {
            type: Boolean,
            default: false
        },
        appMountPath: {
            type: String,
            default: ''
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
            active_tab: 0,
            ticket_id: null,
            ticket: null,
            new_ticket_status: null
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
                    if(this.ticket){
                        let ticket_data = this.parseBackendData(result.data)
                        for(let key in ticket_data){
                            this.$set(this.ticket, ticket_data[key])
                        }
                    }else{
                        this.ticket = this.parseBackendData(result.data)
                    }
                    this.data.ticket = this.ticket
                    this.data.sla = this.ticket.sla
                    this.data.files_count = this.ticket.files_count
                }else{
                    this.msg.error(result.error.message)
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
                        break
                    case 'discussions':
                        this.active_tab = 1
                        break
                    case 'files':
                        this.active_tab = 2
                        break
                    case 'actions':
                        this.active_tab = 3
                        break
                    case 'timeline':
                        this.active_tab = 4
                        break
                    case 'activities':
                        this.active_tab = 5
                        break
                }
            }
        },

        showSubscriptionsPanel(){
            this.data.global.show_panel_subscriptions = ! this.data.global.show_panel_subscriptions
        },

        setSubscriptionsActive(){
            this.ticket.subscribed = true
        },

        setSubscriptionsInactive(){
            this.ticket.subscribed = false
        }
    },

    computed: {
        activeDiscussionsTab(){
            return this.active_tab == 1
        },

        activeFilesTab(){
            return this.active_tab == 2
        },

        activeActionsTab(){
            return this.active_tab == 3
        },

        activeTimelinesTab(){
            return this.active_tab == 4
        },

        activeActivitiesTab(){
            return this.active_tab == 5
        },

        filesTabLabel(){
            return `${this.translations.core.view_btn_files} (${this.data.files_count})`
        }
    },

    watch: {
        'data.reload.ticket'(){
            if(this.data.reload.ticket){
                this.getTicket()
                this.$nextTick(()=>{
                    this.data.reload.ticket = false
                })
            }
        }
    }
}
</script>
<template>
    <section v-if="ticket" class="application-component">
        <component-subscription
            cloud-module="help/ticket"
            :cloud-id="ticket_id"
            @unsubscribed="setSubscriptionsInactive"
            @subscribed="setSubscriptionsActive"
        >
        </component-subscription>
        <component-title
            v-if="ticket"
            :id="ticket.id"
            :subject="ticket.subject"
            :status="
                object_utils.translateEnum(translations.core, 'column_enum_status', ticket.status, null) ||
                object_utils.translateEnum(translations.workflow_statuses, 'column_enum_status', ticket.status)
            "
        >
            <template v-slot:custom-title>
                <div :class="['navbar-item is-clickable', {'has-text-warning': ticket.subscribed}]" @click="showSubscriptionsPanel">
                    &nbsp;
                    <i :class="['fa-lg', {'far fa-bell': ! ticket.subscribed, 'fas fa-bell': ticket.subscribed}]"></i>
                </div>
            </template>
            <template v-slot:actions>
                <div class="navbar-item">
                    <component-workflow-transition
                        v-if="!data.reload.ticket"
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
                        <router-link class="button" :to="`${appMountPath}/`">
                            <b-icon icon="list" size="is-small" />
                            <span>{{ translations.core.view_btn_list }}</span>
                        </router-link>
                        <router-link class="button" :to="`${appMountPath}/${ticket_id}`">
                            <b-icon icon="eye" size="is-small" />
                            <span>{{ translations.core.view_btn_show }}</span>
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
                <component-form v-if="data.ticket" :app-mount-path="appMountPath" view-type="edit" :expanded-tabs="expandedTabs"></component-form>
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

            <b-tab-item :label="filesTabLabel">
                <component-file
                    :translations-file-types-paths="['help.ticket/files']"
                    cloud-module="help/ticket"
                    :cloud-id="ticket_id"
                    :active="activeFilesTab"
                >
                </component-file>
            </b-tab-item>

            <b-tab-item :label="translations.core.view_text_quick_actions">
                <component-actions
                    cloud-module="help/ticket"
                    :cloud-id="ticket_id"
                    :active="activeActionsTab"
                >
                </component-actions>
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
