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
import componentSubscription from 'LesliCoreVue/cloud_objects/subscription.vue'
import componentDiscussion from 'LesliCoreVue/cloud_objects/discussion.vue'
import componentActivity from 'LesliCoreVue/cloud_objects/activity.vue'
import componentAction from 'LesliCoreVue/cloud_objects/action.vue'
import componentFile from 'LesliCoreVue/cloud_objects/file.vue'
import componentWorkflowTransition from 'LesliCoreVue/cloud_objects/workflows/components/transition.vue'
import componentWorkflowChart from 'LesliCoreVue/cloud_objects/workflows/components/chart.vue'
import componentFormStatus from '../components/status.vue'
import componentFormTag from '../components/tag.vue'
import componentForm from '../components/form.vue'





// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-workflow-transition': componentWorkflowTransition,
        'component-workflow-chart': componentWorkflowChart,
        'component-subscription': componentSubscription,
        'component-form-status': componentFormStatus,
        'component-discussion': componentDiscussion,
        'component-activity': componentActivity,
        'component-form-tag': componentFormTag,
        'component-action': componentAction,
        'component-file': componentFile,
        'component-form': componentForm
    },
    data() {
        return {
            translations: I18n.t('cloud_help.tickets.edit'),
            ticket_id: null,
            ticket: null,
            rerender_chart: false
        }
    },
    mounted() {
        this.ticket_id = this.$route.params.id
        this.getTicket()
        this.setSubscriptions()
    },
    methods: {

        setSubscriptions(){
            this.bus.subscribe('update:/help/ticket/workflow', (state)=>{
                this.ticket.detail_attributes.cloud_help_workflow_states_id = state.id
                this.ticket.detail_attributes.state = state.name
                this.ticket.detail_attributes.state_initial = state.initial
            })
        },

        // We publish the ticket so the form can use it
        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }

    }
}
</script>
<template>
    <section v-if="ticket">
        <div class="columns">
            <div class="column is-8">
                <component-form class="box"
                    :ticket-data="ticket"
                />
                <div class="card box">
                    <div class="card-header">
                        <h4 class="card-header-title">
                            {{translations.titles.workflow}}
                        </h4>
                    </div>
                    <div class="card-content">
                        <component-workflow-chart
                            :rerender.sync="rerender_chart"
                            :workflow-id="ticket.detail_attributes.cloud_help_workflows_id"
                            :selected-workflow-state="ticket.detail_attributes.cloud_help_workflow_states_id"
                            cloud-module="help/ticket"
                        />
                    </div>
                </div>
            </div>
            <div class="column is-4">
                <component-workflow-transition
                    class="box"
                    cloud-module="help/ticket"
                    :cloud-id="ticket_id"
                />
                <component-form-status class="box" :state="ticket.detail_attributes.state" :creation-date="ticket.created_at"/>
                <component-form-tag class="box" :ticket="ticket"/>
            </div>
        </div>
        <div class="columns">
            <div class="column">
                <component-discussion cloud-module="help/ticket" :cloud-id="ticket_id"/>
            </div>
            <component-subscription cloud-module="help/ticket" :cloud-id="ticket_id" />
            <component-action cloud-module="help/ticket" :cloud-id="ticket_id" />
            <component-file cloud-module="help/ticket" :cloud-id="ticket_id" />
            <component-activity cloud-module="help/ticket" :cloud-id="ticket_id" />
        </div>
    </section>
</template>
