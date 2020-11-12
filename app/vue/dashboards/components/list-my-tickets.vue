<script>
/*
Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// ·
*/



// · Import frameworks, libraries and tools
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


// · component
export default {
    props: {
        dashboardId: {
            required: true
        },

        componentId: {
            required: true
        }
    },
    
    data() {
        return {
            data_ready: false,
            new_tickets: {
                data: []
            },
            translations: {
                core: I18n.t('core.shared'),
                main: I18n.t('help.dashboard/components'),
                tickets: I18n.t('help.tickets')
            }
        }
    },
    mounted() {
        this.getComponentData()
    },
    methods: {
        getComponentData() {
            let url =`/help/dashboards/${this.dashboardId}/components/${this.componentId}.json?view_type=render`

            this.http.get(url).then(result => {
                this.new_tickets.data = result.data
                this.data_ready = true
            }).catch(error => {
                console.log(error)
            })
        },

        goToUrl(row){
            this.url.go(row.url)
        }
    }
}
</script>
<template>
    <div class="dashboard-list card">
        <div class="card-content has-text-dark">
            <div v-if="data_ready">
                <p class="is-size-5 has-text-centered">{{ translations.main.view_title_my_tickets }}</p>
                <b-table :data="new_tickets.data" :hoverable="true" :striped="true">
                    <template slot-scope="props">
                        <b-table-column field="subject" :label="translations.tickets.column_subject" sortable>
                            <a :href="props.row.url">{{ props.row.subject }}</a>
                        </b-table-column>
                        <b-table-column field="deadline_raw" :label="translations.tickets.column_deadline" sortable>
                            <a :href="props.row.url">
                                {{ props.row.deadline }}
                                <i v-if="new Date(props.row.deadline_raw) < new Date()" class="fas fa-exclamation-circle has-text-danger"></i>
                            </a>
                        </b-table-column>
                        <b-table-column field="status_name" :label="translations.tickets.column_cloud_help_workflow_statuses_id" sortable>
                            <a :href="props.row.url">{{
                                object_utils.translateEnum(translations.core, 'column_enum_status', props.row.status_name)
                            }}</a>
                        </b-table-column>
                    </template>
                </b-table>
            </div>
            <component-data-loading v-else>
            </component-data-loading>
        </div>
    </div>
</template>
<style>
    .dashboard-list .card-content {
        padding: 1.5rem .2rem;
    }
    .dashboard-list table td{
        font-size: 0.875rem;
        padding: 0.5em;
    }
</style>
