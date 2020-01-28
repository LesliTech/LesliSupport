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

@dev            Luis Donis <ldonis@lesli.tech>
@author     LesliTech <hello@lesli.tech>
@license    Propietary - all rights reserved.
@version    0.1.0-alpha

// · ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~
// · 
*/

// · Import modules, components and apps
// · ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~
import componentSubscription from 'LesliCoreVue/cloud_objects/subscription.vue'
import componentDiscussion from 'LesliCoreVue/cloud_objects/discussion.vue'
import componentActivity from 'LesliCoreVue/cloud_objects/activity.vue'
import componentAction from 'LesliCoreVue/cloud_objects/action.vue'
import componentFile from 'LesliCoreVue/cloud_objects/file.vue'
import componentWorkflowStateName from 'LesliCoreVue/cloud_objects/workflow_states/components/name.vue'
import componentTimeline from '../components/timeline.vue'
import componentDeadline from '../components/deadline.vue'
import componentAssignment from '../components/assignment.vue'

// · Component show
// · ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~
export default {
    components: {
        'component-discussion': componentDiscussion,
        'component-action': componentAction,
        'component-file': componentFile,
        'component-timeline': componentTimeline,
        'component-ticket-info': componentWorkflowStateName,
        'component-subscription': componentSubscription,
        'component-deadline': componentDeadline,
        'component-assignment': componentAssignment,
        'component-workflow-state-name': componentWorkflowStateName
    },
    data() {
        return {
            translations: I18n.t("cloud_help.tickets.shared"),
            ticket_id: null,
            ticket: null
        }
    },
    mounted() {
        this.ticket_id = this.$route.params.id
        this.getTicket()
        this.subscribeToDeadline()
        this.subscribeToAssignment()
    },
    methods: {

        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}.json`)
            .then(result => {
                if (result.successful) {
                    this.ticket = result.data;
                }else{
                    this.alert(result.error.message,"danger")
                }
            })
            .catch(error => {
                console.log(error);
            });
        },

        showDeadlineForm(){
            this.bus.publish("show:/help/ticket/deadline")
        },

        showAssignmentForm(){
            this.bus.publish("show:/help/ticket/assignment")
        },
        
        subscribeToDeadline(){
            this.bus.subscribe('patch:/help/ticket/deadline', (deadline)=>{
                this.ticket.detail_attributes.deadline = deadline
            })
        },

        subscribeToAssignment(){
            this.bus.subscribe('patch:/help/ticket/assignment', (assignment)=>{
                this.ticket.assignment_attributes = assignment
            })
            this.bus.subscribe('post:/help/ticket/assignment', (assignment)=>{
                this.ticket.assignment_attributes = assignment
            })
        }
    }
};
</script>
<template>
    <div class="section">
        <div class="columns" v-if="ticket">
            <div class="column is-8">
                <div class="card box">
                    <div class="card-header">
                        <h4 class="card-header-title">{{ ticket.detail_attributes.subject }}</h4>
                        <div class="card-header-icon">
                            <div v-if="! ticket.detail_attributes.state_final">
                                <a @click="showDeadlineForm()">
                                    <b-icon icon="calendar-times" size="is-small" />
                                    {{translations.actions.deadline}}
                                </a>
                                <a @click="showAssignmentForm()">
                                    &nbsp;&nbsp;
                                    <b-icon icon="user-check" size="is-small" />
                                    {{translations.actions.assign}}
                                </a>
                                <router-link :to="`/${ticket_id}/edit`">
                                    &nbsp;&nbsp;
                                    <b-icon icon="edit" size="is-small" />
                                    {{translations.actions.edit}}
                                </router-link>
                            </div>
                            <router-link :to="'/'">
                                &nbsp;&nbsp;
                                <b-icon icon="undo" size="is-small" />
                                {{translations.actions.return}}
                            </router-link>
                        </div>
                    </div>
                    <div class="card-content">
                        <div class="columns">
                            <div class="column is-8">
                                <span class="has-text-weight-bold">
                                    {{translations.fields.id}}:
                                    {{ticket.id}}
                                </span>
                                <br>
                                <span class="has-text-weight-bold">{{translations.fields.category}}:</span>
                                {{ ticket.detail_attributes.category}}
                                <br>
                                <span
                                    class="has-text-weight-bold"
                                >{{translations.fields.type}}:</span>
                                {{ ticket.detail_attributes.type}},
                                <span
                                    class="has-text-weight-bold"
                                >{{translations.fields.state}}:</span>
                                <component-workflow-state-name 
                                    :name="ticket.detail_attributes.state"
                                    :translations-shared-path="'cloud_help.ticket_workflow_states.shared'"
                                />
                            </div>
                            <div class="column is-4 has-text-right">
                                <span class="has-text-weight-bold is-size-5">
                                    {{translations.fields.priority}}:
                                    <span
                                        class="has-text-danger"
                                    >
                                        {{ticket.detail_attributes.priority}}
                                    </span>
                                </span>
                            </div>
                        </div>
                        <div class="columns is-multiline">
                            <div class="column is-12">
                                <span class="has-text-weight-bold">{{translations.fields.description}}:</span>
                                <div v-html="ticket.detail_attributes.description"></div>
                            </div>
                            <div class="column is-12">
                                <span class="has-text-weight-bold">{{ translations.titles.created_by }}:</span>
                                {{ ticket.detail_attributes.email}}
                                <br />
                                <span class="has-text-weight-bold">{{translations.titles.date}}:</span>
                                {{ date.toLocalFormat(ticket.created_at, false, true) }}
                                <br />
                                <span class="has-text-weight-bold">{{translations.titles.assigned}}:</span>
                                {{ticket.assignment_attributes.assignable_name}}
                                ({{translations.assignation_types[ticket.assignment_attributes.assignation_type]}})
                                <br />
                                <div v-if="ticket.detail_attributes.deadline">
                                    <span class="has-text-weight-bold has-text-danger">
                                        {{translations.titles.deadline}}:
                                    </span>
                                    {{date.toLocalFormat(ticket.detail_attributes.deadline, false, true)}}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <component-discussion cloud-module="help/ticket" :cloud-id="ticket_id" />
            </div>
            <div class="column is-4">
                <component-timeline class="card box" />
            </div>
            <component-deadline :ticket-deadline="ticket.detail_attributes.deadline"/>
            <component-assignment :assigned-to="ticket.assignment_attributes.users_id"/>
            <component-action cloud-module="help/ticket" :cloud-id="ticket_id" />
            <component-file cloud-module="help/ticket" :cloud-id="ticket_id" />
            <component-subscription
                cloud-module="help/ticket"
                :cloud-id="ticket_id"
            />
        </div>
    </div>
</template>
<style scoped>
.has-text-bottom{
    margin-top: auto;
}
</style>
