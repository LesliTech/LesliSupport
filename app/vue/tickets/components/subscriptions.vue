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

@dev      Carlos Hermosilla <ldonis@lesli.tech>
@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/

export default {
    props: {
        active: {
            type: Boolean,
            default: false
        },
        ticket_id: {
            type: String,
            default: null
        }
    },
    
    data() {
        return {
            translations: I18n.t('cloud_help.tickets.subscriptions'),
            modal: {
                active: false
            },
            events: []
        }
    },
    
    mounted(){
        this.syncFlags()
    },

    methods: {
        syncFlags(){
            this.modal.active = this.active
        },

        getEvents(){
            this.http.get(`/help/api/tickets/${this.ticket_id}/events`).then(result => {
                if (result.successful) {
                    this.events = result.data
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        putSubscriptions(e){
            if (e) { e.preventDefault() }

            let events = this.events.filter(event => {
                return event.id || event.subscribed
            }).map(event => {
                if(! event.subscribed){
                    event._destroy = true
                }
                return event
            })
            
            this.modal.active = false
            let data = {
                ticket: {
                    subscribers_attributes: events
                }
            }
            this.http.put(`/help/api/tickets/${this.ticket_id}/subscribe`, data).then(result => {
                if (result.successful) {
                    this.events = result.data
                    this.alert(this.translations.messages.subscribe.successful)
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }
    },

    watch: {
        'modal.active': function(){
            if(this.active != this.modal.active){
                this.$emit('update:active', this.modal.active)
            }
        },
        active(){
            if(this.active != this.modal.active){
                this.modal.active = this.active
            }
        },
        ticket_id(){
            if(this.ticket_id){
                this.getEvents()
            }
        }
    }
}
</script>
<template>
    <section>
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
                        {{translations.title}}
                    </h2>
                </div>
                <div class="card-content">
                    {{translations.instructions}}
                    <hr>
                    <form @submit="putSubscriptions">
                        <div v-for="event in events" :key="event.event" class="field">
                            <b-checkbox v-model="event.subscribed">
                                {{translations.events[event.event]}}
                            </b-checkbox>
                        </div>
                        <div class="field">
                            <div class="actions has-text-right">
                                <button class="button is-primary" type="submit">
                                    {{translations.actions.subscribe}}
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </b-modal>
    </section>
</template>

