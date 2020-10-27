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


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    
    // @component_prop TicketPriority [Object] The object representation of the ticket_priority.
    //      If this component is being used by the *new* app, all the object properties are empty
    // @component_prop viewType [String] Either 'new', 'edit' or 'show'. Represents the main app that
    //      imported this component
    props: {
        TicketPriority: {
            required: true
        },

        viewType: {
            type: String,
            required: true
        }
    },

    components: {

    },
    
    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable ticket_priority [Object] An object representing a Ticket priority, with
    //      the same params as the associated rails model
    data() {
        return {
            main_route: '/help/catalog/ticket_priorities',
            ticket_priority: null,
            submitting: false,
            deleting: false,
            translations: {
                main: I18n.t('help.catalog/ticket_priorities'),
                core: I18n.t('core.shared'),
                shared: I18n.t('help.shared')
            }
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
        this.setTicketPriorityId()
        this.copyTicketPriorityProp()
    },

    methods: {

        // @return [void]
        // @description Retrieves the id of the Ticket priority and stores it in the data variable ticket_priority_id
        // @example
        //      console.log(this.ticket_priority_id) // will display null
        //      this.setTicketPriorityId()
        //      console.log(this.ticket_priority_id) // will display a number, like 5
        setTicketPriorityId(){
            this.ticket_priority_id = this.$route.params.id
        },

        // @return [void]
        // @description Copies the content of the prop TicketPriority into the data variable ticket_priority.
        //      This is done to allow this component to modify the Ticket priority's attributes without directly
        //      modifying the received prop
        // @example
        //      console.log(this.ticket_priority) // will display null
        //      this.copyTicketPriorityProp()
        //      console.log(this.ticket_priority_id) // will display an exact copy of the TicketPriority prop
        copyTicketPriorityProp(){
            this.ticket_priority = {... this.TicketPriority}
        },

        // @return [void]
        // @description Catches the submit event of the HTML form, and prevents its default behavior. Depending on the
        //      value of the *viewType* variable, executes a method that sends and HTTP post or put to the lesli API
        //  @example
        //      this.submitTicketPriority() // will trigger a post if viewMode is 'new' or a put if viewMode is 'edit'
        submitTicketPriority(event){
            if (event) { event.preventDefault() }

            if(this.viewType == 'new'){
                this.postTicketPriority()
            }else if(this.viewType == 'edit'){
                this.putTicketPriority()
            }
        },

        // @return [void]
        // @description Connects to the backend using HTTP to create a new Ticket priority under the current user's
        //       account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.ticket_priority.id)  // will display null since this will be a new record
        //      this.postTicketPriority()            // will create a new record and redirect to it's show app
        postTicketPriority() {
            let form_data = {
                ticket_priority: this.ticket_priority
            }
            let url = `${this.main_route}.json`
            this.submitting = true

            this.http.post(url, form_data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_info_ticket_priority_created, 'success')
                    this.$router.push(`/${result.data.id}`)
                }else{
                    this.alert(result.error.message,'danger')
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
        //      this.putTicketPriority() // will update the record and redirect to it's show app
        putTicketPriority() {
            let form_data = {
                ticket_priority: this.ticket_priority
            }
            let url = `${this.main_route}/${this.ticket_priority_id}.json`
            this.submitting = true

            this.http.put(url, form_data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_info_ticket_priority_updated, 'success')
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        // @return [void]
        // @description Connects to the backend using HTTP to delete an existing Ticket priority under the current user's
        //      account. The id of the Ticket priority is provided in the *id* route param. If the HTTP request fails,
        //      an error message is shown
        // @example
        //      this.deleteTicketPriority() // will delete the record and redirect to the list app
        deleteTicketPriority() {
            let url = `${this.main_route}/${this.ticket_priority_id}`
            this.deleting = true

            this.http.delete(url).then(result => {
                this.deleting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_info_ticket_priority_destroyed, 'success')
                    this.$router.push('/')
                }else{
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
    <div class="card" v-if="ticket_priority">
        <!--------------------------------------- START CARD HEADER --------------------------------------->
        <div class="card-header">
            <h2 class="card-header-title">
                <span v-if="viewType == 'new'">{{translations.main.view_title_new}}</span>
                <span v-else>{{translations.main.view_title_edit}}</span>
            </h2>
            <div class="card-header-icon">
                <router-link to="/">
                    &nbsp;&nbsp;&nbsp;
                    <i class="fas fa-undo"></i>
                    {{translations.core.view_btn_return}}
                </router-link>
            </div>
        </div>
        <!---------------------------------------  END CARD HEADER  --------------------------------------->

        <!--------------------------------------- START CARD CONTENT--------------------------------------->
        <div class="card-content">
            <b-tabs>
                <b-tab-item :label="translations.shared.view_tab_title_general_information">
                    <form @submit="submitTicketPriority">
                        <div class="columns">
                            <div class="column">
                                <b-field :label="translations.main.column_name">
                                    <b-input v-model="ticket_priority.name" required="true"></b-input>
                                </b-field>
                            </div>
                            <div class="column">
                                <b-field :label="translations.main.column_weight" :message="translations.main.view_text_column_weight_description">
                                    <b-input max="1000000" min="0" step="1" v-model="ticket_priority.weight" type="number" required="true" >
                                    </b-input>
                                </b-field>
                            </div>
                        </div>

                        <div class="columns">
                            <div v-if="ticket_priority_id" class="column">
                                <div class="field">
                                    <small>
                                        <span class="has-text-weight-bold">
                                            {{translations.main.column_created_at}}:
                                        </span>
                                        {{ ticket_priority.created_at }}
                                        <br>
                                        <span class="has-text-weight-bold">
                                            {{translations.main.column_updated_at}}:
                                        </span>
                                        {{ ticket_priority.updated_at }}
                                    </small>
                                </div>
                            </div>
                            <div class="column has-text-right">
                                <!---------------------------------- START SUBMIT BUTTON ---------------------------------->
                                <b-field v-if="viewType == 'new' || viewType == 'edit'">
                                    <b-button type="is-primary" native-type="submit" :disabled="submitting">
                                        <span v-if="submitting">
                                            <i class="fas fa-circle-notch fa-spin"></i>
                                            &nbsp; {{translations.core.view_btn_saving}}
                                        </span>
                                        <span v-else>
                                            <i class="fas fa-save"></i>
                                            &nbsp; {{translations.core.view_btn_save}}
                                        </span>
                                    </b-button>
                                </b-field>
                                <!----------------------------------  END SUBMIT BUTTON  ---------------------------------->
                            </div>
                        </div>
                    </form>
                </b-tab-item>
                <b-tab-item :label="translations.shared.view_tab_title_delete_section" v-if="viewType != 'new'">
                    <span class="has-text-danger">
                        {{translations.main.view_text_delete_confirmation}}
                    </span>
                    <br>
                    <br>
                    <!---------------------------------- START DELETE BUTTON ---------------------------------->
                    <b-field v-if="viewType != 'new'">
                        <b-button type="is-danger" @click="deleteTicketPriority" expanded class="submit-button" :disabled="deleting">
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
        <!---------------------------------------  END CARD CONTENT --------------------------------------->
    </div>
</template>
