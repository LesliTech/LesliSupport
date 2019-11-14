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
export default {
    data() {
        return {
            translations: {
                form: I18n.t('cloud_help.ticket_priorities.form'),
                shared: I18n.t('cloud_help.ticket_priorities.shared'),
            },
            ticket_priority_id: null,
            ticket_priority: {}
        }
    },
    mounted() {
        this.setTicketPriorityId()
    },
    methods: {

        setTicketPriorityId(){
            if (this.$route.params.id) {
                this.ticket_priority_id = this.$route.params.id
                this.getTicketPriority()
            }
        },

        submitTicketPriority(event){
            if (event) { event.preventDefault() }
            if(this.ticket_priority_id){
                this.putTicketPriority()
            }else{
                this.postTicketPriority()
            }
        },

        putTicketPriority() {
            this.http.put(`/help/ticket_priorities/${this.ticket_priority_id}`, {
                ticket_priority: this.ticket_priority
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.form.messages.update.successful,'success')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        postTicketPriority() {
            this.http.post("/help/ticket_priorities", {
                ticket_priority: this.ticket_priority
            }).then(result => {
                if (result.successful) {
                    this.ticket_priority = result.data
                    this.$router.push(`${this.ticket_priority.id}`)
                }else{
                    this.alert(result.error,'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        getTicketPriority() {
            this.http.get(`/help/api/ticket_priorities/${this.ticket_priority_id}`).then(result => {
                if (result.successful) {
                    this.ticket_priority = result.data
                }else{
                    this.alert(result.error,'danger')
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
                    <router-link v-if="ticket_priority_id" :to="`/${ticket_priority_id}`">
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
                <form @submit="submitTicketPriority">
                    <div class="columns">
                        <div class="column">
                            <b-field :label="translations.shared.fields.name">
                                <b-input v-model="ticket_priority.name" required="true"></b-input>
                            </b-field>
                        </div>
                        <div class="column">
                            <b-field :label="translations.shared.fields.weight">
                                <b-input max="1000000" min="0" v-model="ticket_priority.weight" type="number" required="true" >
                                </b-input>
                            </b-field>
                        </div>
                    </div>
                    <div class="columns">
                        <div v-if="ticket_priority_id" class="column">
                            <div class="field">
                                <small>
                                    <span class="has-text-weight-bold">
                                        {{ `${translations.shared.fields.created_at}:` }}
                                    </span>
                                    {{ ticket_priority.created_at }}
                                    <br>
                                    <span class="has-text-weight-bold">
                                        {{ `${translations.shared.fields.updated_at}:` }}
                                    </span>
                                    {{ ticket_priority.updated_at }}
                                </small>
                            </div>
                        </div>
                        <div class="column">
                            <div class="field">
                                <div class="actions has-text-right">
                                    <button class="button is-primary" type="submit">
                                        <span v-if="ticket_priority_id">{{translations.form.actions.update}}</span>
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
