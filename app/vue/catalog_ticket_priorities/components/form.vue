<script>
/*
Copyright (c) 2020, Lesli Technologies, S. A.

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

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Allows the user to either view, or edit a Ticket priority and save it in the 
    database using HTTP. This component is intended to be used in conjunction with the main apps:
    *new*, *show* and *edit*

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
            ticket_priority: null
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

            this.http.post(url, form_data).then(result => {
                if (result.successful) {
                    this.alert('Ticket priority created successfully', 'success')
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

            this.http.put(url, form_data).then(result => {
                if (result.successful) {
                    this.alert('Ticket priority updated successfully', 'success')
                    this.$router.push(`/${this.ticket_priority.id}`)
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

            this.http.delete(url).then(result => {
                if (result.successful) {
                    this.alert('Ticket priority deleted successfully', 'success')
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
                Ticket priority
            </h2>
            <div class="card-header-icon">
                <router-link v-if="viewType == 'edit'" :to="`/${ticket_priority.id}`">
                    <i class="fas fa-eye"></i>
                    Show Ticket priority
                </router-link>
                <router-link v-if="viewType == 'show'" :to="`/${ticket_priority.id}/edit`">
                    <i class="fas fa-eye"></i>
                    Edit Ticket priority
                </router-link>
                <router-link to="/">
                    &nbsp;&nbsp;&nbsp;
                    <i class="fas fa-undo"></i>
                    Return
                </router-link>
            </div>
        </div>
        <!---------------------------------------  END CARD HEADER  --------------------------------------->

        <!--------------------------------------- START CARD CONTENT--------------------------------------->
        <div class="card-content">
            <form @submit="submitTicketPriority">
                <div class="columns">
                    <div class="column">
                        <b-field label="Name">
                            <b-input v-model="ticket_priority.name" required="true"></b-input>
                        </b-field>
                    </div>
                    <div class="column">
                        <b-field label="Weight">
                            <b-input max="1000000" min="0" v-model="ticket_priority.weight" type="number" required="true" >
                            </b-input>
                        </b-field>
                    </div>
                </div>

                <div class="columns">
                    <div v-if="ticket_priority_id" class="column">
                        <div class="field">
                            <small>
                                <span class="has-text-weight-bold">
                                    Created at:
                                </span>
                                {{ date.toLocalFormat(ticket_priority.created_at, false, true) }}
                                <br>
                                <span class="has-text-weight-bold">
                                    Updated at:
                                </span>
                                {{ date.toLocalFormat(ticket_priority.updated_at, false, true) }}
                            </small>
                        </div>
                    </div>
                    <div class="column has-text-right">
                        <!---------------------------------- START SUBMIT BUTTON ---------------------------------->
                        <b-field v-if="viewType == 'new' || viewType == 'edit'">
                            <b-button type="is-primary" native-type="submit">
                                <span v-if="viewType == 'new'">
                                    Create Ticket priority
                                </span>
                                <span v-else>
                                    Update Ticket priority
                                </span>
                            </b-button>
                        </b-field>
                        <!----------------------------------  END SUBMIT BUTTON  ---------------------------------->
                        
                        <!---------------------------------- START DELETE BUTTON ---------------------------------->
                        <b-field v-if="viewType == 'show'">
                            <b-button type="is-danger" @click="deleteTicketPriority">
                                <span v-if="viewType == 'new'">
                                    Create Ticket priority
                                </span>
                                <span v-else>
                                    Delete Ticket priority
                                </span>
                            </b-button>
                        </b-field>
                        <!----------------------------------  END DELETE BUTTON  ---------------------------------->
                    </div>
                </div>
            </form>
        </div>
        <!---------------------------------------  END CARD CONTENT --------------------------------------->
    </div>
</template>
