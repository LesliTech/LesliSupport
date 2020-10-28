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
        }
    },

    mounted(){
        if (this.$route.params.id) {
            this.ticket_id = this.$route.params.id
            this.getTicketTimeline()
        }
        this.setSubscriptions()
    },

    methods: {

        setSubscriptions(){
            this.bus.subscribe('patch:/help/ticket/assignment', ()=>{
                this.getTicketTimeline()
            })
            this.bus.subscribe('post:/help/ticket/assignment', ()=>{
                this.getTicketTimeline()
            })
            this.bus.subscribe('patch:/help/ticket/deadline', ()=>{
                this.getTicketTimeline()
            })
        },

        getTicketTimeline(){
            this.http.get(`/help/tickets/${this.ticket_id}/timelines`).then(result => {
                if (result.successful) {
                    this.ticket_timelines = result.data
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
        <div class="card-content timeline">
            <div class="columns is-multiline">
                <div v-for="(timeline) in ticket_timelines" :key="timeline.id" class="column is-paddingless is-12">
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
    </div>
</template>
<style scoped>
.timeline {
    max-height: 35rem;
    overflow-y: auto;
    overflow-x: hidden;
}

.line {
    height: 0.2rem;
    width: 4rem;
    vertical-align: middle;
    padding-left: 0.1rem;
    padding-right:0.1rem;
    display: inline-block;
}
</style>
