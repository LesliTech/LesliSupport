/*
Lesli

Copyright (c) 2019, Lesli Technologies, S. A.

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

@dev      Carlos Hermosilla
@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  GIT: 0.1.0 alpha

// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
*/


// · Import main app
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import app from 'LesliCloud/vue/app'



// · Import apps and components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import appList from 'LesliCloud/vue/cloud_object/workflow_states/apps/list.vue'
import appNew from 'LesliCloud/vue/cloud_object/workflow_states/apps/new.vue'
import appShow from 'LesliCloud/vue/cloud_object/workflow_states/apps/show.vue'
import appEdit from 'LesliCloud/vue/cloud_object/workflow_states/apps/edit.vue'


// ·
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
app('CloudHelp', '[list|new|show|edit]', 'help/ticket_states', [{
    path: '/',
    component: appList,
    props: {
        cloudModule: 'help',
        cloudObject: 'ticket',
        translationsSharedPath: 'cloud_help.ticket_states.shared'
    }
},{
    path: '/new',
    component: appNew,
    props: {
        cloudModule: 'help',
        cloudObject: 'ticket',
        translationsSharedPath: 'cloud_help.ticket_states.shared',
        translationsFormPath: 'cloud_help.ticket_states.form'
    }
},{
    path: '/:id',
    component: appShow,
    props: {
        cloudModule: 'help',
        cloudObject: 'ticket',
        translationsSharedPath: 'cloud_help.ticket_states.shared',
        translationsShowPath: 'cloud_help.ticket_states.show'
    }
},{
    path: '/:id/edit',
    component: appEdit,
    props: {
        cloudModule: 'help',
        cloudObject: 'ticket',
        translationsSharedPath: 'cloud_help.ticket_states.shared',
        translationsFormPath: 'cloud_help.ticket_states.form'
    }
}])


                