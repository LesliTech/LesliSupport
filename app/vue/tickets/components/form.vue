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
import componentTicketStateName from "../../components/ticket_state_name.vue"



// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-trix-editor': VueTrix,
        'component-ticket-state-name': componentTicketStateName
    },
    data() {
        return {
            translations:{
                shared: I18n.t('cloud_help.tickets.shared'),
                form: I18n.t('cloud_help.tickets.form')
            },
            ticket_options: {
                types: [],
                categories: [],
                priorities: []
            },
            ticket_id: null,
            ticket_follow_up_states: [],
            ticket_follow_up_state: null,
            ticket: {
                detail_attributes: {}
            },
            modals: {
                escalate: false
            }
        }
    },
    mounted() {
        if (this.$route.params.id) {
            this.ticket_id = this.$route.params.id
            this.getTicket()
            this.getFollowUpStates()
        }
        this.getTicketOptions()
    },
    methods: {

        putTicket(e) {
            if (e) { e.preventDefault() }
            this.http.put(`/help/tickets/${this.ticket_id}`, {
                ticket: this.ticket
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.form.messages.update.successful)
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        postTicket(e) {
            if (e) { e.preventDefault() }
            this.http.post("/help/tickets", {
                ticket: this.ticket
            }).then(result => {
                if (result.successful) {
                    this.ticket = result.data
                    this.alert(this.translations.form.messages.create.successful)
                    this.$router.push(`/${this.ticket.id}`)
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket = result.data
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getFollowUpStates() {
            this.http.get(`/help/api/tickets/${this.ticket_id}/follow_up_states`).then(result =>{
                if (result.successful) {
                    this.ticket_follow_up_states = result.data
                    if(result.data.length > 0){
                        this.ticket_follow_up_state = result.data[0].workflow_id
                    }
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getTicketOptions() {
            this.http.get('/help/api/tickets/options').then(result => {
                if (result.successful) {
                    this.ticket_options = result.data
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        putTicketWorkflow(){
            let data = {
                workflow_id: this.ticket_follow_up_state
            }
            this.http.put(`/help/api/tickets/${this.ticket_id}/workflow`, data).then(result =>{
                if (result.successful) {
                    this.alert(this.translations.form.messages.update_workflow.successful)
                    if(this.ticket.detail_attributes.cloud_help_ticket_workflows_id != this.ticket_follow_up_state){
                        this.ticket.detail_attributes.cloud_help_ticket_workflows_id = this.ticket_follow_up_state
                        this.getFollowUpStates()
                        this.$emit('update-ticket-workflow', result.data)
                    }
                } else {
                    this.alert(result.error.message, 'danger')
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
                    {{translations.shared.name}}
                </h2>
                <div class="card-header-icon">
                    <router-link v-if="ticket_id" :to="`/${ticket_id}`">
                        <i class="fas fa-eye"></i>
                        {{translations.shared.actions.show}}
                    </router-link>
                    <router-link :to="`/`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        {{translations.shared.actions.return}}
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <form>
                    <div class="columns">
                        <div class="column is-12">
                            <b-field :label="translations.shared.fields.subject">
                                <b-input v-model="ticket.detail_attributes.subject" :readonly="ticket_id != null"></b-input>
                            </b-field>
                        </div>
                    </div>
                    <div class="columns">
                        <div class="column is-4">
                            <b-field :label="translations.shared.fields.type">
                                <b-select 
                                    :placeholder="translations.form.placeholders.select_type"
                                    expanded
                                    v-model="ticket.detail_attributes.cloud_help_ticket_types_id"
                                >
                                    <option
                                        v-for="type in ticket_options.types"
                                        :key="type.id"
                                        :value="type.id"
                                        :disabled="ticket_id != null"
                                    >
                                        {{type.name}}
                                    </option>
                                </b-select>
                            </b-field>
                        </div>
                        <div class="column is-4">
                            <b-field :label="translations.shared.fields.category">
                                <b-select
                                    :placeholder="translations.form.placeholders.select_category"
                                    expanded
                                    v-model="ticket.detail_attributes.cloud_help_ticket_categories_id"
                                >
                                    <option
                                        v-for="category in ticket_options.categories"
                                        :key="category.id"
                                        :value="category.id"
                                        :disabled="ticket_id != null"
                                    >   
                                        <span v-for="i in category.depth" :key="`${category.id}_${i}`">--</span>
                                        {{category.name}}
                                    </option>
                                </b-select>
                            </b-field>
                        </div>
                        <div class="column is-4">
                            <b-field :label="translations.shared.fields.priority">
                                <b-select
                                    :placeholder="translations.form.placeholders.select_priority"
                                    expanded
                                    v-model="ticket.detail_attributes.cloud_help_ticket_priorities_id"
                                >
                                    <option
                                        v-for="priority in ticket_options.priorities"
                                        :key="priority.id"
                                        :value="priority.id"
                                        :disabled="ticket_id != null"
                                    >
                                        {{priority.name}}
                                    </option>
                                </b-select>
                            </b-field>
                        </div>
                    </div>
                    <div class="field">
                        <label class="label">{{translations.shared.fields.description}}</label>
                        <div class="control">
                            <component-trix-editor 
                                :disabledEditor="$route.params.id != null"
                                v-model="ticket.detail_attributes.description"
                            ></component-trix-editor>
                        </div>
                    </div>
                    <div v-if="ticket_id">
                        <label class="label">{{translations.form.labels.move_to_another_state}}</label>
                        <div class="columns">
                            <div class="column is-9">
                                <div class="field">
                                    <div class="control">
                                        <b-select
                                            :placeholder="translations.form.placeholders.select_category"
                                            expanded
                                            v-model="ticket_follow_up_state"
                                        >
                                            <option
                                                v-for="state in ticket_follow_up_states"
                                                :key="state.workflow_id"
                                                :value="state.workflow_id"
                                            >
                                                <component-ticket-state-name :name="state.state_name"/>
                                            </option>
                                        </b-select>
                                    </div>
                                </div>
                            </div>
                            <div class="column is-3">
                                <div class="field">
                                    <div class="actions has-text-right">
                                        <button class="button is-primary is-fullwidth" type="button" @click="putTicketWorkflow">
                                            {{translations.form.actions.update}}
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="field">
                        <div v-if="!ticket_id" class="actions has-text-right">
                            <button class="button is-primary" type="submit" @click="postTicket">
                                {{translations.form.actions.create}}
                            </button>
                        </div>
                        <div v-else class="actions has-text-right">
                            <button class="button is-danger" type="button" @click="modals.escalate = true">
                                {{translations.form.actions.escalate}}
                            </button>
                            <button class="button is-warning has-text-white" type="button">
                                {{translations.form.actions.transfer}}
                            </button>
                            <button class="button is-success" type="button">
                                {{translations.form.actions.descalate}}
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</template>
