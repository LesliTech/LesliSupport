<script>
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

@dev      Luis Donis <ldonis@lesli.tech>
@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/



// · Import modules, components and apps
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentWorkflowStateName from "LesliCloud/vue/cloud_object/workflow_states/components/state-name.vue"

export default {
    components: {
        'component-workflow-state-name': componentWorkflowStateName
    },
    props: {
        state: {
            type: String,
            default: 'created'
        },
        creation_date: {
            type: String,
            default: '2019-01-01'
        },
        resolution_date: {
            type: String,
            default: '2019-01-01'
        }
    },
    data(){
        return {
            translations: I18n.t('cloud_help.tickets.status')
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <h4 class="card-header-title">
                <component-workflow-state-name
                    :name="state"
                    :translations-shared-path="'cloud_help.ticket_states.shared'"
                />
            </h4>
        </div>
        <div class="card-content">
            <div class="field">
                <i class="fas fa-info-circle has-text-link"></i>
                <label for="">{{translations.creation_date}}</label>
                <p>{{date.toLocalFormat(creation_date, false, true)}}</p>
            </div>
            <div class="field">
                <i class="fas fa-info-circle has-text-link"></i>
                <label for="">{{translations.due_date}}</label>
                <p>{{date.toLocalFormat(resolution_date, false, true)}}</p>
            </div>
        </div>
    </div>
</template>
