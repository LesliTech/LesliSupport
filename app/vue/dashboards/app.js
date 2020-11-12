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
import appList  from "LesliCoreVue/cloud_objects/dashboards/apps/list.vue"
import appEdit  from "LesliCoreVue/cloud_objects/dashboards/apps/edit.vue"
import appNew   from "LesliCoreVue/cloud_objects/dashboards/apps/new.vue"

// · Import a list of all dashboard components
import componentNewTickets from "./components/list-new-tickets.vue"

app("CloudHelp", "[list|new|edit]", "/help/dashboards", [{
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
    component: appEdit,
    props: {
        cloudEngine: "CloudHelp",
        engineNamespace: "help",
        renderComponents: {
            "component-new-tickets": componentNewTickets,
        }
    }
}])
