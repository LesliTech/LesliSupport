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
export default {
    data() {
        return {
            translations:{
                shared: I18n.t('cloud_help.ticket_workflows.shared')
            },
            ticket_workflows: []
        }
    },
    
    mounted() {
        this.getTicketWorkflows()
    },

    methods: {

        getTicketWorkflows() {
            this.http.get('/help/ticket_workflows.json').then(result => {
                if (result.successful) {
                    this.ticket_workflows = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        showTicketWorkflow(ticket_workflow) {
            this.$router.push(`/${ticket_workflow.id}`)
        }

    }
}
</script>
<template>
    <section class="section">
        <b-table :data="ticket_workflows" @click="showTicketWorkflow" :hoverable="true">
            <template slot-scope="props">
                <b-table-column field="id" :label="translations.shared.fields.id">
                    {{ props.row.id }}
                </b-table-column>
                <b-table-column field="name" :label="translations.shared.fields.name">
                    {{ props.row.name}}
                    <span v-if="props.row.default" class="has-text-weight-bold">
                        ({{translations.shared.fields.default}})
                    </span>
                </b-table-column>
                <b-table-column field="created_at" :label="translations.shared.fields.created_at">
                    {{ date.toLocalFormat(props.row.created_at, true) }}
                </b-table-column>
                <b-table-column field="updated_at" :label="translations.shared.fields.updated_at">
                    {{ date.toLocalFormat(props.row.updated_at, true) }}
                </b-table-column>
            </template>
        </b-table>
    </section>
</template>
<style>
    table tr:hover {
        cursor: pointer;
    }
</style>
