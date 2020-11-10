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


import componentAssignments from '../components/assignment.vue'
// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-rich-text-editor': componentRichTextEditor,
        'vc-date-picker': DatePicker,
        'component-assignments': componentAssignments
    },

    props: {

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
                shared: I18n.t('help.shared'),
                assignments: I18n.t('help.ticket/assignments')
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
        this.setTicket()
        this.setSubscriptions()
        this.getTicketOptions()
    },
    methods: {
        setTicket(){
            this.ticket_id = this.$route.params.id
            this.ticket = this.data.ticket
        },
        
        setSubscriptions(){
            this.bus.subscribe('update:/help/ticket/workflow', (status)=>{
                this.ticket.cloud_help_ticket_workflow_statuses_id = status.id
                this.ticket.status = status.name
                this.ticket.status_type = status.status_type
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
                ticket: JSON.parse(JSON.stringify(this.ticket)) //We deep copy the object so tag changes to data will not affect this.ticket
            }
            data.ticket.detail_attributes.tags = data.ticket.detail_attributes.tags.join(',')
            data.ticket.detail_attributes.description = JSON.stringify(data.ticket.detail_attributes.description)
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
                ticket: JSON.parse(JSON.stringify(this.ticket)) //We deep copy the object so tag changes to data will not affect this.ticket
            }
            data.ticket.detail_attributes.tags = data.ticket.detail_attributes.tags.join(',')
            data.ticket.detail_attributes.description = JSON.stringify(data.ticket.detail_attributes.description)

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

        // @return [void]
        // @description Connects to the backend using HTTP to delete an existing Ticket type under the current user's
        //      account. The id of the Ticket type is provided in the *id* route param. If the HTTP request fails,
        //      an error message is shown
        // @example
        //      this.deleteTicket() // will delete the record and redirect to the list app
        deleteTicket() {
            let url = `${this.main_route}/${this.ticket_id}`
            this.deleting = true

            this.http.delete(url).then(result => {
                this.deleting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_info_ticket_destroyed, 'success')
                    this.$router.push('/')
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        deleteTicketAssignment(deleted_assignment){
            let url = `${this.main_route}/${this.ticket_id}/assignments/${deleted_assignment.id}`

            this.http.delete(url).then(result => {
                if (result.successful) {
                    this.alert(this.translations.assignments.messages_info_assignment_deleted, 'success')
                    
                    this.ticket.assignment_attributes = this.ticket.assignment_attributes.filter((assignment)=>{
                        return deleted_assignment.id != assignment.id
                    })

                    let user = this.data.assignment_options.users.find((user)=>{
                        return user.assignment_id == deleted_assignment.id
                    })
                    user.assignment_id = null
                    user.checked = false
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
    <div class="card">
        <div class="card-header">
            <div class="card-header-title">
                <h4 class="title is-4">
                    <span v-if="viewType == 'new'">{{translations.main.view_title_new}}</span>
                    <span v-else-if="viewType == 'edit'">{{translations.main.view_title_edit}}</span>
                    <span v-else>{{translations.main.view_title_show}}</span>
                </h4>
            </div>
            <div class="card-header-icon">
                <router-link v-if="viewType == 'edit'" :to="`/${ticket_id}`">
                    <i class="fas fa-eye"></i>
                    {{translations.core.view_btn_show}}
                </router-link>
                <router-link v-if="viewType == 'show'" :to="`/${ticket_id}/edit`">
                    <i class="fas fa-edit"></i>
                    {{translations.core.view_btn_edit}}
                </router-link>
                <router-link :to="`/`">
                    &nbsp;&nbsp;&nbsp;
                    <i class="fas fa-undo"></i>
                    {{translations.core.view_btn_return}}
                </router-link>
            </div>
        </div>
        <div class="card-content subtabs">
            <b-tabs>
                <b-tab-item :label="translations.shared.view_tab_title_general_information">
                    <fieldset :disabled="viewType == 'show'">
                        <form @submit="submitTicket">
                            <div v-if="viewType != 'new'">
                                <label class="label">{{translations.main.view_title_assigned_users}}</label>
                                <div class="tags is-medium" v-if="ticket.assignment_attributes && ticket.assignment_attributes.length > 0">
                                    <b-tag
                                        type="is-info"
                                        v-for="assignment in ticket.assignment_attributes"
                                        :key="assignment.id"
                                        :closable="viewType == 'edit'"
                                        @close="deleteTicketAssignment(assignment)"
                                    >
                                        <span>{{assignment.assignable_name}}</span>
                                    </b-tag>
                                </div>
                                <div class="tags" v-else>
                                    <span class="tag">{{translations.main.view_text_no_users_assigned}}</span>
                                </div>
                            </div>
                            <div class="columns">
                                <div class="column is-9">
                                    <b-field>
                                        <template v-slot:label>
                                            {{translations.main.column_subject}}<sup class="has-text-danger">*</sup>
                                        </template>
                                        <b-input v-model="ticket.detail_attributes.subject" required></b-input>
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
                                            >
                                                {{priority.name}}
                                            </option>
                                        </b-select>
                                    </b-field>
                                </div>
                            </div>

                            <b-field :label="translations.main.column_tags">
                                <b-taginput v-model="ticket.detail_attributes.tags" ellipsis :closable="viewType != 'show'"></b-taginput>
                            </b-field>

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
                                <b-button v-if="viewType != 'show'" type="is-primary" native-type="submit" :disabled="submitting" expanded class="submit-button">
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
                    </fieldset>
                </b-tab-item>
                <b-tab-item :label="translations.main.view_tab_title_assignments" v-if="viewType != 'new'">
                    <component-assignments v-if="ticket_id" :ticket-id="ticket_id"></component-assignments>
                </b-tab-item>
                <b-tab-item :label="translations.shared.view_tab_title_delete_section" v-if="viewType == 'edit'">
                    <span class="has-text-danger">
                        {{translations.main.view_text_delete_confirmation}}
                    </span>
                    <br>
                    <br>
                    <!---------------------------------- START DELETE BUTTON ---------------------------------->
                    <b-field v-if="viewType != 'new'">
                        <b-button type="is-danger" @click="deleteTicket" expanded class="submit-button" :disabled="deleting">
                            <span v-if="deleting">
                                <i class="fas fa-spin fa-circle-notch"></i> {{translations.core.view_btn_deleting}}
                            </span>
                            <span v-else>
                                <i class="fas fa-trash-alt"></i> {{translations.core.view_btn_delete}}
                            </span>
                        </b-button>
                    </b-field>
                    <!----------------------------------  END DELETE BUTTON  ---------------------------------->
                </b-tab-item>
            </b-tabs>
        </div>
    </div>
</template>
