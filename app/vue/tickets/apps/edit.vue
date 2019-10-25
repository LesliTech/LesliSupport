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
import componentDiscussionList from 'LesliCloud/vue/components/lists/discussion.vue'
import componentDiscussionForm from 'LesliCloud/vue/components/forms/discussion.vue'
import componentActionList from 'LesliCloud/vue/components/lists/action.vue'
import componentFormPriority from '../components/priority.vue'
import componentFormStatus from '../components/status.vue'
import componentFormState from '../components/state.vue'
import componentFormType from '../components/type.vue'
import componentFormTag from '../components/tag.vue'
import componentForm from '../components/form.vue'
import VueTrix from "vue-trix"



// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-discussion-form': componentDiscussionForm,
        'component-discussion-list': componentDiscussionList,
        'component-form-priority': componentFormPriority,
        'component-action-list': componentActionList,
        'component-form-status': componentFormStatus,
        'component-form-state': componentFormState,
        'component-form-type': componentFormType,
        'component-form-tag': componentFormTag,
        'component-form': componentForm,
        'component-trix-editor': VueTrix
    },
    data() {
        return {
            ticket_options: null,
            ticket_id: null,
            ticket: null
        }
    },
    mounted() {
        this.ticket_id = this.$route.params.id
        this.getTicket()
        this.getTicketOptions()
    },
    methods: {

        getTicketOptions() {
            this.http.get('/help/api/tickets/options').then(result => {
                if (result.successful) {
                    this.ticket_options = result.data
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket = result.data
                }
            }).catch(error => {
                console.log(error)
            })
        }

    }
}
</script>
<template>
    <div class="columns" v-if="ticket && ticket_options">
        <div class="column is-8">
            <component-form />
            <component-discussion-form class="box" cloud-module="help/ticket" :cloud-object-id="ticket_id" />
            <component-discussion-list cloud-module="help/ticket" :cloud-object-id="ticket_id" />
        </div>
        <div class="column is-4">
            <component-form-status class="box" />
            <component-form-tag class="box" :ticket="ticket" :options="ticket_options" />
            <component-form-type class="box" :ticket="ticket" :options="ticket_options" />
            <component-form-state class="box" :ticket="ticket" :options="ticket_options" />
            <component-form-priority class="box" :ticket="ticket" :options="ticket_options" />
        </div>
        <component-action-list cloud-module="help/ticket" :cloud-id="ticket_id" />
    </div>
</template>
