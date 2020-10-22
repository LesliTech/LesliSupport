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
@description App that allows the user to create a new Ticket priority

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
    // @data_variable ticket_priority [Object] An object representing a Ticket priority, with
    //      the same params as the associated rails model
    data(){
        return {
            translations: {
                main: I18n.t('help.catalog/ticket_priorities')
            },
            ticket_priority: {
                name: null,
                weight: null
            },
            index_abilities: this.abilities.privilege('tickets', 'cloud_help')
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted(){

    },

    methods: {
        
    }
}
</script>
<template>
    <section class="application-component">
        <component-header 
            :title="translations.main.view_title_main"
        >
        </component-header>
        <component-form :ticket-priority="ticket_priority" view-type="new" />
    </section>
</template>
