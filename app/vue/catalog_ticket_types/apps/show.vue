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

    data() {
        return {
            ticket_type: {},
            ticket_type_id: null,
            modal:{
                active: false
            }
        }
    },

    mounted() {
        // · SetTicketTypeId calls getTicketType
        this.setTicketTypeId()
    },

    methods: {
        
        setTicketTypeId(){
            if (this.$route.params.id) {
                this.ticket_type_id = this.$route.params.id
                this.getTicketType()
            }
        },

        getTicketType() {
            this.http.get(`/help/catalog/ticket_types/${this.ticket_type_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket_type = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        deleteTicketType(){
            this.modal.active = false
            this.http.delete(`/help/catalog/ticket_types/${this.ticket_type_id}`).then(result => {
                if(result.successful){
                    this.alert('Ticket type deleted successfully','success')
                    this.$router.push('/')
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <section class="section" v-if="ticket_type_id">
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
                        Are you sure you want to delete this type? 
                    </h2>
                </div>
                <div class="card-content">
                    You will only be able to do this if there are no tickets currenty associated to it
                </div>
                <div class="card-footer has-text-right">
                    <button class="card-footer-item button is-danger" @click="deleteTicketType">
                        Yes, delete it
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modal.active=false">
                        Cancel
                    </button>
                </div>
            </div>
        </b-modal>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    Ticket Type
                </h2>
                <div class="card-header-icon">
                    <router-link :to="`/${ticket_type_id}/edit`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-edit"></i>
                        Edit Ticket Type
                    </router-link>
                    <router-link :to="`/`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        Return
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <div class="columns">
                    <div class="column">
                        <p>
                            <span class="has-text-weight-bold">
                                Name:
                            </span>
                            {{ ticket_type.name }}
                        </p>
                    </div>
                </div>
                <div class="columns">
                    <div class="column">
                        <small>
                            <span class="has-text-weight-bold">
                                Created at:
                            </span>
                            {{ date.toLocalFormat(ticket_type.created_at,false,true) }}
                            <br>
                            <span class="has-text-weight-bold">
                                Updated at:
                            </span>
                            {{ date.toLocalFormat(ticket_type.updated_at,false,true) }}
                        </small>
                    </div>
                    <div class="column">
                        <div class="field">
                            <div class="actions has-text-right">
                                <button class="button is-danger" @click="modal.active = true">
                                    Delete Ticket Type
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>
