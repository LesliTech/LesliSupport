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
import componentTicketStateName from '../../components/ticket_state_name.vue'

// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-discussion-form': componentDiscussionForm,
        'component-discussion-list': componentDiscussionList,
        'component-action-list': componentActionList,
        'component-file-list': componentFileList,
        'component-ticket-state-name': componentTicketStateName
    },
    data() {
        return {
            translations:{
                shared: I18n.t('cloud_help.tickets.shared')
            },
            ticket_options: null,
            ticket_id: null,
            ticket: null
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
    <div class="columns" v-if="ticket && ticket_options">
        <div class="column">
            <div class="card box">
                <div class="card-header">
                    <h4 class="card-header-title">
                        {{ ticket.detail_attributes.subject }}
                    </h4>
                    <div class="card-header-icon">
                        <router-link :to="`/${ticket_id}/edit`">
                            <i class="fas fa-edit"></i>
                            {{translations.shared.actions.edit}}
                        </router-link>
                        <router-link :to="'/'">
                            &nbsp;&nbsp;&nbsp;
                            <i class="fas fa-undo"></i>
                            {{translations.shared.actions.return}}
                        </router-link>
                    </div>
                    
                </div>
                <div class="card-content">
                    <div class="columns">
                        <div class="column is-10">
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.category}:` }}
                            </span>
                            {{ ticket.detail_attributes.category}}, 
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.type}:` }}
                            </span>
                            {{ ticket.detail_attributes.type}}, 
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.state}:` }}
                            </span>
                            <component-ticket-state-name :name="ticket.detail_attributes.state">
                            </component-ticket-state-name>
                        </div>
                        <div class="column is-2 has-text-right">
                            <span class="has-text-weight-bold is-size-5">
                                {{ `${translations.shared.fields.priority}:` }}
                                <span class="has-text-danger">
                                    {{ ticket.detail_attributes.priority}}
                                </span>
                            </span>
                        </div>
                    </div>
                    <div class="columns">
                        <div class="column">
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.description}:` }}
                            </span>
                            <div v-html="ticket.detail_attributes.description"></div>
                        </div>
                    </div>
                    <div class="columns">
                        <div class="column">
                            <span class="has-text-weight-bold">
                                {{ `Created by:` }}
                            </span>
                            {{ ticket.detail_attributes.email}} at 
                            {{ticket.created_at}}
                        </div>
                    </div>
                </div>
            </div>
            <component-discussion-form cloud-module="help/ticket" :cloud-id="ticket_id" class="box"/>
            <component-discussion-list cloud-module="help/ticket" :cloud-id="ticket_id" />
        </div>
        <component-action-list cloud-module="help/ticket" :cloud-id="ticket_id" />
        <component-file-list cloud-module="help/ticket" :cloud-id="ticket_id" />
    </div>
</template>
