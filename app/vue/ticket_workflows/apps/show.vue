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
import componentChart from '../components/chart.vue'

export default {
    components: {
        'component-chart': componentChart
    },
    data() {
        return {
            translations: {
                shared: I18n.t('cloud_help.ticket_workflows.shared')
            },
            ticket_workflow: {},
            ticket_workflow_id: null
        }
    },
    mounted() {
        // · SetTicketWorkflowId calls getTicketWorkflow
        this.setTicketWorkflowId()
    },
    methods: {
        
        setTicketWorkflowId(){
            if (this.$route.params.id) {
                this.ticket_workflow_id = this.$route.params.id
                this.getTicketWorkflow()
            }
        },

        getTicketWorkflow() {
            this.http.get(`/help/ticket_workflows/${this.ticket_workflow_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket_workflow = result.data
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
    <section>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    {{ translations.shared.name }}
                </h2>
                <div class="card-header-icon">
                    <router-link :to="`/${ticket_workflow_id}/edit`">
                        <i class="fas fa-edit"></i>
                        {{ translations.shared.actions.edit }}
                    </router-link>
                    <router-link :to="`/`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        {{ translations.shared.actions.return }}
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <div class="columns">
                    <div class="column">
                        <p v-if="Object.keys(ticket_workflow).length > 0">
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.ticket_category_name}:` }}
                            </span>
                            {{ ticket_workflow[1].ticket_category_name }},
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.ticket_type_name}:` }}
                            </span>
                            {{ ticket_workflow[1].ticket_type_name }}
                        </p>
                    </div>
                </div>
                <component-chart :workflow="ticket_workflow">
                </component-chart>
            </div>
        </div>
    </section>
</template>
