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
import componentSlaData from '../../slas/components/data.vue'
// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-rich-text-editor': componentRichTextEditor,
        'vc-date-picker': DatePicker,
        'component-assignments': componentAssignments,
        'component-sla-data': componentSlaData
    },

    props: {
        viewType: {
            type: String,
            default: 'new'
        },

        expandedTabs: {
            type: Boolean,
            default: false
        },

        appMountPath: {
            type: String,
            required: true
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
            loading: {
                options: false
            },
            ticket_id: null,
            ticket: {},
            transfer: {},
            modals: {
                escalate: false,
                descalate: false,
                transfer: false
            },
            auto_assignment: false,
            assignments_abilities: {
                create: false
            },
            ticket_abilities: {
                catalog_ticket_types: this.abilities.privilege('catalog/ticket_types', 'cloud_help'),
                catalog_ticket_categories: this.abilities.privilege('catalog/ticket_categories', 'cloud_help'),
                catalog_ticket_priorities: this.abilities.privilege('catalog/ticket_priorities', 'cloud_help'),
                catalog_ticket_workspaces: this.abilities.privilege('catalog/ticket_workspaces', 'cloud_help')
            },
        }
    },
    mounted() {
        this.setTicket()
        this.setAbilities()
        this.setAutoAssignment()
        this.setSubscriptions()
        this.getTicketOptions()
        this.getTicketImages()
    },

    beforeDestroy(){
        this.deleteSubscriptions()
    },

    methods: {
        setTicket(){
            this.ticket_id = this.$route.params.id
            this.ticket = this.data.ticket
        },

        setAbilities(){
            this.assignments_abilities = this.abilities.privilege('ticket/assignments', 'cloud_help')
        },

        setAutoAssignment(){
            if(this.viewType != 'new'){
                if(this.ticket.assignment_attributes.find(assignment => assignment.users_id == lesli.current_user.id)){
                    this.auto_assignment = true
                }
            }
        },
        
        setSubscriptions(){
            this.bus.subscribe('update:/help/ticket/workflow', (status)=>{
                this.ticket.cloud_help_workflow_statuses_id = status.id
                this.ticket.status = status.name
                this.ticket.status_type = status.status_type
            })

            
            this.bus.subscribe('post:/help/tickets/files-complete', ()=>{
                this.getTicketImages()
            })

            this.bus.subscribe('delete:/help/tickets/files', (deleted_file)=>{
                this.data.ticket_images = this.data.ticket_images.filter( ticket_image => ticket_image.id != deleted_file.id)
            })
        },

        deleteSubscriptions(){
            this.bus.$off('update:/help/sla/workflow')
            this.bus.$off('post:/help/tickets/files-complete')
            this.bus.$off('delete:/help/tickets/files')
        },

        // @return [void]
        // @description Catches the submit ticket of the HTML form, and prevents its default behavior. Depending on the
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
                event.preventDefault()
            }
            let data = {
                ticket: JSON.parse(JSON.stringify(this.ticket)) //We deep copy the object so tag changes to data will not affect this.ticket
            }
            data.ticket.tags = data.ticket.tags.join(',')
            data.ticket.reference_url = window.location.href
            data.ticket.description = JSON.stringify(data.ticket.description)
            this.submitting = true

            this.http.post(this.main_route, data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.msg.success(this.translations.main.messages_info_ticket_created)
                    this.$router.push(`${this.appMountPath}/${result.data.id}`)
                } else {
                    this.msg.error(result.error.message)
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
            data.ticket.tags = data.ticket.tags.join(',')
            data.ticket.description = JSON.stringify(data.ticket.description)

            let url = `${this.main_route}/${this.ticket_id}.json`
            this.submitting = true

            this.http.put(url, data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.$nextTick(()=>{
                        this.$set(this.data, 'sla', result.data.sla)
                        this.data.reload.sla = true
                    })
                    this.msg.success(this.translations.main.messages_info_ticket_updated)
                    this.reloadTicket()
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })

        },

        getTicketOptions() {
            let url = `${this.main_route}/options`
            this.loading.options = true

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.options = result.data
                } else {
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            }).finally(()=>{
                this.loading.options = false
            })
        },

        getTicketImages(){
            if(this.ticket_id){
                let url = `${this.main_route}/${this.ticket_id}/resources/images.json`

                this.http.get(url).then(result => {
                    if (result.successful) {
                        this.data.ticket_images = result.data
                    } else {
                        this.msg.error(result.error.message)
                    }
                }).catch(error => {
                    console.log(error)
                })
            }
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
                    this.msg.success(this.translations.main.messages_info_ticket_destroyed)
                    this.$router.push(`${this.appMountPath}/`)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        deleteTicketAssignment(deleted_assignment){
            if(! deleted_assignment){
                return
            }

            let url = `${this.main_route}/${this.ticket_id}/assignments/${deleted_assignment.id}`

            this.http.delete(url).then(result => {
                if (result.successful) {
                    this.msg.success(this.translations.assignments.messages_info_assignment_deleted)
                    
                    this.ticket.assignment_attributes = this.ticket.assignment_attributes.filter((assignment)=>{
                        return deleted_assignment.id != assignment.id
                    })

                    let user = this.data.assignment_options.users.find((user)=>{
                        return user.assignment_id == deleted_assignment.id
                    })
                    user.assignment_id = null
                    user.checked = false
                    
                    this.reloadTicketRecord()
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        autoAssignTicket(){
            if(this.auto_assignment){
                this.data.events.post_auto_assignment = true
            }else{
                this.deleteTicketAssignment(this.ticket.assignment_attributes.find(assignment => assignment.users_id == lesli.current_user.id))
            }
        },

        reloadTicketRecord(){
            this.data.reload.timelines = true
            this.data.reload.activities = true
        },

        reloadTicket(){
            this.reloadTicketRecord()
            this.data.reload.ticket = true
        }
    },

    watch: {
        'ticket.assignment_attributes'(){
            if(this.ticket.assignment_attributes.find(assignment => assignment.users_id == lesli.current_user.id)){
                this.auto_assignment = true
            }else{
                this.auto_assignment = false
            }
        }
    },

    computed: {
        editorType(){
            if(this.viewType == 'show'){
                return 'read'
            }else{
                return 'full'
            }
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-content subtabs">
            <b-tabs :expanded="expandedTabs">
                <b-tab-item :label="translations.shared.view_tab_title_general_information">
                    <form @submit="submitTicket">
                        <fieldset :disabled="viewType == 'show'">
                            <div class="columns">
                                <div class="column is-6">
                                    <b-field :label="translations.main.column_cloud_help_catalog_ticket_workspaces_id">
                                        <template v-slot:message>
                                            <a
                                                v-if="ticket_abilities.catalog_ticket_workspaces.create && viewType != 'show'"
                                                href="/help/catalog/ticket_workspaces/new"
                                                target="_blank"
                                            >
                                                {{translations.main.view_text_add_ticket_workspace}}
                                            </a>
                                        </template>
                                        <b-select
                                            :placeholder="translations.core.view_placeholder_select_option"
                                            expanded
                                            :disabled="loading.options"
                                            v-model="ticket.cloud_help_catalog_ticket_workspaces_id"
                                        >
                                            <option
                                                v-for="workspace in options.workspaces"
                                                :key="workspace.id"
                                                :value="workspace.id"
                                            >
                                                {{workspace.name}}
                                            </option>
                                        </b-select>
                                    </b-field>
                                </div>
                                <div class="column is-6 has-text-right">
                                    <b-field v-if="viewType != 'show'">
                                        <template v-slot:label>
                                            &nbsp;
                                        </template>
                                        <b-button :disabled="loading.options" @click="getTicketOptions">
                                            <b-icon v-if="loading.options" size="is-small" icon="sync" custom-class="fa-spin"></b-icon>
                                            <b-icon v-else size="is-small" icon="sync" ></b-icon>
                                            <span>{{translations.main.view_btn_reload_options}}</span>
                                        </b-button>
                                    </b-field>
                                </div>
                            </div>
                        </fieldset>
                        <div class="columns is-multiline" v-if="viewType != 'new'">
                            <div class="column is-5">
                                <b-field :label="translations.main.column_users_id">
                                    <b-input v-model="ticket.user_creator_name" readonly></b-input>
                                </b-field>
                            </div>
                            <div class="column is-7">
                                <b-field :label="translations.main.column_reference_url">
                                    <b-input v-model="ticket.reference_url" readonly></b-input>
                                </b-field>
                            </div>
                            <div class="column is-9">
                                <label class="label">{{translations.main.view_title_assigned_users}}</label>
                                <div class="tags is-medium" v-if="ticket.assignment_attributes && ticket.assignment_attributes.length > 0">
                                    <b-tag
                                        type="is-info"
                                        v-for="assignment in ticket.assignment_attributes"
                                        :key="assignment.id"
                                        closable
                                        @close="deleteTicketAssignment(assignment)"
                                    >
                                        <span>{{assignment.assignable_name}}</span>
                                    </b-tag>
                                </div>
                                <div class="tags" v-else>
                                    <span class="tag">{{translations.main.view_text_no_users_assigned}}</span>
                                </div>
                            </div>
                            <div v-if="data.ticket_assignable" class="column is-3">
                                <b-field :label="translations.main.view_title_auto_assignment">
                                    <b-checkbox v-model="auto_assignment" @change.native="autoAssignTicket">
                                        {{translations.main.view_text_assign_ticket_to_self}}
                                    </b-checkbox>
                                </b-field>
                            </div>
                        </div>
                        <fieldset :disabled="viewType == 'show'">
                            <div class="columns">
                                <div class="column is-9">
                                    <b-field>
                                        <template v-slot:label>
                                            {{translations.main.column_subject}}<sup class="has-text-danger">*</sup>
                                        </template>
                                        <b-input v-model="ticket.subject" required></b-input>
                                    </b-field>
                                </div>
                                <div class="column is-3">
                                    <b-field :label="translations.main.column_deadline">
                                        <vc-date-picker
                                            v-model="ticket.deadline"
                                            :locale="date.vcDatepickerConfig()"
                                            :popover="{ visibility: 'focus' }"
                                        >
                                            <template v-slot="{ inputValue, inputEvents }">
                                                <input
                                                    class="input is-default"
                                                    v-on="inputEvents"
                                                    :value="inputValue"
                                                    :placeholder="translations.core.view_text_select_date"
                                                />
                                            </template>
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
                                        <template v-slot:message>
                                            <a
                                                v-if="ticket_abilities.catalog_ticket_types.create && viewType != 'show'"
                                                href="/help/catalog/ticket_types/new"
                                                target="_blank"
                                            >
                                                {{translations.main.view_text_add_ticket_type}}
                                            </a>
                                        </template>
                                        <b-select 
                                            :placeholder="translations.core.view_placeholder_select_option"
                                            expanded
                                            required
                                            :disabled="loading.options"
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
                                    <b-field :label="translations.main.column_cloud_help_catalog_ticket_categories_id">
                                        <template v-slot:message>
                                            <a
                                                v-if="ticket_abilities.catalog_ticket_categories.create && viewType != 'show'"
                                                href="/help/catalog/ticket_categories/new"
                                                target="_blank"
                                            >
                                                {{translations.main.view_text_add_ticket_category}}
                                            </a>
                                        </template>
                                        <b-select
                                            :placeholder="translations.core.view_placeholder_select_option"
                                            expanded
                                            :disabled="loading.options"
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
                                    <b-field :label="translations.main.column_cloud_help_catalog_ticket_priorities_id">
                                        <template v-slot:message>
                                            <a
                                                v-if="ticket_abilities.catalog_ticket_priorities.create && viewType != 'show'"
                                                href="/help/catalog/ticket_priorities/new"
                                                target="_blank"
                                            >
                                                {{translations.main.view_text_add_ticket_priority}}
                                            </a>
                                        </template>
                                        <b-select
                                            :placeholder="translations.core.view_placeholder_select_option"
                                            expanded
                                            :disabled="loading.options"
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
                            <div class="columns">
                                <div class="column is-9">
                                    <b-field :label="translations.main.column_tags">
                                        <b-taginput v-model="ticket.tags" ellipsis :closable="viewType != 'show'"></b-taginput>
                                    </b-field>
                                </div>
                                <div class="column is-3" v-if="viewType != 'new'">
                                    <b-field :label="translations.main.column_hours_worked">
                                        <b-input type="number" min="0" max="1000" step="0.01" v-model="ticket.hours_worked"></b-input>
                                    </b-field>
                                </div>
                            </div>

                            <div class="field">
                                <label class="label">{{translations.main.column_description}}</label>
                                <div class="control">
                                    <component-rich-text-editor v-model="ticket.description" :type="editorType">
                                    </component-rich-text-editor>
                                </div>
                            </div>

                            <div class="field" v-if="viewType != 'new' && data.ticket_images.length > 0">
                                <label class="label">{{translations.main.view_title_screenshots}}</label>
                                <a
                                    v-for="image in data.ticket_images"
                                    :key="image.id"
                                    :href="image.href"
                                    target="_ticket_image"
                                >
                                    <img class="ticket-image" :src="image.src">
                                </a>
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
                        </fieldset>
                    </form>
                </b-tab-item>
                <b-tab-item :label="translations.main.view_tab_title_sla" v-if="viewType != 'new'">
                    <component-sla-data v-if="data.sla" shadowless></component-sla-data>
                </b-tab-item>
                <b-tab-item :label="translations.main.view_tab_title_assignments" v-if="viewType != 'new' && assignments_abilities.create">
                    <component-assignments v-if="ticket_id" :ticket-id="ticket_id" :app-mount-path="appMountPath" ></component-assignments>
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
<style scoped>
.ticket-image {
   max-height: 8rem;
    width: auto;
}
</style>
