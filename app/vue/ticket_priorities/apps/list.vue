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


// · Component list
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    data() {
        return {
            translations:{
                shared: I18n.t('cloud_help.ticket_priorities.shared')
            },
            tickets: [],
            columns: []
        }
    },
    mounted() {
        this.setColumns()
        this.getPriorities()
    },
    methods: {

        setColumns(){
            this.columns = [{
                field: 'id',
                label: this.translations.shared.fields.id,
                centered: true,
                numeric: true
            }, {
                field: 'name',
                label: this.translations.shared.fields.name
            }, {
                field: 'weight',
                label: this.translations.shared.fields.weight,
            }, {
                field: 'created_at',
                label: this.translations.shared.fields.created_at
            }, {
                field: 'updated_at',
                label: this.translations.shared.fields.updated_at
            }];
        },

        getPriorities() {
            this.http.get("/help/ticket_priorities.json").then(result => {
                if (result.successful) {
                    this.tickets = result.data
                }else{
                    this.alert(result.error,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        showPriority(ticket_priority) {
            this.$router.push(`${ticket_priority.id}`)
        }

    }
}
</script>
<template>
    <section class="section">
        <b-table :data="tickets" :columns="columns" @click="showPriority" :hoverable="true">
        </b-table>
    </section>
</template>
<style>
    table tr:hover {
        cursor: pointer;
    }
</style>
