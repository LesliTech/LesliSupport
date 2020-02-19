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

@author   [AUTHOR_NAME_GOES_HERE]
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description App that retrieves and shows a Ticket category specified by the id in the route

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

    },
    
    components: {
        'component-form': componentForm
    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable ticket_category [Object] An object representing a Ticket category, with
    //      the same params as the associated rails model
    // @data_variable ticket_category_id [String|Integer] The id of the Ticket category, as
    //      obtained from the route using the *Vue-router* *params* 
    data(){
        return {
            main_route: '/help/catalog/ticket_categories',
            ticket_category: null,
            ticket_category_id: null
        }
    },

    // @return [void]
    // @description Executes the necessary methods needed to initialize this component
    mounted(){
        this.setTicketCategoryId()
        this.getTicketCategory()
    },

    methods: {

        // @return [void]
        // @description Retrieves the id of the Ticket category and stores it in the data variable ticket_category_id
        // @example
        //      console.log(this.ticket_category_id) // will display null
        //      this.setTicketCategoryId()
        //      console.log(this.ticket_category_id) // will display a number, like 5
        setTicketCategoryId(){
            this.ticket_category_id = this.$route.params.id
        },

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves the Ticket category associated to
        //      the variable *Ticket category_id*. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.ticket_category) // will display null
        //      this.getTicketCategory()
        //      console.log(this.ticket_category) // will display an object representation of the Ticket category
        getTicketCategory(){
            let url = `${this.main_route}/${this.ticket_category_id}.json`
            this.http.get(url).then(result => {
                if (result.successful) {
                    this.ticket_category = result.data
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
    <section class="section">
        <component-form v-if="ticket_category" :ticket-category="ticket_category" view-type="show"/>
        <component-layout-data-loading v-else size="is-medium" />
    </section>
</template>
