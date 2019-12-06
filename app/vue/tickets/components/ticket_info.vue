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
import componentTicketStateName from "../../components/ticket_state_name.vue";

// · Component ticket_info_display
// · ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~
export default {
    props:{
        ticket: {
            type: Object,
            default(){
                return {
                    detail_attributes: {},
                    assignment_attributes: {}
                }
            }
        }
    },
    components: {
        'component-ticket-state-name': componentTicketStateName
    },
    data(){
        return {
            translations: I18n.t('cloud_help.tickets.shared')
        }
    }
}
</script>
<template>
    <section>
        <div class="columns">
            <div class="column is-8">
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
                <component-ticket-state-name :name="ticket.detail_attributes.state"></component-ticket-state-name>
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
            <div class="column is-8">
                <span class="has-text-weight-bold">{{ translations.titles.created_by }}:</span>
                {{ ticket.detail_attributes.email}}
                <br />
                <span class="has-text-weight-bold">{{translations.titles.date}}:</span>
                {{ date.toLocalFormat(ticket.created_at, false, true) }}
                <br />
                <span class="has-text-weight-bold">{{translations.titles.assigned}}:</span>
                {{ticket.assignment_attributes.assignable_name}}
                ({{translations.assignation_types[ticket.assignment_attributes.assignation_type]}})
            </div>
            <div class="column is-4 has-text-bottom">
                <slot name="actions">
                </slot>
            </div>
        </div>
    </section>
</template>
<style scoped>
.has-text-bottom{
    margin-top: auto;
}
</style>
