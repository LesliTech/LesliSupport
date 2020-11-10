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
export default {
    data() {
        return {
            ticket_id: null,
            ticket_timelines: [],
            translations:{
                main: I18n.t('help.ticket/timelines'),
                core: I18n.t('core.shared'),
                shared: I18n.t('help.shared')
            },
            loading: false,
            filters: {
                action: null
            },
            options: {
                actions: []
            }
        }
    },

    mounted(){
        if (this.$route.params.id) {
            this.ticket_id = this.$route.params.id
            this.getTicketTimelines()
        }
        this.getTicketTimelinesOptions()
        this.setSubscriptions()
    },

    methods: {

        setSubscriptions(){
            this.bus.subscribe('patch:/help/ticket/assignment', ()=>{
                this.getTicketTimelines()
            })
            this.bus.subscribe('post:/help/ticket/assignment', ()=>{
                this.getTicketTimelines()
            })
            this.bus.subscribe('patch:/help/ticket/deadline', ()=>{
                this.getTicketTimelines()
            })
        },

        getTicketTimelines(){
            this.loading = true;
            this.http.get(`/help/tickets/${this.ticket_id}/timelines`).then(result => {
                this.loading = false;
                if (result.successful) {
                    this.ticket_timelines = result.data
                    this.data.timelines = this.ticket_timelines
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getTicketTimelinesOptions(){
            this.http.get(`/help/tickets/${this.ticket_id}/timelines/options`).then(result => {
                if (result.successful) {
                    result.data.actions = [{
                        value: null,
                        text: this.translations.main.view_placeholder_all_actions
                    }].concat(result.data.actions)
                    this.options = result.data
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        isFieldChange(action){
            return action == 'category_transferred' || action == 'type_transferred' || action == 'priority_changed'
        },

        isFinalStatus(action){
            return action == 'closed'
        },

        isNormalStatus(action){
            return action == 'created' || action == 'status_changed'
        },

        isDeadlineChange(action){
            return action == 'deadline_established'
        },

        clearSearch(event){
            if(event){
                event.preventDefault()
            }
            
            this.filters.search = ''
        }
    },

    computed: {
        filteredTimelines(){
            if(this.filters.action){
                return this.ticket_timelines.filter((timeline)=>{
                    return timeline.action == this.filters.action
                })
            }else{
                return this.ticket_timelines
            }
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <div class="card-header-title is-shadowless">
                <h4 class=" title is-4">
                {{translations.main.view_title_main}}
                </h4>
            </div>
        </div>
        <br>
        <div class="card-content">
            
            <div class="columns">
                <div class="column is-7">
                    <b-field>
                        <b-select expanded v-model="filters.action">
                            <option v-for="action in options.actions" :key="action.value" :value="action.value">
                                {{object_utils.translateEnum(translations.main, 'column_enum_action', action.text)}}
                            </option>
                        </b-select>
                    </b-field>
                </div>
                <div class="column is-5 has-text-right">
                    <b-button @click="getTicketTimelines" :disabled="loading">
                        <i :class="['fas', 'fa-sync', {'fa-spin': loading}]"></i>
                        {{translations.core.view_text_btn_reload}}
                    </b-button>
                </div>
            </div>
            <div v-if="!loading && ticket_timelines.length > 0" class="timeline">
                <div class="columns is-multiline">
                    <div v-for="(timeline, index) in filteredTimelines" :key="index" class="column is-12">
                        <span>
                            <span
                                class="has-text-weight-bold"
                                :class="{
                                    'has-text-warning': isFieldChange(timeline.action),
                                    'has-text-danger': isDeadlineChange(timeline.action),
                                    'has-text-success': isFinalStatus(timeline.action),
                                    'has-text-info': isNormalStatus(timeline.action)
                                }"
                            >
                                &nbsp;&nbsp; {{object_utils.translateEnum(translations.main, 'column_enum_action', timeline.action)}}
                            </span>
                            <span v-if="timeline.description">:</span> {{timeline.description}}
                        </span>
                        <small class="is-pulled-right">
                            {{timeline.created_at}} &nbsp;&nbsp;
                        </small>
                        <hr>
                    </div>
                </div>
            </div>
            <component-data-loading v-else></component-data-loading>
        </div>
    </div>
</template>
<style scoped>
.timeline {
    max-height: 25rem;
    overflow-y: auto;
    overflow-x: hidden;
    scrollbar-width: thin;
    scrollbar-color: #AAAAAA #ffffff;
}
hr {
    margin: 0.5rem 0;
}
</style>
