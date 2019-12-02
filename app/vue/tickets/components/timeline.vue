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
            <div class="columns">
                <div class="column is-3">
                    Legend goes here
                </div>
                <div class="column is-9">
                    <span v-for="(timeline, i) in ticket_timelines" :key="timeline.id">
                        <span v-if="i != 0" class="line has-background-black" />
                        <b-tooltip 
                            :label="timeline.description"
                            position="is-bottom"
                            multilined
                            :type="tooltipType(timeline.action)"
                        >
                            <span 
                                class="button is-rounded has-text-centered"
                                :class="{
                                    'is-warning': isTransfer(timeline.action),
                                    'is-danger': isEscalate(timeline.action),
                                    'is-success': isDescalate(timeline.action),
                                    'is-info': isCoreState(timeline.action)
                                }"
                            >
                                {{translations.actions[timeline.action]}}






<div class="tile">
  <div class="tile is-8 is-parent is-vertical">
    <div class="tile is-child notification is-primary">
      Hello
    </div>
    <div class="tile is-child notification is-warning">
      World
    </div>
  </div>
  <div class="tile is-parent">
    <div class="tile is-child notification is-info">
      Helo!
    </div>
  </div>
</div>












                            </span>
                            &nbsp;
                        </b-tooltip>
                    </span>
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
