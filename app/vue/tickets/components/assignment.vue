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

@dev      Carlos Hermosilla
@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/

export default {
    props: {
        currentAssignable: {
            required: true
        }
    },

    data() {
        return {
            show: false,
            ticket_id: null,
            translations: {
                shared: I18n.t('cloud_help.tickets.shared'),
                assignment: I18n.t('cloud_help.tickets.assignment')
            },
            assignable: null,
            assignables: null,
            modal: {
                active: false
            }
        }
    },
    
    mounted(){
        this.bus.subscribe("show:/help/ticket/assignment", () => this.show = !this.show )
        this.ticket_id = this.$route.params.id
        this.getTicketAssignments()
    },

    methods: {
        
        getTicketAssignments() {
            this.http.get(`/help/tickets/${this.ticket_id}/assignments`).then(result => {
                if (result.successful) {
                    this.assignables = result.data;
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error);
            })
        },

        patchTicketAssignment() {
            if(this.assignable){
                let data = {
                    ticket: {
                        assignment_attributes: {
                            assignation_type: 'user',
                            users_id:  this.assignable.id
                        }
                    }
                }
                this.modal.active = false
                this.show = false
                this.http.patch(`/help/tickets/${this.ticket_id}`, data).then(result => {
                    if (result.successful) {
                        this.alert(this.translations.assignment.messages.assignment.user.successful)
                        this.bus.publish('patch:/help/ticket/assignment', result.data.assignment_attributes)
                    }else{
                        this.alert(result.error.message,'danger')
                    }
                }).catch(error => {
                    console.log(error);
                })
            }else{
                this.alert(this.translations.assignment.messages.assignment.user.uselected, 'danger')
            }
        },

        setTicketAssignable(){
            if(this.assignables && this.currentAssignable){
                this.assignable = this.assignables.filter( assignable => {
                    return assignable.id == this.currentAssignable
                })[0]
            }
        }
    },

    watch: {
        assignables(){
            this.setTicketAssignable()
        },
        currentAssignable(){
            this.setTicketAssignable()
        }
    }
}
</script>
<template>
    <section v-if="this.assignables">
        <div :class="[{ 'is-active': show }, 'quickview']">
            <header class="quickview-header" @click="show = false">
                <p class="title">
                    {{translations.assignment.title}}
                </p>
                <i class="fas fa-chevron-right clickable"></i>
            </header>
            <div class="quickview-body">
                <div class="quickview-block">
                    <section class="box">
                        <b-modal 
                            :active.sync="modal.active"
                            has-modal-card
                            trap-focus
                            aria-role="dialog"
                            aria-modal
                        >
                            <div class="card">
                                <div class="card-header is-danger">
                                    <h2 class="card-header-title">
                                        {{ translations.assignment.modals.user.title }}
                                    </h2>
                                </div>
                                <div class="card-content">
                                    {{ translations.assignment.modals.user.body }}
                                </div>
                                <div class="card-footer has-text-right">
                                    <button class="card-footer-item button is-danger" @click="patchTicketAssignment">
                                        {{ translations.assignment.modals.user.actions.assign }}
                                    </button>
                                    <button class="card-footer-item button is-secondary" @click="modal.active = false">
                                        {{ translations.assignment.modals.user.actions.cancel }}
                                    </button>
                                </div>
                            </div>
                        </b-modal>
                        <b-table
                            :data="assignables"
                            :selected.sync="assignable"
                            :paginated="true"
                            :per-page="10"
                            :pagination-simple="true"
                        >
                            <template slot-scope="props">
                                <b-table-column field="id" :label="translations.assignment.fields.user.id" width="40" numeric>
                                    {{ props.row.id }}
                                </b-table-column>
                                <b-table-column field="email" :label="translations.assignment.fields.user.email">
                                    {{ props.row.email }}
                                </b-table-column>
                            </template>
                        </b-table>
                    </section>
                </div>
            </div>
            <footer class="quickview-footer">
                <button class="card-footer-item button is-primary" type="button" @click="modal.active = true">
                    {{translations.assignment.actions.assign_to_user}}
                </button>
            </footer>
        </div>
    </section>
</template>
<style scoped>
.clickable{
    cursor: pointer;
}
</style>
