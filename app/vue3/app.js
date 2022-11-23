/*
Copyright (c) 2022, all rights reserved.

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


// · Import main app
import app from "LesliVue/app"

// · Import apps and components
// import appDashboard from "LesliVue/cloud-objects/dashboards/apps/show.vue"

// // · Tickets components
import ticketsIndex from './apps/tickets/index.vue'
import ticketsNew from './apps/tickets/new.vue'
import ticketsShow from './apps/tickets/show.vue'

// // SLAs components
import slasIndex from './apps/sla/index.vue'
import slaNew from './apps/sla/new.vue'
import slaShow from './apps/sla/show.vue'

// // · Reports components
import reportsIndex from './apps/reports/index.vue'

// · Ticket priorities components
import prioritiesIndex from './apps/catalog/priorities/index.vue'

// ·
app('CloudHelp', [
    // {
    //     path: '/',
    //     component: appDashboard
    // },
    {
        path: '/catalog/ticket_priorities',
        component: prioritiesIndex
    },
    {
        path: '/tickets',
        component: ticketsIndex
    },
    {
        path: '/tickets/new',
        component: ticketsNew
    },
    {
        path: '/tickets/:id',
        component: ticketsShow
    },
    {
        path: '/slas',
        component: slasIndex
    },
    {
        path: '/slas/new',
        component: slaNew
    },
    {
        path: '/slas/:id/',
        component: slaShow
    },
    {
        path: '/reports',
        component: reportsIndex
    },

])
