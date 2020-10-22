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
import componentRichTextEditor from 'LesliCoreVue/components/forms/richtext-editor.vue'



// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-rich-text-editor': componentRichTextEditor
    },

    props: {
        ticketData: {
            default: null
        }
    },

    data() {
        return {
            translations:{
                shared: I18n.t('cloud_help.tickets.shared'),
                form: I18n.t('cloud_help.tickets.form'),
                modals: I18n.t('cloud_help.tickets.modals')
            },
            ticket_options: {
                types: [],
                categories: [],
                priorities: []
            },
            ticket_id: null,
            ticket: {
                detail_attributes: {}
            },
            transfer: {},
            modals: {
                escalate: false,
                descalate: false,
                transfer: false
            }
        }
    },
    mounted() {
        this.setTicketId()
        this.setTicket()
        this.setSubscriptions()
        this.getTicketOptions()
    },
    methods: {
        setTicketId(){
            this.ticket_id = this.$route.params.id
        },

        setTicket(){
            if(this.ticketData){
                this.ticket = {... this.ticketData}
            }
        },
        
        setSubscriptions(){
            
            this.bus.subscribe('update:/help/ticket/workflow', (status)=>{
                this.ticket.cloud_help_ticket_workflow_statuses_id = status.id
                this.ticket.status = status.name
                this.ticket.status_initial = status.initial
                this.ticket.status_final = status.final
                this.ticket.status_name = status.name
                this.rerender_chart = true
            })
        },

        postTicket(e) {
            if (e) { e.preventDefault() }
            this.http.post('/help/tickets', {
                ticket: this.ticket
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.form.messages.create.successful)
                    this.$router.push(`/${result.data.id}`)
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getTicketOptions() {
            this.http.get('/help/options/tickets').then(result => {
                if (result.successful) {
                    this.ticket_options = result.data
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        escalateTicket(){
            let next_priority = this.ticket_options.priorities.filter( priority => {
                return priority.weight > this.ticket.priority_weight
            }).sort()

            this.modals.escalate = false
            if(next_priority.length > 0){
                this.patchTicketPriority('escalate', next_priority[0])
            }else{
                this.alert(translations.form.errors.ticket_at_max_priority, 'error')
            }
        },

        descalateTicket(){
            let next_priority = this.ticket_options.priorities.filter( priority => {
                return priority.weight < this.ticket.priority_weight
            }).sort( (a, b)=>{
                return b - a
            })

            this.modals.escalate = false
            if(next_priority.length > 0){
                this.patchTicketPriority('descalate', next_priority[0])
            }else{
                this.alert(translations.form.errors.ticket_at_min_priority, 'error')
            }
        },

        // Used by escalateTicket and descalateTicket. action has to either be 'escalate' or 'descalate'
        patchTicketPriority(action, priority){
            let data = {
                ticket: {
                    cloud_help_catalog_ticket_priorities_id: priority.id
                }
            }

            this.http.patch(`/help/tickets/${this.ticket_id}`, data).then(result => {
                if (result.successful) {
                    this.alert(this.translations.modals[action].messages.successful)
                    this.$router.push(`/${this.ticket.id}`)
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        putTicketTransfer(e){
            if (e) { e.preventDefault() }

            let data = {
                ticket: this.transfer
            }

            this.modals.transfer = false
            this.http.put(`/help/tickets/${this.ticket_id}`, data).then(result => {
                if (result.successful) {
                    this.alert(this.translations.modals.transfer.messages.successful)
                    this.$router.push(`/${this.ticket.id}`)
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
    <div class="card">
        <b-modal 
            :active.sync="modals.escalate"
            has-modal-card
            trap-focus
            aria-role="dialog"
            aria-modal
        >
            <div class="card">
                <div class="card-header is-danger">
                    <h2 class="card-header-title">
                        {{ translations.modals.escalate.title }}
                    </h2>
                </div>
                <div class="card-content">
                    {{ translations.modals.escalate.body }}
                </div>
                <div class="card-footer has-text-right">
                    <button class="card-footer-item button is-danger" @click="escalateTicket">
                        {{ translations.modals.escalate.actions.escalate }}
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modals.escalate=false">
                        {{ translations.modals.escalate.actions.cancel }}
                    </button>
                </div>
            </div>
        </b-modal>
        <b-modal 
            :active.sync="modals.descalate"
            has-modal-card
            trap-focus
            aria-role="dialog"
            aria-modal
        >
            <div class="card">
                <div class="card-header is-danger">
                    <h2 class="card-header-title">
                        {{ translations.modals.descalate.title }}
                    </h2>
                </div>
                <div class="card-content">
                    {{ translations.modals.descalate.body }}
                </div>
                <div class="card-footer has-text-right">
                    <button class="card-footer-item button is-danger" @click="descalateTicket">
                        {{ translations.modals.descalate.actions.descalate }}
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modals.descalate=false">
                        {{ translations.modals.descalate.actions.cancel }}
                    </button>
                </div>
            </div>
        </b-modal>
        <b-modal 
            :active.sync="modals.transfer"
            has-modal-card
            trap-focus
            aria-role="dialog"
            aria-modal
        >
            <div class="card">
                <div class="card-header is-danger">
                    <h2 class="card-header-title">
                        {{ translations.modals.transfer.title }}
                    </h2>
                </div>
                <div class="card-content">
                    {{ translations.modals.transfer.body.warning }}
                    {{ translations.modals.transfer.body.instructions }}
                    <hr>
                    <form id="form-transfer" @submit="putTicketTransfer">
                        <div class="columns">
                            <div class="column is-6">
                                <b-field :label="translations.modals.transfer.fields.type">
                                    <b-select 
                                        :placeholder="translations.form.placeholders.select_type"
                                        expanded
                                        v-model="transfer.cloud_help_catalog_ticket_types_id"
                                        :required="true"
                                    >
                                        <option
                                            v-for="type in ticket_options.types"
                                            :key="type.id"
                                            :value="type.id"
                                        >
                                            {{type.name}}
                                        </option>
                                    </b-select>
                                </b-field>
                            </div>
                            <div class="column is-6">
                                <b-field :label="translations.modals.transfer.fields.category">
                                    <b-select
                                        :placeholder="translations.form.placeholders.select_category"
                                        expanded
                                        v-model="transfer.cloud_help_catalog_ticket_categories_id"
                                        :required="true"
                                    >
                                        <option
                                            v-for="category in ticket_options.categories"
                                            :key="category.id"
                                            :value="category.id"
                                        >   
                                            <span v-for="i in category.depth" :key="`${category.id}_${i}`">--</span>
                                            {{category.name}}
                                        </option>
                                    </b-select>
                                </b-field>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="card-footer has-text-right">
                    <button class="card-footer-item button is-danger" type="submit" form="form-transfer">
                        {{ translations.modals.transfer.actions.transfer }}
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modals.transfer=false">
                        {{ translations.modals.transfer.actions.cancel }}
                    </button>
                </div>
            </div>
        </b-modal>
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
                                v-model="ticket.cloud_help_catalog_ticket_types_id"
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
                                v-model="ticket.cloud_help_catalog_ticket_categories_id"
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
                                v-model="ticket.cloud_help_catalog_ticket_priorities_id"
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
                    <div class="control" v-if="$route.params.id == null">
                        <component-rich-text-editor
                            v-model="ticket.detail_attributes.description"
                        />
                    </div>
                    <div class="control" v-else>
                        <div v-html="ticket.detail_attributes.description">
                        </div>
                    </div>
                </div>
                <hr v-if="ticket_id" class="is-divider" />
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
                        <button class="button is-danger" type="button" @click="modals.descalate = true">
                            {{translations.form.actions.descalate}}
                        </button>
                        <button 
                            v-if="ticket.status_initial"
                            class="button is-danger"
                            type="button" @click="modals.transfer = true"
                        >
                            {{translations.form.actions.transfer}}
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</template>
<style scoped>
.is-divider {
    background-color: #F14668;
}
</style>
