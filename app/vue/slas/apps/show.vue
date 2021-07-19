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


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentSubscription from 'LesliCoreVue/cloud_objects/subscription.vue'
import componentDiscussion from 'LesliCoreVue/cloud_objects/discussion-simple.vue'
import componentAction from 'LesliCoreVue/cloud_objects/action.vue'
import componentFile from 'LesliCoreVue/cloud_objects/file.vue'

import componentActivities from '../components/activities.vue'
import componentData from '../components/data.vue'





// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-subscription': componentSubscription,
        'component-discussion': componentDiscussion,
        'component-activities': componentActivities,
        'component-action': componentAction,
        'component-file': componentFile,
        'component-data': componentData
    },
    data() {
        return {
            translations: {
                main: I18n.t('help.slas'),
                core: I18n.t('core.shared'),
                shared: I18n.t('help.shared'),
                workflow_statuses: I18n.t('help.workflow/statuses')
            },
            sla_id: null,
            sla: null,
            new_sla_status: null,
            active_tab: 0
        }
    },
    mounted() {
        this.sla_id = this.$route.params.id
        this.getSla()
        this.setSubscriptions()
    },
    methods: {

        setSubscriptions(){
            this.bus.subscribe('update:/help/sla/workflow', (status)=>{
                this.sla.cloud_help_sla_workflow_statuses_id = status.id
                this.sla.status = status.name
                this.sla.status_initial = status.initial
                this.sla.status_final = status.final
                this.sla.status_name = status.name
                this.sla.status_number = status.number
            })
        },

        // We publish the sla so the form can use it
        getSla() {
            this.http.get(`/help/slas/${this.sla_id}.json`).then(result => {
                if (result.successful) {
                    this.sla = this.parseBackendData(result.data)
                    this.data.slas.sla = this.sla
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        parseBackendData(sla){
            if(sla.deadline){
                sla.deadline = new Date(sla.deadline)
            }

            if(sla.tags && sla.tags.trim().length > 0){
                sla.tags = sla.tags.split(',')
            }else{
                sla.tags = []
            }

            if(sla.description){
                sla.description = JSON.parse(sla.description)
            }else{
                sla.description = {}
            }

            return sla
        }
    },

    computed: {
        activeFilesTab(){
            return this.active_tab == 2
        },

        activeDiscussionsTab(){
            return this.active_tab == 1
        },

        activeActivitiesTab(){
            return this.active_tab == 3
        }
    }
}
</script>
<template>
    <section v-if="sla" class="application-component">
        <component-header :title="sla.name">
            <div class="navbar-item">
                <div class="buttons">
                    <router-link class="button" to="/">
                        <b-icon icon="list" size="is-small" />
                        <span>{{ translations.core.view_btn_list }}</span>
                    </router-link>
                    <router-link class="button" :to="`/${sla_id}/edit`">
                        <b-icon icon="edit" size="is-small" />
                        <span>{{ translations.core.view_btn_edit }}</span>
                    </router-link>
                </div>
            </div>
        </component-header>
        <b-tabs vertical v-model="active_tab">
            <b-tab-item :label="translations.shared.view_tab_title_general_information">
                <component-data v-if="data.slas.sla"></component-data>
            </b-tab-item>

            <b-tab-item :label="translations.core.view_btn_discussions">
                <div class="card">
                    <div class="card-header">
                        <div class="card-header-title is-shadowless">
                            <h4 class=" title is-4">
                                {{translations.core.view_text_discussions}}
                            </h4>
                        </div>
                    </div>
                    <div class="card-content">
                        <component-discussion cloud-module="help/sla" :cloud-id="sla_id" :active="activeDiscussionsTab"></component-discussion>
                    </div>
                </div>
            </b-tab-item>

            <b-tab-item :label="translations.core.view_btn_files">
                <component-file translations-file-types-path="help.sla/files" cloud-module="help/sla" :cloud-id="sla_id" :active="activeFilesTab">
                </component-file>
            </b-tab-item>

            <b-tab-item :label="translations.core.view_btn_activities">
                <component-activities :sla-id="sla_id" :active="activeActivitiesTab"></component-activities>
            </b-tab-item>
        </b-tabs>
    </section>
</template>
