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
    
    // @component_prop TicketType [Object] The object representation of the ticket_type.
    //      If this component is being used by the *new* app, all the object properties are empty
    // @component_prop viewType [String] Either 'new', 'edit' or 'show'. Represents the main app that
    //      imported this component
    props: {
        TicketType: {
            required: true
        },

        viewType: {
            type: String,
            required: true
        },

        appMountPath: {
            type: String,
            required: true
        }
    },

    components: {

    },
    
    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable ticket_type [Object] An object representing a Ticket type, with
    //      the same params as the associated rails model
    data() {
        return {
            main_route: '/help/catalog/ticket_types',
            ticket_type: null,
            submitting: false,
            deleting: false,
            translations: {
                main: I18n.t('help.catalog/ticket_types'),
                core: I18n.t('core.shared'),
                shared: I18n.t('help.shared')
            }
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
        this.setTicketTypeId()
        this.copyTicketTypeProp()
    },

    methods: {

        // @return [void]
        // @description Retrieves the id of the Ticket type and stores it in the data variable ticket_type_id
        // @example
        //      console.log(this.ticket_type_id) // will display null
        //      this.setTicketTypeId()
        //      console.log(this.ticket_type_id) // will display a number, like 5
        setTicketTypeId(){
            this.ticket_type_id = this.$route.params.id
        },

        // @return [void]
        // @description Copies the content of the prop TicketType into the data variable ticket_type.
        //      This is done to allow this component to modify the Ticket type's attributes without directly
        //      modifying the received prop
        // @example
        //      console.log(this.ticket_type) // will display null
        //      this.copyTicketTypeProp()
        //      console.log(this.ticket_type_id) // will display an exact copy of the TicketType prop
        copyTicketTypeProp(){
            this.ticket_type = {... this.TicketType}
        },

        // @return [void]
        // @description Catches the submit event of the HTML form, and prevents its default behavior. Depending on the
        //      value of the *viewType* variable, executes a method that sends and HTTP post or put to the lesli API
        //  @example
        //      this.submitTicketType() // will trigger a post if viewMode is 'new' or a put if viewMode is 'edit'
        submitTicketType(event){
            if (event) { event.preventDefault() }

            if(this.viewType == 'new'){
                this.postTicketType()
            }else if(this.viewType == 'edit'){
                this.putTicketType()
            }
        },

        // @return [void]
        // @description Connects to the backend using HTTP to create a new Ticket type under the current user's
        //       account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.ticket_type.id)  // will display null since this will be a new record
        //      this.postTicketType()            // will create a new record and redirect to it's show app
        postTicketType() {
            let form_data = {
                ticket_type: this.ticket_type
            }
            let url = `${this.main_route}.json`
            this.submitting = true

            this.http.post(url, form_data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_info_ticket_type_created, 'success')
                    this.$router.push(`${this.appMountPath}/${result.data.id}`)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        // @return [void]
        // @description Connects to the backend using HTTP to update an existing Ticket type under the current user's
        //      account. The id of the Ticket type is provided in the *id* route param. If the HTTP request fails,
        //      an error message is shown
        // @example
        //      this.putTicketType() // will update the record and redirect to it's show app
        putTicketType() {
            let form_data = {
                ticket_type: this.ticket_type
            }
            let url = `${this.main_route}/${this.ticket_type_id}.json`
            this.submitting = true

            this.http.put(url, form_data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_info_ticket_type_updated, 'success')
                }else{
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
        //      this.deleteTicketType() // will delete the record and redirect to the list app
        deleteTicketType() {
            let url = `${this.main_route}/${this.ticket_type_id}`
            this.deleting = true

            this.http.delete(url).then(result => {
                this.deleting = false
                if (result.successful) {
                    this.alert(this.translations.main.messages_info_ticket_type_destroyed, 'success')
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
    <div class="card" v-if="ticket_type">

        <!--------------------------------------- START CARD CONTENT--------------------------------------->
        <div class="card-content">
            <b-tabs>
                <b-tab-item :label="translations.shared.view_tab_title_general_information">
                    <form @submit="submitTicketType">
                        <div class="columns">
                            <div class="column">
                                <b-field :label="translations.main.column_name">
                                    <b-input v-model="ticket_type.name" required="true"></b-input>
                                </b-field>
                            </div>
                        </div>

                        <div class="columns">
                            <div v-if="ticket_type_id" class="column">
                                <div class="field">
                                    <small>
                                        <span class="has-text-weight-bold">
                                            {{translations.main.column_created_at}}:
                                        </span>
                                        {{ ticket_type.created_at }}
                                        <br>
                                        <span class="has-text-weight-bold">
                                            {{translations.main.column_updated_at}}:
                                        </span>
                                        {{ ticket_type.updated_at }}
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
                        <b-button type="is-danger" @click="deleteTicketType" expanded class="submit-button" :disabled="deleting">
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
