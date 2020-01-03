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

@dev      Luis Donis <ldonis@lesli.tech>
@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/



// · Import modules, components and apps
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentDiscussionList from 'LesliCloud/vue/components/lists/discussion.vue'
import componentDiscussionForm from 'LesliCloud/vue/components/forms/discussion.vue'
import componentActionList from 'LesliCloud/vue/components/lists/action.vue'
import componentFileList from 'LesliCloud/vue/components/lists/file.vue'
import componentFormStatus from '../components/status.vue'
import componentFormTag from '../components/tag.vue'
import componentForm from '../components/form.vue'
import componentWorkflowChart from '../../components/workflow_chart.vue'
import VueTrix from "vue-trix"



// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-discussion-form': componentDiscussionForm,
        'component-discussion-list': componentDiscussionList,
        'component-action-list': componentActionList,
        'component-file-list': componentFileList,
        'component-form-status': componentFormStatus,
        'component-form-tag': componentFormTag,
        'component-form': componentForm,
        'component-workflow-chart': componentWorkflowChart,
        'component-trix-editor': VueTrix
    },
    data() {
        return {
            translations: I18n.t('cloud_help.tickets.edit'),
            ticket_workflow: null,
            ticket_id: null,
            ticket: {
                detail_attributes: {}
            },
            rerender_chart: false
        }
    },
    mounted() {
        this.ticket_id = this.$route.params.id
        this.getTicket()
    },
    methods: {

        getTicketWorkflow() {
            let id = this.ticket.detail_attributes.cloud_help_ticket_workflows_id
            this.http.get(`/help/ticket_workflows/${id}.json`).then(result => {
                if (result.successful) {
                    this.ticket_workflow = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        // We publish the ticket so the form can use it
        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket = result.data
                    this.bus.publish("get:/help/ticket", this.ticket)
                    this.getTicketWorkflow()
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        updateTicketWorkflow(state) {
            this.ticket.detail_attributes.cloud_help_ticket_states_id = state.id
            this.ticket.detail_attributes.state = state.state_name
            this.rerender_chart = true
        }

    }
}
</script>
<template>
    <section v-if="ticket">
        <div class="columns">
            <div class="column is-8">
                <component-form v-on:update-ticket-workflow="updateTicketWorkflow"/>
            </div>
            <div class="column is-4">
                <component-form-status class="box" :state="ticket.detail_attributes.state" :creation_date="ticket.created_at"/>
                <component-form-tag class="box" :ticket="ticket"/>
            </div>
        </div>
        <div class="columns">
            <div class="column">
                <div class="card box">
                    <div class="card-header">
                        <h4 class="card-header-title">
                            {{translations.titles.workflow}}
                        </h4>
                    </div>
                    <div class="card-content">
                        <component-workflow-chart 
                            v-if="ticket_workflow"
                            :rerender.sync="rerender_chart"
                            :workflow="ticket_workflow.details"
                            :selected_node="ticket.detail_attributes.cloud_help_ticket_states_id"
                        >
                        </component-workflow-chart>
                    </div>
                </div>
                <component-discussion-form cloud-module="help/ticket" :cloud-id="ticket_id" class="box"/>
                <component-discussion-list cloud-module="help/ticket" :cloud-id="ticket_id" />
            </div>
            <component-action-list cloud-module="help/ticket" :cloud-id="ticket_id" />
            <component-file-list cloud-module="help/ticket" :cloud-id="ticket_id" />
        </div>
    </section>
</template>
