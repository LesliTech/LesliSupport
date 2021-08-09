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
import componentForm from '../components/form.vue'


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


export default {
    props: {
        appMountPath: {
            type: String,
            default: ''
        }
    },

    components: {
        'component-form': componentForm
    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable ticket_priority [Object] An object representing a Ticket priority, with
    //      the same params as the associated rails model
    // @data_variable ticket_priority_id [String|Integer] The id of the Ticket priority, as
    //      obtained from the route using the *Vue-router* *params* 
    data(){
        return {
            main_route: '/help/catalog/ticket_priorities',
            ticket_priority: null,
            ticket_priority_id: null,
            translations: {
                main: I18n.t('help.catalog/ticket_priorities'),
                core: I18n.t('core.shared')
            },
            index_abilities: this.abilities.privilege('tickets', 'cloud_help')
        }
    },

    // @return [void]
    // @description Executes the necessary methods needed to initialize this component
    mounted(){
        this.setTicketPriorityId()
        this.getTicketPriority()
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
        // @description Connects to the backend using HTTP and retrieves the Ticket priority associated to
        //      the variable *Ticket priority_id*. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.ticket_priority) // will display null
        //      this.getTicketPriority()
        //      console.log(this.ticket_priority) // will display an object representation of the Ticket priority
        getTicketPriority(){
            this.http.get(`${this.main_route}/${this.ticket_priority_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket_priority = result.data
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header 
            :title="translations.main.view_title_edit"
        >
            <div class="navbar-item">
                <div class="buttons">
                    <router-link class="button" :to="`${appMountPath}/`">
                        <b-icon icon="list" size="is-small" />
                        <span>{{ translations.core.view_btn_list }}</span>
                    </router-link>
                </div>
            </div>
        </component-header>
        <component-form v-if="ticket_priority" :ticket-priority="ticket_priority" view-type="edit" :app-mount-path="appMountPath"/>
        <component-data-loading v-else size="is-medium" />
    </section>
</template>
