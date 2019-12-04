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

@dev            Luis Donis <ldonis@lesli.tech>
@author     LesliTech <hello@lesli.tech>
@license    Propietary - all rights reserved.
@version    0.1.0-alpha

// · ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~
// · 
*/

// · Import modules, components and apps
// · ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~
import componentDiscussionList from "LesliCloud/vue/components/lists/discussion.vue";
import componentDiscussionForm from "LesliCloud/vue/components/forms/discussion.vue";
import componentActionList from "LesliCloud/vue/components/lists/action.vue";
import componentFileList from "LesliCloud/vue/components/lists/file.vue";
import componentTimeline from "../components/timeline.vue";
import componentTicketInfoDisplay from "../components/ticket_info_display.vue";

// · Component show
// · ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~
export default {
    components: {
        "component-discussion-form": componentDiscussionForm,
        "component-discussion-list": componentDiscussionList,
        "component-action-list": componentActionList,
        "component-file-list": componentFileList,
        "component-timeline": componentTimeline,
        "component-ticket-info-display": componentTicketInfoDisplay
    },
    data() {
        return {
            translations: {
                shared: I18n.t("cloud_help.tickets.shared")
            },
            ticket_id: null,
            ticket: null
        }
    },
    mounted() {
        this.ticket_id = this.$route.params.id
        this.getTicket()
    },
    methods: {
        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}.json`)
            .then(result => {
                if (result.successful) {
                    this.ticket = result.data;
                }else{
                    this.alert(result.error.message,"danger")
                }
            })
            .catch(error => {
                console.log(error);
            });
        }
    }
};
</script>
<template>
    <div class="columns" v-if="ticket">
        <div class="column is-8">
            <div class="card box">
                <div class="card-header">
                    <h4 class="card-header-title">{{ ticket.detail_attributes.subject }}</h4>
                    <div class="card-header-icon">
                        <router-link :to="`/${ticket_id}/assign`">
                            <i class="fas fa-user-check"></i>
                            {{translations.shared.actions.assign}}
                        </router-link>
                        <router-link :to="'/'">
                            &nbsp;&nbsp;&nbsp;
                            <i class="fas fa-undo"></i>
                            {{translations.shared.actions.return}}
                        </router-link>
                    </div>
                </div>
                <div class="card-content">
                    <component-ticket-info-display :ticket="ticket" />
                </div>
            </div>
            <component-discussion-form cloud-module="help/ticket" :cloud-id="ticket_id" class="box" />
            <component-discussion-list cloud-module="help/ticket" :cloud-id="ticket_id" />
        </div>
        <div class="column is-4">
            <component-timeline class="card box" />
        </div>
        <component-action-list cloud-module="help/ticket" :cloud-id="ticket_id" />
        <component-file-list cloud-module="help/ticket" :cloud-id="ticket_id" />
    </div>
</template>
