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
import componentStateName from '../../components/ticket_state_name.vue'

export default {
    components: {
        'component-state-name': componentStateName
    },

    data() {
        return {
            translations:{
                shared: I18n.t('cloud_help.ticket_states.shared')
            },
            ticket_states: [],
            columns: []
        }
    },
    mounted() {
        this.setColumns()
        this.getTicketStates()
    },
    methods: {

        setColumns(){
            this.columns = [{
                field: 'id',
                label: this.translations.shared.fields.id,
                width: 40,
                centered: true,
                numeric: true
            }, {
                field: 'name',
                label: this.translations.shared.fields.name
            }, {
                field: 'created_at',
                label: this.translations.shared.fields.created_at
            }, {
                field: 'updated_at',
                label: this.translations.shared.fields.updated_at
            }];
        },

        getTicketStates() {
            this.http.get("/help/ticket_states.json").then(result => {
                if (result.successful) {
                    this.ticket_states = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        showTicketState(ticket_state) {
            this.$router.push(`/${ticket_state.id}`)
        }

    }
}
</script>
<template>
    <section class="section">
        <b-table :data="ticket_states" @click="showTicketState" :hoverable="true">
            <template v-slot="props">
                <b-table-column field="id" :label="translations.shared.fields.id" width="40" centered numeric>
                    {{props.row.id}}
                </b-table-column>
                <b-table-column field="name" :label="translations.shared.fields.name">
                    <component-state-name
                        :name="props.row.name"
                        :initial="props.row.initial"
                        :final="props.row.final"
                    >
                    </component-state-name>
                </b-table-column>
                <b-table-column field="created_at" :label="translations.shared.fields.created_at">
                    {{props.row.created_at}}
                </b-table-column>
                <b-table-column field="updated_at" :label="translations.shared.fields.updated_at">
                    {{props.row.updated_at}}
                </b-table-column>
            </template>
        </b-table>
    </section>
</template>
<style>
    table tr:hover {
        cursor: pointer;
    }
</style>
