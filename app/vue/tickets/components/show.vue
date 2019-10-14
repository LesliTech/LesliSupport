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


// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    data() {
        return {
            ticket_id: null,
            ticket: {}
        }
    },
    mounted() {
        this.ticket_id = this.$route.params.ticket_id
    },
    methods: {
        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}`).then(result => {
                if (result.successful) {
                    this.ticket = result.data
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
                    {{ ticket.subject }}
                </h2>
                <router-link :to="`/${ticket.id}/edit`" class="card-header-icon">
                    edit
                </router-link>
            </div>
            <div class="card-content" v-html="ticket.description">
            </div>
        </div>
    </section>
</template>
