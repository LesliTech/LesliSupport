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

    props: {
        expandedTabs: {
            type: Boolean,
            default: false
        },

        appMountPath: {
            type: String,
            default: ''
        }
    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable ticket_type [Object] An object representing a Ticket type, with
    //      the same params as the associated rails model
    data(){
        return {
            translations: {
                main: I18n.t('help.tickets'),
                core: I18n.t('core.shared')
            },
            ticket: null,
        }
    },

    mounted(){
        this.initializeTicket()
    },

    methods: {
        initializeTicket(){
            this.data.ticket = null
            this.ticket = {
                cloud_help_catalog_ticket_types_id: null,
                cloud_help_catalog_ticket_categories_id: null,
                cloud_help_catalog_ticket_sources_id: null,
                cloud_help_catalog_ticket_priorities_id: null,
                cloud_help_catalog_ticket_workspaces_id: null,
                subject: null,
                description: {},
                deadline: new Date(),
                tags: [],
                hours_worked: 0
            }
            this.$nextTick(()=>{
                this.data.ticket = this.ticket
            })
        }
    }
}
</script>
<template>
    <section class="application-component app-tickets">
        <component-header :title="translations.main.view_title_main" >
            <div class="navbar-item">
                <div class="buttons">
                    <router-link class="button" :to="`${appMountPath}/`">
                        <b-icon icon="list" size="is-small" />
                        <span>{{ translations.core.view_btn_list }}</span>
                    </router-link>
                </div>
            </div>
        </component-header>
        <component-form v-if="data.ticket" view-type="new" :expanded-tabs="expandedTabs" :app-mount-path="appMountPath" ></component-form>
    </section>
</template>
