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

// · Component assign
// · ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~         ~·~
export default {
    components: {
        "component-discussion-form": componentDiscussionForm,
        "component-discussion-list": componentDiscussionList,
        "component-action-list": componentActionList,
        "component-file-list": componentFileList,
        "component-ticket-info-display": componentTicketInfoDisplay
    },
    data(){
        return {
            ticket_id: null,
            translations: {
                shared: I18n.t('cloud_help.tickets.shared'),
                assign: I18n.t('cloud_help.tickets.assign')
            },
            assignables: {
                user: [],
                team: []
            },
            ticket: null,
            selected_user: null,
            selected_team: null,
            modals: {
                user: {
                    active: false
                }
            }
        }
    },
    mounted() {
        this.ticket_id = this.$route.params.id
        this.getTicket()
        this.getTicketAssignables()
    },
    methods: {
        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket = result.data
                }else{
                    this.alert(result.error.message,"danger")
                }
            }).catch(error => {
                console.log(error);
            })
        },
        
        getTicketAssignables() {
            this.http.get(`/help/api/tickets/assignables`).then(result => {
                if (result.successful) {
                    this.assignables = result.data;
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error);
            })
        },

        setTicketAssignable(){
            let user_id = this.ticket.assignment_attributes.users_id
            if( user_id ){
                this.selected_user = this.assignables.user.filter( user => user.id == user_id)[0]
            }
            //TODO: IMPLEMENT TEAMS
        },

        assignTicketToUser() {
            if(this.selected_user){
                let data = {
                    ticket: {
                        assignment_attributes: {
                            assignation_type: 'user',
                            users_id:  this.selected_user.id
                        }
                    }
                }
                this.modals.user.active = false
                this.http.post(`/help/api/tickets/${this.ticket_id}/assign`, data).then(result => {
                    if (result.successful) {
                        this.alert(this.translations.assign.messages.assignment.user.successful)
                        this.$router.push(`/${this.ticket_id}`)
                    }else{
                        this.alert(result.error.message,'danger')
                    }
                }).catch(error => {
                    console.log(error);
                })
            }else{
                this.alert(this.translations.assign.messages.assignment.user.uselected, 'danger')
            }
        },
    },
    watch:{
        ticket(){
            if(this.assignables){
                this.setTicketAssignable()
            }
        },
        assignables(){
            if(this.ticket){
                this.setTicketAssignable()
            }
        }
    }
}
</script>
<template>
    <div class="columns is-multiline" v-if="ticket">
        <b-modal 
            :active.sync="modals.user.active"
            has-modal-card
            trap-focus
            aria-role="dialog"
            aria-modal
        >
            <div class="card">
                <div class="card-header is-danger">
                    <h2 class="card-header-title">
                        {{ translations.assign.modals.user.title }}
                    </h2>
                </div>
                <div class="card-content">
                    {{ translations.assign.modals.user.body }}
                </div>
                <div class="card-footer has-text-right">
                    <button class="card-footer-item button is-danger" @click="assignTicketToUser">
                        {{ translations.assign.modals.user.actions.assign }}
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modals.user.active = false">
                        {{ translations.assign.modals.user.actions.cancel }}
                    </button>
                </div>
            </div>
        </b-modal>
        <div class="column is-12">
            <div class="card box">
                <div class="card-header">
                    <h4 class="card-header-title">{{ translations.assign.title }}</h4>
                    <div class="card-header-icon">
                        <router-link :to="`/${ticket_id}`">
                            <i class="fas fa-eye"></i>
                            {{translations.shared.actions.show}}
                        </router-link>
                        <router-link :to="'/'">
                            &nbsp;&nbsp;&nbsp;
                            <i class="fas fa-undo"></i>
                            {{translations.shared.actions.return}}
                        </router-link>
                    </div>
                </div>
                <div class="card-content">
                    <div class="columns is-multiline">
                        <div class="column is-12">
                            <span class="has-text-weight-bold">{{translations.shared.titles.assigned}}:</span>
                            {{ticket.assignment_attributes.assignable_name}}
                            ({{translations.shared.assignation_types[ticket.assignment_attributes.assignation_type]}})
                        </div>
                        <hr>
                        <div class="column is-6">
                             <h4 class="has-text-weight-bold">{{translations.assign.titles.assign_to_user}}</h4>
                            <b-table
                                :data="assignables.user"
                                :selected.sync="selected_user"
                                :paginated="true"
                                :per-page="5"
                                :pagination-simple="true"
                            >
                                <template slot-scope="props">
                                    <b-table-column field="id" :label="translations.assign.fields.user.id" width="40" numeric>
                                        {{ props.row.id }}
                                    </b-table-column>
                                    <b-table-column field="email" :label="translations.assign.fields.user.email">
                                        {{ props.row.email }}
                                    </b-table-column>
                                    <b-table-column field="created_at" :label="translations.assign.fields.user.created_at">
                                        {{ date.toLocalFormat(props.row.created_at) }}
                                    </b-table-column>
                                </template>
                            </b-table>
                            <div class="field">
                                <div class="actions has-text-right">
                                    <button class="button is-primary" type="submit" @click="modals.user.active = true">
                                        {{translations.assign.actions.assign_to_user}}
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="column is-6">
                             <h4 class="has-text-weight-bold">{{translations.assign.titles.assign_to_team}}</h4>
                            <span class="has-text-grey">{{translations.shared.not_implemented}}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="column is-12">
            <div class="card box">
                <div class="card-header">
                    <h4 class="card-header-title">{{ ticket.detail_attributes.subject }}</h4>
                </div>
                <div class="card-content">
                    <component-ticket-info-display :ticket="ticket" />
                </div>
            </div>
            <component-discussion-form cloud-module="help/ticket" :cloud-id="ticket_id" class="box" />
            <component-discussion-list cloud-module="help/ticket" :cloud-id="ticket_id" />
        </div>
        <component-action-list cloud-module="help/ticket" :cloud-id="ticket_id" />
        <component-file-list cloud-module="help/ticket" :cloud-id="ticket_id" />
    </div>
</template>
