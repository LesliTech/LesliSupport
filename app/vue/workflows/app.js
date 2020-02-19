/*
Copyright (c) 2020, Lesli Technologies, S. A.

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

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description App that allows the user to create a new Ticket category

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · Import main app from core
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import app from 'LesliCoreVue/app'



// · Import apps and components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import appList from 'LesliCoreVue/cloud_objects/workflows/apps/list.vue'
import appNew from 'LesliCoreVue/cloud_objects/workflows/apps/new.vue'
import appShow from 'LesliCoreVue/cloud_objects/workflows/apps/show.vue'
import appEdit from 'LesliCoreVue/cloud_objects/workflows/apps/edit.vue'


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
app('CloudHelp', '[list|new|show|edit]', 'help/workflows', [{
    path: '/',
    component: appList,
    props: {
        cloudModule: 'help/'
    }
},{
    path: '/new',
    component: appNew,
    props: {
        cloudModule: 'help/'
    }
},{
    path: '/:id',
    component: appShow,
    props: {
        cloudModule: 'help/'
    }
},{
    path: '/:id/edit',
    component: appEdit,
    props: {
        cloudModule: 'help/'
    }
}])
