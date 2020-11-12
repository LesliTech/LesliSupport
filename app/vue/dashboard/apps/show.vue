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


// · Import components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentNewTickets from "../../dashboards/components/list-new-tickets.vue"
import componentMyTickets from "../../dashboards/components/list-my-tickets.vue"
import componentUnassignedTickets from "../../dashboards/components/list-unassigned-tickets.vue"
import componentTicketsByType from "../../dashboards/components/chart-tickets-by-type.vue"
import componentTicketsByCategory from "../../dashboards/components/chart-tickets-by-category.vue"


// · component
export default {
    components: {
        "component-new-tickets": componentNewTickets,
        "component-my-tickets": componentMyTickets,
        "component-unassigned-tickets": componentUnassignedTickets,
        "component-tickets-by-type": componentTicketsByType,
        "component-tickets-by-category": componentTicketsByCategory
    },

    data() {
        return {
            main_route: '/help/dashboards/default.json',
            dashboard: null,
            translations: {
                tickets: I18n.t('help.tickets')
            }
        }
    },

    mounted(){
        this.getDefaultDashboard()
    },

    methods: {
        getDefaultDashboard(){
            this.http.get(this.main_route).then((result)=>{
                if (result.successful) {
                    this.dashboard = result.data
                }else{
                    this.alert(result.error.message,'danger')
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
            :title="false"
        >
            <div class="buttons">
                <a class="button" href="/help/tickets/new">
                    <b-icon icon="plus" size="is-small"></b-icon>
                    <span>{{ translations.tickets.view_btn_create }}</span>
                </a>
            </div>
        </component-header>

        <div class="columns is-multiline" v-if="dashboard">
            <div v-for="component in dashboard.components" :key="component.id" :class="['column', `is-${component.layout}`]">
                <component :is="`component-${component.component_id.replace(/\_/g,'-')}`" :dashboard-id="dashboard.id" :component-id="component.id">
                </component>
            </div>
        </div>
        <component-data-loading v-else>
        </component-data-loading>
    </section>
</template>
