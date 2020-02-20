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
@description App that retrieves and shows list of all the Ticket associated to 
    the account of the logged user

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentWorkflowStatusName from 'LesliCoreVue/cloud_objects/workflows/components/status-name.vue'

// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    props: {

    },
    
    components: {
        'component-workflow-status-name': componentWorkflowStatusName
    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable tickets [Array] An array of objects, each object represents a 
    //      Ticket, with the same params as the associated rails model
    data(){
        return {
            main_route: '/help/tickets',
            tickets: null,
            reloading: false
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
       this.getTickets()
    },

    methods: {

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves a list of Ticket associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.tickets) // will display null
        //      this.getTickets()
        //      console.log(this.tickets) // will display an array of objects, each representing a Ticket.
        getTickets() {
            this.http.get(`${this.main_route}.json`).then(result => {
                this.reloading = false
                if (result.successful) {
                    this.tickets = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        // @return [void]
        // @param ticket [Object] The object representation of the selected Ticket
        // @description Redirects the router to show the selected Ticket
        // @example
        //      this.showTicket(this.tickets[1])
        //      // Asume the id of the Ticket is 4
        //      // The user will be redirected to the url /help/tickets/4
        showTicket(ticket) {
            this.$router.push(`/${ticket.id}`)
        },

        reloadTickets(){
            this.reloading = true
            this.getTickets()
        }
    },

    computed: {

        // @return [String] The class that is used to give a spinning animation to the icon (if needed)
        // @description When the user clicks the 'reload' button, it changes the value of the *reloading*
        //      data variable. And that is used by this method to change the class of the icon and add it
        //      the spinning animation
        reloadingClass(){
            if(this.reloading){
                return 'fa-spin'
            }

            return ''
        }
    }
}
</script>
<template>
    <section class="section" v-if="tickets">
        <component-layout-data-empty v-if="tickets.length == 0" />
        <div class="card" v-if="tickets.length > 0">
            <div class="card-header">
                <h4 class="card-header-title">
                    Tickets
                </h4>
                <div class="buttons">
                    <button class="button is-white" @click="reloadTickets" :disabled="reloading">
                        <b-icon icon="sync" size="is-small" :custom-class="reloadingClass" />
                    </button>
                    &nbsp;&nbsp;&nbsp;
                </div>
            </div>
            <div class="card-content">
                <b-table :data="tickets" @click="showTicket" :hoverable="true">
                    <template v-slot="props">
                        <b-table-column field="id" label="Number" centered numeric width="40">
                            {{props.row.id}}
                        </b-table-column>
                        <b-table-column field="subject" label="Subject">
                            {{props.row.subject}}
                        </b-table-column>
                        <b-table-column field="priority" label="Priority">
                            {{props.row.priority}}
                        </b-table-column>
                        <b-table-column field="type" label="Type">
                            {{props.row.type}}
                        </b-table-column>
                        <b-table-column field="category" label="Category">
                            {{props.row.category}}
                        </b-table-column>
                        <b-table-column field="assignation_type" label="Assignation Type">
                            <span v-if="props.row.assignation_type">
                                {{`${props.row.assignation_type.charAt(0).toUpperCase()}${props.row.assignation_type.slice(1)}`}}
                            </span>
                            <span v-else>
                                None
                            </span>
                        </b-table-column>
                        <b-table-column field="state" label="Status">
                            <component-workflow-status-name
                                :name="props.row.state"
                            />
                        </b-table-column>
                        <b-table-column field="created_at" label="Created at">
                            {{ date.toLocalFormat(props.row.created_at,true) }}
                        </b-table-column>
                    </template>
                </b-table>
            </div>
        </div>
    </section>

    <section class="section" v-else>
        <component-layout-data-loading  size="is-medium" />
    </section>
</template>
