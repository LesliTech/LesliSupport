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
import VueTrix from "vue-trix"



// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-trix-editor': VueTrix
    },
    data() {
        return {
            ticket_id: null,
            ticket: {
                detail_attributes: {
                    subject: "",
                    description: ""
                }
            }
        }
    },
    mounted() {
        if (this.$route.params.id) {
            this.ticket_id = this.$route.params.id
        }
    },
    methods: {

        putTicket(e) {

            if (e) { e.preventDefault() }

            //delete this.ticket.cloud_help_accounts_id

            this.http.put("/help/tickets/"+this.ticket_id, {
                ticket: this.ticket
            }).then(result => {
                if (result.successful) {
                    this.alert("Ticket updated successfuly")
                }
            }).catch(error => {
                console.log(error)
            })

        },

        postTicket(e) {

            if (e) { e.preventDefault() }

            this.http.post("/help/tickets", {
                ticket: this.ticket
            }).then(result => {
                this.ticket = result.data
                this.$router.push(`${this.ticket.id}/show`)
            }).catch(error => {
                console.log(error)
            })

        },

        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}`).then(result => {
                if (result.successful) {
                    this.ticket.detail_attributes = {
                        id: result.data.id,
                        subject: result.data.subject,
                        description: result.data.description
                    }
                }
            }).catch(error => {
                console.log(error)
            })
        }

    },
    watch: {
        ticket_id(ticket_id) {
            this.getTicket()
        }
    }
}
</script>
<template>
    <section class="section">
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    Ticket
                </h2>
                <router-link v-if="ticket_id" :to="`/${ticket.id}/show`" class="card-header-icon">
                    show
                </router-link>
            </div>
            <div class="card-content">
                <form>
                    <b-field label="Subject">
                        <b-input v-model="ticket.detail_attributes.subject"></b-input>
                    </b-field>
                    <div class="field">
                        <label for="article.content" class="label">Content</label>
                        <div class="control">
                            <component-trix-editor v-model="ticket.detail_attributes.description"></component-trix-editor>
                        </div>
                    </div>
                    <div class="field">
                        <div class="actions">
                            <button class="button is-primary" v-if="!ticket_id" @click="postTicket">Create ticket</button>
                            <button class="button is-primary" v-if="ticket_id" @click="putTicket">Update ticket</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</template>
