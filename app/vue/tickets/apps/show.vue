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
import componentTicketStateName from "../../components/ticket_state_name.vue";
import componentTimeline from "../components/timeline.vue";

// · Component show
// · ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~
export default {
    components: {
        "component-discussion-form": componentDiscussionForm,
        "component-discussion-list": componentDiscussionList,
        "component-action-list": componentActionList,
        "component-file-list": componentFileList,
        "component-timeline": componentTimeline,
        "component-ticket-state-name": componentTicketStateName
    },
    data() {
        return {
            translations: {
                shared: I18n.t("cloud_help.tickets.shared"),
                show: I18n.t("cloud_help.tickets.show")
            },
            ticket_id: null,
            ticket: null,
            assignables: [],
            assignable: null,
            modal: {
                active: false
            }
        };
    },
    mounted() {
        this.ticket_id = this.$route.params.id
        this.getTicket()
        this.getAssignables()
    },
    methods: {
        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}.json`)
            .then(result => {
                if (result.successful) {
                    this.ticket = result.data;
                }else{
                    this.alert(result.error.message,'danger')
                }
            })
            .catch(error => {
                console.log(error);
            });
        },

        getAssignables() {
            this.http.get(`/help/api/tickets/${this.ticket_id}/assignables`).then(result => {
                if (result.successful) {
                    this.assignables = result.data;
                }else{
                    this.alert(result.error.message,'danger')
                }
            })
            .catch(error => {
                console.log(error);
            });
        },

        assignTicket() {
            if(this.assignable){
                let data = {
                    ticket: {
                        assignment_attributes: {
                            assignable_id: this.assignable.id,
                            assignable_type: this.assignable.assignable_type
                        }
                    }
                }
                this.modal.active = false

                this.http.post(`/help/api/tickets/${this.ticket_id}/assign`, data).then(result => {
                    if (result.successful) {
                        this.ticket = result.data
                        this.alert(this.translations.show.messages.assignment.successful)
                    }else{
                        this.alert(result.error.message,'danger')
                    }
                })
                .catch(error => {
                    console.log(error);
                });
            }else{
                this.alert(this.translations.show.messages.assignment.uselected, 'danger')
            }
        }
    }
};
</script>
<template>
    <div class="columns" v-if="ticket">
        <b-modal :active.sync="modal.active">
            <div class="card">
                <header class="card-header">
                    <p class="card-header-title">{{translations.show.modal.title}}</p>
                </header>
                <div class="card-content">
                    <b-table
                        :data="assignables"
                        :selected.sync="assignable"
                        :paginated="true"
                        :per-page="5"
                        :pagination-simple="true"
                    >
                        <template slot-scope="props">
                            <b-table-column field="id" :label="translations.show.modal.fields.user.id" width="40" numeric>
                                {{ props.row.id }}
                            </b-table-column>
                            <b-table-column field="email" :label="translations.show.modal.fields.user.email">
                                {{ props.row.email }}
                            </b-table-column>
                            <b-table-column field="first_name" :label="translations.show.modal.fields.user.first_name">
                                {{ props.row.first_name }}
                            </b-table-column>
                            <b-table-column field="last_name" :label="translations.show.modal.fields.user.last_name">
                                {{ props.row.last_name }}
                            </b-table-column>
                            <b-table-column field="created_at" :label="translations.show.modal.fields.user.created_at">
                                {{ date.toLocalFormat(props.row.created_at) }}
                            </b-table-column>
                        </template>
                    </b-table>
                </div>
                <div class="card-footer has-text-right">
                    <button class="card-footer-item button is-primary" @click="assignTicket">
                        {{translations.show.modal.actions.assign}}
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modal.active=false">
                        {{translations.show.modal.actions.cancel}}
                    </button>
                </div>
            </div>
        </b-modal>
        <div class="column is-8">
            <div class="card box">
                <div class="card-header">
                    <h4 class="card-header-title">{{ ticket.detail_attributes.subject }}</h4>
                    <div class="card-header-icon">
                        <router-link :to="`/${ticket_id}/edit`">
                            <i class="fas fa-edit"></i>
                            {{translations.shared.actions.edit}}
                        </router-link>
                        <router-link :to="'/'">
                            &nbsp;&nbsp;&nbsp;
                            <i class="fas fa-undo"></i>
                            {{translations.shared.actions.return}}
                        </router-link>
                    </div>
                </div>
                <div class="card-content">
                    <div class="columns">
                        <div class="column is-8">
                            <span class="has-text-weight-bold">{{ `${translations.shared.fields.category}:` }}</span>
                            {{ ticket.detail_attributes.category}}
                            <br>
                            <span
                                class="has-text-weight-bold"
                            >{{ `${translations.shared.fields.type}:` }}</span>
                            {{ ticket.detail_attributes.type}},
                            <span
                                class="has-text-weight-bold"
                            >{{ `${translations.shared.fields.state}:` }}</span>
                            <component-ticket-state-name :name="ticket.detail_attributes.state"></component-ticket-state-name>
                        </div>
                        <div class="column is-4 has-text-right">
                            <span class="has-text-weight-bold is-size-5">
                                {{ `${translations.shared.fields.priority}:` }}
                                <span
                                    class="has-text-danger"
                                >{{ ticket.detail_attributes.priority}}</span>
                            </span>
                        </div>
                    </div>
                    <div class="columns">
                        <div class="column">
                            <span class="has-text-weight-bold">{{ `${translations.shared.fields.description}:` }}</span>
                            <div v-html="ticket.detail_attributes.description"></div>
                        </div>
                    </div>
                    <div class="columns">
                        <div class="column is-8">
                            <span class="has-text-weight-bold">{{ translations.show.titles.created_by }}:</span>
                            {{ ticket.detail_attributes.email}}
                            <br />
                            <span class="has-text-weight-bold">{{translations.show.titles.date}}:</span>
                            {{ date.toLocalFormat(ticket.created_at, false, true) }}
                            <br />
                            <span class="has-text-weight-bold">{{translations.show.titles.assigned}}:</span>
                            {{ticket.assignable_name}} ({{translations.shared.assignable_types[ticket.assignable_type]}})
                        </div>
                        <div class="column is-4 has-text-right">
                            <button
                                class="button is-primary"
                                @click="modal.active = true"
                            >{{translations.show.actions.assign}}</button>
                        </div>
                    </div>
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
