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
                form: I18n.t('cloud_help.ticket_types.form'),
                shared: I18n.t('cloud_help.ticket_types.shared'),
            },
            ticket_type_id: null,
            ticket_type: {}
        }
    },
    mounted() {
        this.setTicketTypeId()
    },
    methods: {

        setTicketTypeId(){
            if (this.$route.params.id) {
                this.ticket_type_id = this.$route.params.id
                this.getTicketType()
            }
        },

        submitTicketType(event){
            if (event) { event.preventDefault() }
            if(this.ticket_type_id){
                this.putTicketType()
            }else{
                this.postTicketType()
            }
        },

        putTicketType() {
            this.http.put(`/help/ticket_types/${this.ticket_type_id}`, {
                ticket_type: this.ticket_type
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.form.messages.update.successful,'success')
                    this.$router.push(`/${this.ticket_type_id}`)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        postTicketType() {
            this.http.post("/help/ticket_types", {
                ticket_type: this.ticket_type
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

        getTicketType() {
            this.http.get(`/help/ticket_types/${this.ticket_type_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket_type = result.data
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
                    <router-link v-if="ticket_type_id" :to="`/${ticket_type_id}`">
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
                <form @submit="submitTicketType">
                    <b-field :label="translations.shared.fields.name">
                        <b-input v-model="ticket_type.name" required="true"></b-input>
                    </b-field>
                    <div class="columns">
                        <div v-if="ticket_type_id" class="column">
                            <div class="field">
                                <small>
                                    <span class="has-text-weight-bold">
                                        {{ `${translations.shared.fields.created_at}:` }}
                                    </span>
                                    {{ ticket_type.created_at }}
                                    <br>
                                    <span class="has-text-weight-bold">
                                        {{ `${translations.shared.fields.updated_at}:` }}
                                    </span>
                                    {{ ticket_type.updated_at }}
                                </small>
                            </div>
                        </div>
                        <div class="column">
                            <div class="field">
                                <div class="actions has-text-right">
                                    <button class="button is-primary" type="submit">
                                        <span v-if="ticket_type_id">{{translations.form.actions.update}}</span>
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
