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

// · Settings components
import settingsList from './account_settings/apps/list.vue'

// · Dashboard components
import dashboardsList  from 'LesliVue/shared/dashboards/apps/list.vue'
import dashboardsShow  from 'LesliVue/shared/dashboards/apps/show.vue'
import dashboardsNew   from 'LesliVue/shared/dashboards/apps/new.vue'

// · Ticket workspaces components
// import ticketWorkspacesList  from './catalog_ticket_workspaces/apps/list.vue'
// import ticketWorkspacesEdit  from './catalog_ticket_workspaces/apps/edit.vue'
// import ticketWorkspacesNew   from './catalog_ticket_workspaces/apps/new.vue'

// · Ticket categories components
import ticketCategoriesList  from './catalog_ticket_categories/apps/list.vue'
import ticketCategoriesEdit  from './catalog_ticket_categories/apps/edit.vue'
import ticketCategoriesShow  from './catalog_ticket_categories/apps/show.vue'
import ticketCategoriesNew   from './catalog_ticket_categories/apps/new.vue'

// · Ticket priorities components
// import ticketPrioritiesList  from './catalog_ticket_priorities/apps/list.vue'
// import ticketPrioritiesEdit  from './catalog_ticket_priorities/apps/edit.vue'
// import ticketPrioritiesNew   from './catalog_ticket_priorities/apps/new.vue'

// · Ticket types components
// import ticketTypesList  from './catalog_ticket_types/apps/list.vue'
// import ticketTypesNew   from './catalog_ticket_types/apps/new.vue'
// import ticketTypesEdit  from './catalog_ticket_types/apps/edit.vue'

// · Report components
// import reportsList from './reports/apps/list.vue'

// · Slas components
// import slasList from './slas/apps/list.vue'
// import slasEdit from './slas/apps/edit.vue'
// import slasNew from './slas/apps/new.vue'
// import slasShow from './slas/apps/show.vue'

// · Tickets components
// import ticketsList from './tickets/apps/list.vue'
// import ticketsEdit from './tickets/apps/edit.vue'
// import ticketsNew from './tickets/apps/new.vue'
// import ticketsShow from './tickets/apps/show.vue'

// · Import a list of all dashboard components
import componentNewTickets from './dashboards/components/list-new-tickets.vue'
import componentMyTickets from './dashboards/components/list-my-tickets.vue'
import componentUnassignedTickets from './dashboards/components/list-unassigned-tickets.vue'
import componentTicketsByType from './dashboards/components/chart-tickets-by-type.vue'
import componentTicketsByCategory from './dashboards/components/chart-tickets-by-category.vue'
import componentHoursWorked from './dashboards/components/chart-hours-worked.vue'

// · Import a list of all workflow components
import workflowsList  from 'LesliVue/shared/workflows/apps/list.vue'
import workflowsEdit  from 'LesliVue/shared/workflows/apps/edit.vue'
import workflowsShow  from 'LesliVue/shared/workflows/apps/show.vue'
import workflowsNew   from 'LesliVue/shared/workflows/apps/new.vue'

// ·
app('CloudHelp', '/help', '[account_settings|dashboards|ticket_workspaces|ticket_types|ticket_priorities|ticket_categories|tickets|slas]', [
    {
        path: '/settings',
        component: settingsList
    },
    {
        path: '/',
        component: dashboardsShow,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help',
            newResourceAnchorPath: '/help/tickets/new',
            newResourceAnchorText: ()=>{
                return I18n.t('help.tickets.view_btn_create')
            },
            appMountPath: '/help',
            renderComponents: {
                'component-new-tickets': componentNewTickets,
                'component-my-tickets': componentMyTickets,
                'component-unassigned-tickets': componentUnassignedTickets,
                'component-tickets-by-type': componentTicketsByType,
                'component-tickets-by-category': componentTicketsByCategory,
                'component-hours-worked': componentHoursWorked
            }
        }
    },
    {
        path: '/dashboards',
        component: dashboardsList,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help',
            appMountPath: '/help/dashboards'
        }
    },{
        path: '/dashboards/new',
        component: dashboardsNew,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help',
            appMountPath: '/help/dashboards'
        }
    },
    {
        path: '/dashboards/:id',
        component: dashboardsShow,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help',
            newResourceAnchorPath: '/help/tickets/new',
            newResourceAnchorText: ()=>{
                return I18n.t('help.tickets.view_btn_create')
            },
            appMountPath: '/help/dashboards',
            renderComponents: {
                'component-new-tickets': componentNewTickets,
                'component-my-tickets': componentMyTickets,
                'component-unassigned-tickets': componentUnassignedTickets,
                'component-tickets-by-type': componentTicketsByType,
                'component-tickets-by-category': componentTicketsByCategory,
                'component-hours-worked': componentHoursWorked
            }
        }
    },
    {
        path: '/workflows',
        component: workflowsList,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help',
            appMountPath: '/help/workflows'
        }
    },{
        path: '/workflows/new',
        component: workflowsNew,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help',
            appMountPath: '/help/workflows'
        }
    },{
        path: '/workflows/:id',
        component: workflowsShow,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help',
            appMountPath: '/help/workflows'
        }
    },{
        path: '/workflows/:id/edit',
        component: workflowsEdit,
        props: {
            cloudEngine: 'CloudHelp',
            engineNamespace: 'help',
            appMountPath: '/help/workflows'
        }
    },
    // {
    //     path: '/catalog/ticket_workspaces',
    //     component: ticketWorkspacesList,
    //     props: {
    //         appMountPath: '/help/catalog/ticket_workspaces'
    //     }
    // },{
    //     path: '/catalog/ticket_workspaces/new',
    //     component: ticketWorkspacesNew,
    //     props: {
    //         appMountPath: '/help/catalog/ticket_workspaces'
    //     }
    // },{
    //     path: '/catalog/ticket_workspaces/:id',
    //     component: ticketWorkspacesEdit,
    //     props: {
    //         appMountPath: '/help/catalog/ticket_workspaces'
    //     }
    // },
    {
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
    }
    // ,{
    //     path: '/catalog/ticket_priorities',
    //     component: ticketPrioritiesList,
    //     props: {
    //         appMountPath: '/help/catalog/ticket_priorities'
    //     }
    // },{
    //     path: '/catalog/ticket_priorities/new',
    //     component: ticketPrioritiesNew,
    //     props: {
    //         appMountPath: '/help/catalog/ticket_priorities'
    //     }
    // },{
    //     path: '/catalog/ticket_priorities/:id',
    //     component: ticketPrioritiesEdit,
    //     props: {
    //         appMountPath: '/help/catalog/ticket_priorities'
    //     }
    // }
    // ,{
    //     path: '/catalog/ticket_types',
    //     component: ticketTypesList,
    //     props: {
    //         appMountPath: '/help/catalog/ticket_types'
    //     }
    // },{
    //     path: '/catalog/ticket_types/new',
    //     component: ticketTypesNew,
    //     props: {
    //         appMountPath: '/help/catalog/ticket_types'
    //     }
    // },{
    //     path: '/catalog/ticket_types/:id',
    //     component: ticketTypesEdit,
    //     props: {
    //         appMountPath: '/help/catalog/ticket_types'
    //     }
    // },
    // {
    //     path: '/slas',
    //     component: slasList,
    //     props: {
    //         appMountPath: '/help/slas'
    //     }
    // },
    // {
    //     path: '/slas/new',
    //     component: slasNew,
    //     props: {
    //         appMountPath: '/help/slas'
    //     }
    // },
    // {
    //     path: '/slas/:id',
    //     component: slasShow,
    //     props: {
    //         appMountPath: '/help/slas'
    //     }
    // },
    // {
    //     path: '/slas/:id/edit',
    //     component: slasEdit,
    //     props: {
    //         appMountPath: '/help/slas'
    //     }
    // },
    //,{
    //     path: '/tickets',
    //     component: ticketsList,
    //     props: {
    //         appMountPath: '/help/tickets'
    //     }
    // },
    // {
    //     path: '/tickets/new',
    //     component: ticketsNew,
    //     props: {
    //         appMountPath: '/help/tickets'
    //     }
    // },{
    //     path: '/tickets/:id',
    //     component: ticketsShow,
    //     props: {
    //         appMountPath: '/help/tickets'
    //     }
    // },{
    //     path: '/tickets/:id/edit',
    //     component: ticketsEdit,
    //     props: {
    //         appMountPath: '/help/tickets'
    //     }
    // },
    // {
    //     path: '/reports',
    //     component: reportsList,
    //     props: {
    //         appMountPath: '/help/reports'
    //     }
    // }
],{
    ticket: null,
    sla: null,
    ticket_assignable: false,
    assignment_options: {},
    ticket_images: [],
    checks: {
        reload: false,
        selected_record_id: null,
        records: [],
        active_tab: 0 // 0 -> list, 1 -> new, 2 -> edit
    },
    reload: {
        activities: false,
        timelines: false,
        ticket: false,
        sla: false,
    },
    events: {
        post_auto_assignment: false
    }
})
