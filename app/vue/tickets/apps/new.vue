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

export default {
    components: {
        'component-form': componentForm
    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable ticket_type [Object] An object representing a Ticket type, with
    //      the same params as the associated rails model
    data(){
        return {
            translations: {
                main: I18n.t('help.tickets')
            },
            ticket: {
                cloud_help_catalog_ticket_types_id: null,
                cloud_help_catalog_ticket_categories_id: null,
                cloud_help_catalog_ticket_sources_id: null,
                cloud_help_catalog_ticket_priorities_id: null,
                detail_attributes: {
                    subject: null,
                    description: null,
                    deadline: new Date(),
                    tags: null
                }
            }
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header 
            :title="translations.main.view_title_main"
        >
        </component-header>
        <component-form :ticket-data="ticket" view-type="new"></component-form>
    </section>
</template>
