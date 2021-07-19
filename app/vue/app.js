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


// · Import main app
import app from 'LesliVue/app2'


// · Import apps and components

// · Dashboard components
import dashboardsShow from './dashboard/actions/show.vue'
import dashboardsList  from 'LesliVue/shared/dashboards/apps/list.vue'
import dashboardsEdit  from 'LesliVue/shared/dashboards/apps/edit.vue'
import dashboardsNew   from 'LesliVue/shared/dashboards/apps/new.vue'

// · Ticket categories components
import ticketCategoriesList  from './catalog_ticket_categories/apps/list.vue'
import ticketCategoriesEdit  from './catalog_ticket_categories/apps/edit.vue'
import ticketCategoriesShow  from './catalog_ticket_categories/apps/show.vue'
import ticketCategoriesNew   from './catalog_ticket_categories/apps/new.vue'

// · Ticket priorities components
import ticketPrioritiesList  from './catalog_ticket_priorities/apps/list.vue'
import ticketPrioritiesEdit  from './catalog_ticket_priorities/apps/edit.vue'
import ticketPrioritiesNew   from './catalog_ticket_priorities/apps/new.vue'

// · Ticket types components
import ticketTypesList  from './catalog_ticket_types/apps/list.vue'
import ticketTypesNew   from './catalog_ticket_types/apps/new.vue'
import ticketTypesEdit  from './catalog_ticket_types/apps/edit.vue'

// · Slas components
import slasList from './slas/apps/list.vue'
import slasEdit from './slas/apps/edit.vue'
import slasNew from './slas/apps/new.vue'
import slasShow from './slas/apps/show.vue'

// · Tickets components
import ticketsList from './tickets/apps/list.vue'
import ticketsEdit from './tickets/apps/edit.vue'
import ticketsNew from './tickets/apps/new.vue'
import ticketsShow from './tickets/apps/show.vue'

// · Import a list of all dashboard components
import componentNewTickets from './dashboards/components/list-new-tickets.vue'
import componentMyTickets from './dashboards/components/list-my-tickets.vue'
import componentUnassignedTickets from './dashboards/components/list-unassigned-tickets.vue'
import componentTicketsByType from './dashboards/components/chart-tickets-by-type.vue'
import componentTicketsByCategory from './dashboards/components/chart-tickets-by-category.vue'
import componentHoursWorked from './dashboards/components/chart-hours-worked.vue'

// ·
app('CloudHelp', '/help', '[dashboards|ticket_types|ticket_priorities|ticket_categories|tickets|slas]', [
    {
        path: '/',
        component: dashboardsShow
    },{
        path: '/dashboards',
        component: dashboardsList,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help'
        }
    },{
        path: '/dashboards/new',
        component: dashboardsNew,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help'
        }
    },{
        path: '/dashboards/:id',
        component: dashboardsEdit,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help',
            renderComponents: {
                'component-new-tickets': componentNewTickets,
                'component-my-tickets': componentMyTickets,
                'component-unassigned-tickets': componentUnassignedTickets,
                'component-tickets-by-type': componentTicketsByType,
                'component-tickets-by-category': componentTicketsByCategory,
                'component-hours-worked': componentHoursWorked
            }
        }
    },{
        path: '/catalog/ticket_categories',
        component: ticketCategoriesList,
        props: {
            appMountPath: '/help/catalog/ticket_categories'
        }
    },{
        path: '/catalog/ticket_categories/new',
        component: ticketCategoriesNew,
        props: {
            appMountPath: '/help/catalog/ticket_categories'
        }
    },{
        path: '/catalog/ticket_categories/:id',
        component: ticketCategoriesShow,
        props: {
            appMountPath: '/help/catalog/ticket_categories'
        }
    },{
        path: '/catalog/ticket_categories/:id/edit',
        component: ticketCategoriesEdit,
        props: {
            appMountPath: '/help/catalog/ticket_categories'
        }
    },{
        path: '/catalog/ticket_priorities',
        component: ticketPrioritiesList
    },{
        path: '/catalog/ticket_priorities/new',
        component: ticketPrioritiesEdit
    },{
        path: '/catalog/ticket_priorities/:id',
        component: ticketPrioritiesNew
    },{
        path: '/catalog/ticket_types',
        component: ticketTypesList
    },{
        path: '/catalog/ticket_types/new',
        component: ticketTypesNew
    },{
        path: '/catalog/ticket_types/:id',
        component: ticketTypesEdit
    },{
        path: '/slas',
        component: slasList
    },{
        path: '/slas/new',
        component: slasNew
    },{
        path: '/slas/:id',
        component: slasShow
    },{
        path: '/slas/:id/edit',
        component: slasEdit
    },{
        path: '/tickets',
        component: ticketsList
    },{
        path: '/tickets/new',
        component: ticketsNew
    },{
        path: '/tickets/:id',
        component: ticketsShow
    },{
        path: '/tickets/:id/edit',
        component: ticketsEdit
    }
],{
    slas: {
        sla: null,
        reload: {
            activities: false,
            sla: false
        }
    }, 
    tickets: {
        ticket: null,
        ticket_assignable: false,
        assignment_options: {},
        reload: {
            timelines: false,
            activities: false,
            ticket: false,
            sla: false
        },
        ticket_images: [],
        events: {
            post_auto_assignment: false,
            delete_auto_assignment: false
        }
    }
})
