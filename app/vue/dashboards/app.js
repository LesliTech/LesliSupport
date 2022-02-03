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
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import app from "LesliCoreVue/app"

// · Import apps and components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import appList  from "LesliVue/shared/dashboards/apps/list.vue"
import appShow  from "LesliVue/shared/dashboards/apps/show.vue"
import appNew   from "LesliVue/shared/dashboards/apps/new.vue"

// · Import a list of all dashboard components
import componentNewTickets from "./components/list-new-tickets.vue"
import componentMyTickets from "./components/list-my-tickets.vue"
import componentUnassignedTickets from "./components/list-unassigned-tickets.vue"
import componentTicketsByType from "./components/chart-tickets-by-type.vue"
import componentTicketsByCategory from "./components/chart-tickets-by-category.vue"
import componentHoursWorked from "./components/chart-hours-worked.vue"

app("CloudHelp", "[list|new|show/edit]", "/help/dashboards", [{
    path: "/",
    component: appList,
    props: {
        cloudEngine: "CloudHelp",
        engineNamespace: "help"
    }
},{
    path: "/new",
    component: appNew,
    props: {
        cloudEngine: "CloudHelp",
        engineNamespace: "help"
    }
},{
    path: "/:id",
    component: appShow,
    props: {
        cloudEngine: "CloudHelp",
        engineNamespace: "help",
        newResourceAnchorPath: "/help/tickets/new",
        newResourceAnchorText: ()=>{
            return I18n.t("help.tickets.view_btn_create")
        },
        renderComponents: {
            "component-new-tickets": componentNewTickets,
            "component-my-tickets": componentMyTickets,
            "component-unassigned-tickets": componentUnassignedTickets,
            "component-tickets-by-type": componentTicketsByType,
            "component-tickets-by-category": componentTicketsByCategory,
            "component-hours-worked": componentHoursWorked
        }
    }
}])
