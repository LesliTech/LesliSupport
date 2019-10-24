
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
import VueTrix from "vue-trix"
import componentDiscussionList from 'LesliCloud/vue/components/lists/discussion.vue'
import componentDiscussionForm from 'LesliCloud/vue/components/forms/discussion.vue'
import componentActionList from 'LesliCloud/vue/components/lists/action.vue'
import componentFormStatus from '../components/status.vue'
import componentFormState from '../components/state.vue'
import componentFormTag from '../components/tag.vue'
import componentFormType from '../components/type.vue'
import componentFormPriority from '../components/priority.vue'



// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-trix-editor': VueTrix,
        'component-discussion-form': componentDiscussionForm,
        'component-discussion-list': componentDiscussionList,
        'component-action-list': componentActionList,
        'component-form-status': componentFormStatus,
        'component-form-state': componentFormState,
        'component-form-tag': componentFormTag,
        'component-form-type': componentFormType,
        'component-form-priority': componentFormPriority
    },
    data() {
        return {
            ticket_options: {},
            ticket_id: null,
            ticket: {
                detail_attributes: {
                    subject: "",
                    description: "",
                    tags: "",
                    cloud_help_ticket_types_id: null
                }
            }
        }
    },
    mounted() {
        this.ticket_id = this.$route.params.id
        this.getTicket()
        this.getTicketOptions()
    },
    methods: {

        getTicketOptions() {
            this.http.get('/help/api/tickets/options').then(result => {
                if (result.successful) {
                    this.ticket_options = result.data
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket = result.data
                }
            }).catch(error => {
                console.log(error)
            })
        }

    }
}
</script>
<template>
    <div class="columns">
        <div class="column is-8">
            <div class="card box">
                <div class="card-header">
                    <h4 class="card-header-title">
                        {{ ticket.detail_attributes.subject }}
                    </h4>
                    <a class="card-header-icon" @click="bus.$emit('show:/help/ticket/actions')">
                        actions
                    </a>
                    <router-link :to="`/${ticket_id}/edit`" class="card-header-icon">
                        edit
                    </router-link>
                </div>
                <div class="card-content">
                    <div v-html="ticket.detail_attributes.description"></div>
                </div>
            </div>
            <component-discussion-form class="box" cloud-module="help/ticket" :cloud-object-id="ticket_id" />
            <component-discussion-list cloud-module="help/ticket" :cloud-object-id="ticket_id" />
        </div>
        <div class="column is-4">
            <component-form-status class="box" />
            <component-form-tag v-if="ticket.detail_attributes" :ticket_id="ticket_id" :ticket_tags="ticket.detail_attributes.tags" class="box" />
            <component-form-type v-if="ticket.detail_attributes" :ticket_id="ticket_id" :ticket_type="ticket.detail_attributes.cloud_help_ticket_types_id" :options="ticket_options.types" class="box" />
            <component-form-state v-if="ticket.detail_attributes" :ticket_id="ticket_id" :ticket_state="ticket.detail_attributes.cloud_help_ticket_states_id" :options="ticket_options.states" class="box" />
            <component-form-priority v-if="ticket.detail_attributes" :ticket_id="ticket_id" :ticket_priority="ticket.detail_attributes.cloud_help_ticket_priorities_id" :options="ticket_options.priorities" class="box" />
        </div>
        <component-action-list v-if="ticket_id" cloud-module="help/ticket" :cloud-id="ticket_id" />
    </div>
</template>
