<script>
/*
Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// ·
*/


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentRichTextEditor from 'LesliCoreVue/components/forms/richtext-editor.vue'
import DatePicker from 'v-calendar/lib/components/date-picker.umd'

// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-rich-text-editor': componentRichTextEditor,
        'vc-date-picker': DatePicker
    },

    props: {
        ticketData: {
            required: true
        },

        viewType: {
            type: String,
            default: 'new'
        }
    },

    data() {
        return {
            main_route: '/help/tickets',
            submitting: false,
            deleting: false,
            translations:{
                main: I18n.t('help.tickets'),
                core: I18n.t('core.shared'),
                shared: I18n.t('help.shared')
            },
            options: {
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
        this.copyTicketProp()
        this.setSubscriptions()
        this.getTicketOptions()
    },
    methods: {
        setTicketId(){
            this.ticket_id = this.$route.params.id
        },

        copyTicketProp(){
            this.ticket = {... this.ticketData}
        },
        
        setSubscriptions(){
            this.bus.subscribe('update:/help/ticket/workflow', (status)=>{
                this.ticket.cloud_help_ticket_workflow_statuses_id = status.id
                this.ticket.status = status.name
                this.ticket.status_type = status.status_type
                this.rerender_chart = true
            })
        },

        // @return [void]
        // @description Catches the submit event of the HTML form, and prevents its default behavior. Depending on the
        //      value of the *viewType* variable, executes a method that sends and HTTP post or put to the lesli API
        //  @example
        //      this.submitTicket() // will trigger a post if viewMode is 'new' or a put if viewMode is 'edit'
        submitTicket(event){
            if (event) { event.preventDefault() }

            if(this.viewType == 'new'){
                this.postTicket()
            }else if(this.viewType == 'edit'){
                this.putTicket()
            }
        },

        postTicket(event) {
            if(event){
                e.preventDefault()
            }
            let data = {
                ticket: this.ticket
            }
            this.submitting = true

            this.http.post(this.main_route, data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_info_ticket_created, 'success')
                    this.$router.push(`/${result.data.id}`)
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        // @return [void]
        // @description Connects to the backend using HTTP to update an existing Ticket priority under the current user's
        //      account. The id of the Ticket priority is provided in the *id* route param. If the HTTP request fails,
        //      an error message is shown
        // @example
        //      this.putTicket() // will update the record and redirect to it's show app
        putTicket() {
            let data = {
                ticket: this.ticket
            }
            let url = `${this.main_route}/${this.ticket_id}.json`
            this.submitting = true

            this.http.put(url, data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_info_ticket_updated, 'success')
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        getTicketOptions() {
            let url = `${this.main_route}/options`

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.options = result.data
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        escalateTicket(){
            let next_priority = this.options.priorities.filter( priority => {
                return priority.weight > this.ticket.priority_weight
            }).sort()

            this.modals.escalate = false
            if(next_priority.length > 0){
                this.patchTicket('escalate', next_priority[0])
            }else{
                this.alert(translations.form.errors.ticket_at_max_priority, 'error')
            }
        },

        descalateTicket(){
            let next_priority = this.options.priorities.filter( priority => {
                return priority.weight < this.ticket.priority_weight
            }).sort( (a, b)=>{
                return b - a
            })

            this.modals.escalate = false
            if(next_priority.length > 0){
                this.patchTicket('descalate', next_priority[0])
            }else{
                this.alert(translations.form.errors.ticket_at_min_priority, 'error')
            }
        },

        // Used by escalateTicket and descalateTicket. action has to either be 'escalate' or 'descalate'
        patchTicket(action, priority){
            let data = {
                ticket: {
                    cloud_help_catalog_ticket_priorities_id: priority.id
                }
            }
            let url = `${this.main_route}/${this.ticket_id}`
            this.submitting = true

            this.http.patch(url, data).then(result => {
                this.submitting = false

                if (result.successful) {
                    this.alert('this.translations.modals[action].messages.successful')
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        putTicketTransfer(event){
            if(event){
                event.preventDefault()
            }

            let data = {
                ticket: this.transfer
            }
            let url = `${this.main_route}/${this.ticket_id}`
            this.submitting = true
            this.modals.transfer = false


            this.http.put(url, data).then(result => {
                if (result.successful) {
                    this.alert('this.translations.modals.transfer.messages.successful')
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
                        {{ 'translations.modals.escalate.title' }}
                    </h2>
                </div>
                <div class="card-content">
                    {{ 'translations.modals.escalate.body' }}
                </div>
                <div class="card-footer has-text-right">
                    <button class="card-footer-item button is-danger" @click="escalateTicket">
                        {{ 'translations.modals.escalate.actions.escalate' }}
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modals.escalate=false">
                        {{ 'translations.modals.escalate.actions.cancel' }}
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
                        {{ 'translations.modals.descalate.title' }}
                    </h2>
                </div>
                <div class="card-content">
                    {{ 'translations.modals.descalate.body' }}
                </div>
                <div class="card-footer has-text-right">
                    <button class="card-footer-item button is-danger" @click="descalateTicket">
                        {{ 'translations.modals.descalate.actions.descalate' }}
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modals.descalate=false">
                        {{ 'translations.modals.descalate.actions.cancel' }}
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
                        {{ 'translations.modals.transfer.title' }}
                    </h2>
                </div>
                <div class="card-content">
                    {{ 'translations.modals.transfer.body.warning' }}
                    {{ 'translations.modals.transfer.body.instructions' }}
                    <hr>
                    <form id="form-transfer" @submit="putTicketTransfer">
                        <div class="columns">
                            <div class="column is-6">
                                <b-field :label="'translations.modals.transfer.fields.type'">
                                    <b-select 
                                        :placeholder="'translations.form.placeholders.select_type'"
                                        expanded
                                        v-model="transfer.cloud_help_catalog_ticket_types_id"
                                        :required="true"
                                    >
                                        <option
                                            v-for="type in options.types"
                                            :key="type.id"
                                            :value="type.id"
                                        >
                                            {{type.name}}
                                        </option>
                                    </b-select>
                                </b-field>
                            </div>
                            <div class="column is-6">
                                <b-field :label="'translations.modals.transfer.fields.category'">
                                    <b-select
                                        :placeholder="'translations.form.placeholders.select_category'"
                                        expanded
                                        v-model="transfer.cloud_help_catalog_ticket_categories_id"
                                        :required="true"
                                    >
                                        <option
                                            v-for="category in options.categories"
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
                        {{ 'translations.modals.transfer.actions.transfer' }}
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modals.transfer=false">
                        {{ 'translations.modals.transfer.actions.cancel' }}
                    </button>
                </div>
            </div>
        </b-modal>

        <div class="card-header">
            <h2 class="card-header-title">
                <span v-if="viewType == 'new'">{{translations.main.view_title_new}}</span>
                <span v-else>{{translations.main.view_title_edit}}</span>
            </h2>
            <div class="card-header-icon">
                <router-link v-if="viewType == 'edit'" :to="`/${ticket_id}`">
                    <i class="fas fa-eye"></i>
                    {{translations.core.view_btn_show}}
                </router-link>
                <router-link :to="`/`">
                    &nbsp;&nbsp;&nbsp;
                    <i class="fas fa-undo"></i>
                    {{translations.core.view_btn_return}}
                </router-link>
            </div>
        </div>
        <div class="card-content">
            <form @submit="submitTicket">
                <div class="columns">
                    <div class="column is-9">
                        <b-field>
                            <template v-slot:label>
                                {{translations.main.column_subject}}<sup class="has-text-danger">*</sup>
                            </template>
                            <b-input v-model="ticket.detail_attributes.subject" :readonly="ticket_id != null" required></b-input>
                        </b-field>
                    </div>
                    <div class="column is-3">
                        <b-field :label="translations.main.column_deadline">
                            <vc-date-picker
                                v-model="ticket.detail_attributes.deadline"
                                :locale="date.vcDatepickerConfig()"
                                :popover="{ visibility: 'focus' }"
                                :input-props="{
                                    placeholder: translations.core.view_text_select_date
                                }"
                            >
                            </vc-date-picker>
                        </b-field>
                    </div>
                </div>
                <div class="columns">
                    <div class="column is-4">
                        <b-field>
                            <template v-slot:label>
                                {{translations.main.column_cloud_help_catalog_ticket_types_id}}<sup class="has-text-danger">*</sup>
                            </template>
                            <b-select 
                                :placeholder="translations.core.view_placeholder_select_option"
                                expanded
                                required
                                v-model="ticket.cloud_help_catalog_ticket_types_id"
                            >
                                <option
                                    v-for="type in options.types"
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
                        <b-field>
                            <template v-slot:label>
                                {{translations.main.column_cloud_help_catalog_ticket_categories_id}}<sup class="has-text-danger">*</sup>
                            </template>
                            <b-select
                                :placeholder="translations.core.view_placeholder_select_option"
                                expanded
                                required
                                v-model="ticket.cloud_help_catalog_ticket_categories_id"
                            >
                                <option
                                    v-for="category in options.categories"
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
                        <b-field>
                            <template v-slot:label>
                                {{translations.main.column_cloud_help_catalog_ticket_priorities_id}}<sup class="has-text-danger">*</sup>
                            </template>
                            <b-select
                                :placeholder="translations.core.view_placeholder_select_option"
                                expanded
                                required
                                v-model="ticket.cloud_help_catalog_ticket_priorities_id"
                            >
                                <option
                                    v-for="priority in options.priorities"
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
                    <label class="label">{{translations.main.column_description}}</label>
                    <div class="control">
                        <component-rich-text-editor
                            v-model="ticket.detail_attributes.description"
                        >
                        </component-rich-text-editor>
                    </div>
                </div>
                <hr>
                <div class="field has-text-right">
                    <b-button type="is-primary" native-type="submit" :disabled="submitting" expanded class="submit-button">
                        <span v-if="submitting">
                            <i class="fas fa-circle-notch fa-spin"></i>
                            &nbsp; {{translations.core.view_btn_saving}}
                        </span>
                        <span v-else>
                            <i class="fas fa-save"></i>
                            &nbsp; {{translations.core.view_btn_save}}
                        </span>
                    </b-button>
                </div>
            </form>
        </div>
    </div>
</template>
