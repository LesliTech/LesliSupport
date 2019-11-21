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
import componentChart from '../components/chart.vue'
import componentStateName from '../../components/ticket_state_name.vue'

export default {
    components: {
        'component-chart': componentChart,
        'component-state-name': componentStateName
    },
    data() {
        return {
            rerender_chart: false,
            default_states:{
                created: 1,
                closed: 2
            },
            translations: {
                shared: I18n.t('cloud_help.ticket_workflows.shared'),
                edit: I18n.t('cloud_help.ticket_workflows.edit')
            },
            ticket_workflow: {},
            ticket_workflow_id: null,
            ticket_states: [],
            selected_state: null,
            selected_follow_up_state: null,
            selected_node: {}
        }
    },
    mounted() {
        // · SetTicketWorkflowId calls getTicketWorkflow
        this.setTicketWorkflowId()
        this.getTicketStates()
    },
    methods: {
        
        setTicketWorkflowId(){
            if (this.$route.params.id) {
                this.ticket_workflow_id = this.$route.params.id
                this.getTicketWorkflow()
            }
        },

        getTicketWorkflow() {
            this.http.get(`/help/ticket_workflows/${this.ticket_workflow_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket_workflow = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getTicketStates(){
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

        addStateToWorkflow(){
            if(this.selected_state){
                let state = this.ticket_states.filter(element => element.id === this.selected_state)[0]
                let new_node = {
                    next_states: `${this.default_states.closed}`,
                    visited: false,
                    ticket_state_id: state.id,
                    ticket_state_name: state.name
                }
                this.ticket_workflow[this.default_states.created].next_states+=`|${state.id}`
                this.$set(this.ticket_workflow, state.id, new_node)
            }
        },

        deleteStateFromWorkflow(deleted_node){
            let id = deleted_node.ticket_state_id
            this.$delete(this.ticket_workflow,id)
            for(let node_id in this.ticket_workflow){
                let node = this.ticket_workflow[node_id]
                if(node.next_states){
                    node.next_states = node.next_states.replace(
                        new RegExp(`([^0-9]${id}$)|(^${id}[^0-9])|(^${id}$)`,'g'), ''
                    ).replace(
                        new RegExp(`([^0-9]${id}[^0-9])`,'g'), '|'
                    )
                    if(node.next_states.length == 0){
                        node.next_states = null
                    }
                }
            }
        },

        addFollowUpState(){
            if(this.selected_follow_up_state){
                if(this.selected_node.next_states){
                    this.selected_node.next_states += `|${this.selected_follow_up_state}`
                }else{
                    this.selected_node.next_states = `${this.selected_follow_up_state}`
                }
                this.rerender_chart = true
            }
        },
        
        selectNode(node){
            this.selected_node = node
        },

        deleteFollowingState(node){
            let id = node.ticket_state_id
            this.selected_node.next_states = this.selected_node.next_states.replace(
                new RegExp(`([^0-9]${id}$)|(^${id}[^0-9])|(^${id}$)`,'g'), ''
            ).replace(
                new RegExp(`([^0-9]${id}[^0-9])`,'g'), '|'
            )
            this.rerender_chart = true
        },

        putTicketWorkflow(event){
            event.preventDefault()
            let data = { ticket_workflow: Object.values(this.ticket_workflow) }
            this.http.put(`/help/ticket_workflows/${this.ticket_workflow_id}`, data).then(result => {
                if (result.successful) {
                    this.alert(this.translations.edit.messages.update.successful)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }
    },
    computed: {
        ticketStates(){
            return this.ticket_states.filter((element)=>{
                return !this.ticket_workflow[element.id]
            })
        },
        
        nextStatesOfSelectedNode(){
            let next_states = []
            if(this.selected_node.next_states){
                let next_states_ids = this.selected_node.next_states.split('|')
                next_states_ids.forEach((id)=>{
                    next_states.push(this.ticket_workflow[id])
                })
            }
            return next_states
        },

        possibleFollowUpStates(){
            if(
                ! this.selected_node.ticket_state_id || 
                this.selected_node.ticket_state_id == this.default_states.closed
            ){
                return []
            }
            let follow_up_states  = this.selected_node.next_states.split('|').map((element)=>{
                return parseInt(element)
            })
            return this.ticket_states.filter(element => {
                return ! (
                    follow_up_states.includes(element.id) ||
                    element.id == this.default_states.created
                ) && (
                    this.ticket_workflow[element.id]
                )
            })
        }
    }
}
</script>
<template>
    <section>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    {{ translations.shared.name }}
                </h2>
                <div class="card-header-icon">
                    <router-link :to="`/${ticket_workflow_id}`">
                        <i class="fas fa-eye"></i>
                        {{ translations.shared.actions.show }}
                    </router-link>
                    <router-link :to="`/`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        {{ translations.shared.actions.return }}
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <div class="columns">
                    <div class="column">
                        <p v-if="Object.keys(ticket_workflow).length > 0">
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.ticket_category_name}:` }}
                            </span>
                            {{ ticket_workflow[1].ticket_category_name }},
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.ticket_type_name}:` }}
                            </span>
                            {{ ticket_workflow[1].ticket_type_name }}
                        </p>
                    </div>
                </div>
                <component-chart :workflow="ticket_workflow" :rerender.sync="rerender_chart">
                </component-chart>
                <hr>
                <form @submit="putTicketWorkflow">
                    <div class="columns">
                        <div class="column">
                            <div class="columns">
                                <div class="column is-four-fifths">
                                    <b-field>
                                        <b-select placeholder="Add a state to the workflow" expanded v-model="selected_state">
                                            <option
                                                v-for="ticket_state in ticketStates"
                                                :value="ticket_state.id"
                                                :key="ticket_state.id">
                                                {{ ticket_state.name }}
                                            </option>
                                        </b-select>
                                    </b-field>
                                </div>
                                <div class="column is-one-fifths">
                                    <b-field class="has-text-right">
                                        <b-button type="is-success" expanded @click="addStateToWorkflow">
                                            Add State
                                        </b-button>
                                    </b-field>
                                </div>
                            </div>
                        </div>
                        <div class="column">
                            <div class="columns">
                                <div class="column is-four-fifths">
                                    <b-field>
                                        <b-select placeholder="Add a follow up state" expanded v-model="selected_follow_up_state">
                                            <option
                                                v-for="ticket_state in possibleFollowUpStates"
                                                :value="ticket_state.id"
                                                :key="ticket_state.id">
                                                    <component-state-name 
                                                        :name="ticket_state.name"
                                                        :initial="ticket_state.initial"
                                                        :final="ticket_state.final"
                                                    >
                                                    </component-state-name>
                                            </option>
                                        </b-select>
                                    </b-field>
                                </div>
                                <div class="column is-one-fifths">
                                    <b-field class="has-text-right">
                                        <b-button type="is-success" expanded @click="addFollowUpState">
                                            Add Follow Up
                                        </b-button>
                                    </b-field>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="columns">
                        <div class="column">
                            Current State:
                            <div class="list is-hoverable">
                                <a 
                                    v-for="(node, key) in ticket_workflow"
                                    :key="key"
                                    class="list-item"
                                    @click="selectNode(node)"
                                    :class="{'is-active':selected_node.ticket_state_id == node.ticket_state_id}"
                                >
                                    <component-state-name :name="node.ticket_state_name" :initial="node.initial" :final="node.final">
                                    </component-state-name>
                                    <button 
                                        v-if="node.ticket_state_id != default_states.created && node.ticket_state_id != default_states.closed"
                                        type="button"
                                        class="delete is-pulled-right"
                                        @click="deleteStateFromWorkflow(node)"
                                    ></button>
                                </a>
                            </div>
                        </div>
                        <div class="column">
                            Follow up States:
                            <div class="list is-hoverable">
                                <a v-for="(node, key) in nextStatesOfSelectedNode" :key="key" class="list-item">
                                    <component-state-name :name="node.ticket_state_name" :initial="node.initial" :final="node.final">
                                    </component-state-name>
                                    <button type="button" class="delete is-pulled-right" @click="deleteFollowingState(node)"></button>
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="columns">
                        <div class="column">
                            <div class="field">
                                <div class="actions has-text-right">
                                    <button class="button is-primary" type="submit">
                                        <span>{{translations.edit.actions.update}}</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</template>
