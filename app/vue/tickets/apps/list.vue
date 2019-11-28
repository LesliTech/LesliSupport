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


// · Component list
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentTicketStateName from '../../components/ticket_state_name.vue'
export default {
    components: {
        'component-ticket-state-name': componentTicketStateName
    },
    data() {
        return {
            translations: {
                shared: I18n.t('cloud_help.tickets.shared') 
            },
            tickets: []
        }
    },
    mounted() {
        this.getTickets()
    },
    methods: {

        getTickets() {
            this.http.get("/help/tickets.json").then(result => {
                if (result.successful) {
                    this.tickets = result.data
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        clickTicket(ticket) {
            this.$router.push(`${ticket.id}`)
        }

    }
}
</script>
<template>
    <section class="section">
        <b-table :data="tickets" @click="clickTicket" :hoverable="true">
            <template v-slot="props">
                <b-table-column field="id" :label="translations.shared.fields.id" centered numeric width="40">
                    {{props.row.id}}
                </b-table-column>
                <b-table-column field="subject" :label="translations.shared.fields.subject">
                    {{props.row.subject}}
                </b-table-column>
                <b-table-column field="priority" :label="translations.shared.fields.priority">
                    {{props.row.priority}}
                </b-table-column>
                <b-table-column field="type" :label="translations.shared.fields.type">
                    {{props.row.type}}
                </b-table-column>
                <b-table-column field="category" :label="translations.shared.fields.category">
                    {{props.row.category}}
                </b-table-column>
                <b-table-column field="state" :label="translations.shared.fields.state">
                    <component-ticket-state-name :name="props.row.state">
                    </component-ticket-state-name>
                </b-table-column>
                <b-table-column field="created_at" :label="translations.shared.fields.created_at">
                    {{ date.toLocalFormat(props.row.created_at,true) }}
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
