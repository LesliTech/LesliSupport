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


// · Component list
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    data() {
        return {
            tickets: [],
            columns: [{
                field: 'id',
                label: 'Number',
                centered: true,
                numeric: true,
                width: '40'
            }, {
                field: 'subject',
                label: 'Subject'
            }, {
                field: 'status',
                label: 'Status'
            }, {
                field: 'created_at',
                label: 'Created',
                centered: true
            }]
        }
    },
    mounted() {
        this.getTickets()
    },
    methods: {

        getTickets() {

            this.http.get("/help/tickets.json").then(result => {
                if (result.successful) {
                    this.tickets = result.data
                }
            }).catch(error => {
                console.log(error)
            })

        },

        clickTicket(ticket) {
            this.$router.push(`${ticket.id}`)
        }

    }
}
</script>
<template>
    <section class="section">
        <b-table :data="tickets" :columns="columns" @click="clickTicket" :hoverable="true">
        </b-table>
    </section>
</template>
<style>
    table tr:hover {
        cursor: pointer;
    }
</style>
