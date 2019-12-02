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



// · Import modules, components and apps
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentTicketStateName from "../../components/ticket_state_name.vue"

export default {
    components: {
        'component-ticket-state-name': componentTicketStateName
    },
    data() {
        return {
            ticket_id: null,
            ticket_timelines: [],
            translations: I18n.t('cloud_help.tickets.timeline')
        }
    },
    mounted(){
        if (this.$route.params.id) {
            this.ticket_id = this.$route.params.id
            this.getTicketTimeline()
        }
    },
    methods: {
        getTicketTimeline(){
            this.http.get(`/help/api/tickets/${this.ticket_id}/timelines`).then(result => {
                if (result.successful) {
                    this.ticket_timelines = result.data
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        isTransfer(action){
            return action == 'category_transferred' || action == 'type_transferred'
        },

        isEscalate(action){
            return action == 'priority_increased'
        },

        isDescalate(action){
            return action == 'priority_decreased'
        },

        isCoreState(action){
            return action == 'created' || action == 'closed'
        },

        tooltipType(action){
            if(this.isTransfer(action)){
                return 'is-warning'
            }
            if(this.isEscalate(action)){
                return 'is-danger'
            }
            if(this.isDescalate(action)){
                return 'is-success'
            }
            if(this.isCoreState(action)){
                return 'is-info'
            }
            return 'is-light'
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <h4 class="card-header-title">
                {{translations.title}}
            </h4>
        </div>
        <div class="card-content timeline">
            <div class="columns is-multiline">
                <div v-for="(timeline) in ticket_timelines" :key="timeline.id" class="column is-12">
                    <span>
                        <span
                            class="has-text-weight-bold"
                            :class="{
                                'has-text-warning': isTransfer(timeline.action),
                                'has-text-danger': isEscalate(timeline.action),
                                'has-text-success': isDescalate(timeline.action),
                                'has-text-info': isCoreState(timeline.action)
                            }"
                        >
                            {{translations.actions[timeline.action]}}
                        </span>: {{timeline.description}}
                    </span>
                    <br>
                    <small class="is-pulled-right">
                        {{date.toLocalFormat(timeline.created_at, false, true)}}
                    </small>
                    <hr>
                </div>
            </div>
        </div>
    </div>
</template>
<style scoped>
.timeline {
    max-height: 26rem;
    overflow-y: scroll;
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
