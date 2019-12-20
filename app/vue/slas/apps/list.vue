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
                shared: I18n.t('cloud_help.slas.shared')
            },
            slas: []
        }
    },
    mounted() {
        this.getSlas()
    },
    methods: {

        getSlas() {
            this.http.get("/help/slas.json").then(result => {
                if (result.successful) {
                    this.slas = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        showSla(sla) {
            this.$router.push(`/${sla.id}`)
        }

    }
}
</script>
<template>
    <section class="section">
        <b-table :data="slas" @click="showSla" :hoverable="true">
            <template slot-scope="props">
                <b-table-column field="id" :label="translations.shared.fields.id" width="40" numeric centered>
                    {{ props.row.id }}
                </b-table-column>
                <b-table-column field="name" :label="translations.shared.fields.name">
                    {{ props.row.name }}
                    <span v-if="props.row.default" class="has-text-weight-bold">
                        ({{translations.shared.default}})
                    </span>
                </b-table-column>
                <b-table-column field="expected_response_time" :label="translations.shared.fields.expected_response_time">
                    {{ props.row.expected_response_time }}
                </b-table-column>
                <b-table-column field="expected_resolution_time" :label="translations.shared.fields.expected_resolution_time">
                    {{ props.row.expected_resolution_time }}
                </b-table-column>
                <b-table-column field="created_at" :label="translations.shared.fields.created_at">
                    {{ date.toLocalFormat(props.row.created_at, true) }}
                </b-table-column>
                <b-table-column field="updated_at" :label="translations.shared.fields.updated_at">
                    {{ date.toLocalFormat(props.row.updated_at, true) }}
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
