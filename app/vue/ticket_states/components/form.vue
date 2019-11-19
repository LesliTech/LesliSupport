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
            translations: {
                form: I18n.t('cloud_help.ticket_states.form'),
                shared: I18n.t('cloud_help.ticket_states.shared'),
            },
            ticket_state_id: null,
            ticket_state: {}
        }
    },
    mounted() {
        this.setTicketStateId()
    },
    methods: {

        setTicketStateId(){
            if (this.$route.params.id) {
                this.ticket_state_id = this.$route.params.id
                this.getTicketState()
            }
        },

        submitTicketState(event){
            if (event) { event.preventDefault() }
            if(this.ticket_state_id){
                this.putTicketState()
            }else{
                this.postTicketState()
            }
        },

        putTicketState() {
            this.http.put(`/help/ticket_states/${this.ticket_state_id}`, {
                ticket_state: this.ticket_state
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.form.messages.update.successful,'success')
                    this.$router.push(`/${this.ticket_state_id}`)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        postTicketState() {
            this.http.post("/help/ticket_states", {
                ticket_state: this.ticket_state
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.form.messages.create.successful,'success')
                    this.$router.push(`/${result.data.id}`)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        getTicketState() {
            this.http.get(`/help/api/ticket_states/${this.ticket_state_id}`).then(result => {
                if (result.successful) {
                    this.ticket_state = result.data
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
    <section>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    {{translations.shared.name}}
                </h2>
                <div class="card-header-icon">
                    <router-link v-if="ticket_state_id" :to="`/${ticket_state_id}`">
                        <i class="fas fa-eye"></i>
                        {{translations.shared.actions.show}}
                    </router-link>
                    <router-link :to="`/`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        {{translations.shared.actions.return}}
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <form @submit="submitTicketState">
                    <b-field :label="translations.shared.fields.name">
                        <b-input v-model="ticket_state.name" required="true"></b-input>
                    </b-field>
                    <div class="columns">
                        <div v-if="ticket_state_id" class="column">
                            <div class="field">
                                <small>
                                    <span class="has-text-weight-bold">
                                        {{ `${translations.shared.fields.created_at}:` }}
                                    </span>
                                    {{ ticket_state.created_at }}
                                    <br>
                                    <span class="has-text-weight-bold">
                                        {{ `${translations.shared.fields.updated_at}:` }}
                                    </span>
                                    {{ ticket_state.updated_at }}
                                </small>
                            </div>
                        </div>
                        <div class="column">
                            <div class="field">
                                <div class="actions has-text-right">
                                    <button class="button is-primary" type="submit">
                                        <span v-if="ticket_state_id">{{translations.form.actions.update}}</span>
                                        <span v-else>{{translations.form.actions.create}}</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</template>
