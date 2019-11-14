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
                    this.alert("Ticket updated successfuly")
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
                    this.$router.push(`${this.ticket_priority.id}/show`)
                }else{
                    this.alert(result.error,'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        getTicketPriority() {
            this.http.get(`/help/ticket_priorities/${this.ticket_priority_id}/edit`).then(result => {
                if (result.successful) {
                    this.ticket = result.data
                }else{
                    this.alert(result.error,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        goToList(){
            this.$router.push(`/`)
        }

    }
}
</script>
<template>
    <section>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    Ticket Priority
                </h2>
                <h2 class="card-header-options">
                    <a @click="goToList">
                        <i class="fas fa-undo"></i>
                        Return
                    </a>
                </h2>
                <router-link v-if="ticket_priority_id" :to="`/${ticket_priority_id}/show`" class="card-header-icon">
                    Show
                </router-link>
            </div>
            <div class="card-content">
                <form @submit="submitTicketPriority">
                    <div class="columns">
                        <div class="column">
                            <b-field label="Name">
                                <b-input v-model="ticket_priority.name" required="true"></b-input>
                            </b-field>
                        </div>
                        <div class="column">
                            <b-field label="Weight">
                                <b-input max="1000000" min="0" v-model="ticket_priority.weight" type="number" required="true" >
                                </b-input>
                            </b-field>
                        </div>
                    </div>
                    
                    <div v-if="ticket_priority_id" class="field">
                        <p>
                            Created at: {{ ticket_priority.created_at }}, 
                            Updated at: {{ ticket_priority.updated_at }}
                        </p>
                    </div>
                    <div class="field">
                        <div class="actions">
                            <button class="button is-primary" v-if="!ticket_priority_id" type="submit">Create Priority</button>
                            <button class="button is-primary" v-if="ticket_priority_id" type="submit">Update Priority</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</template>
