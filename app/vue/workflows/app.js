
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
import app from 'LesliVue/app'

// · Import common apps
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import appList  from 'LesliVue/shared/workflows/apps/list.vue'
import appEdit  from 'LesliVue/shared/workflows/apps/edit.vue'
import appShow  from 'LesliVue/shared/workflows/apps/show.vue'
import appNew   from 'LesliVue/shared/workflows/apps/new.vue'


const props = {
    cloudEngine: "CloudHelp",
    engineNamespace: "help"
}

// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
app("CloudHelp", "[list|new|edit|show]", "/help/workflows", [{
    path: "/",
    component: appList,
    props: props
},{
    path: "/new",
    component: appNew,
    props: props
},{
    path: "/:id",
    component: appShow,
    props: props
},{
    path: "/:id/edit",
    component: appEdit,
    props: props
}])
