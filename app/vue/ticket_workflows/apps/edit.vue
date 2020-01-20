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
import componentWorkflowStateName from "LesliCloud/vue/cloud_object/workflow_states/components/state-name.vue"
import componentWorkflowChart from '../../components/workflow_chart.vue'

export default {
    components: {
        'component-workflow-chart': componentWorkflowChart,
        'component-workflow-state-name': componentWorkflowStateName
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
            ticket_workflow: null,
            ticket_workflow_id: null,
            ticket_states: [],
            slas: [],
            selected_state: null,
            selected_follow_up_state: null,
            selected_node: {}
        }
    },
    mounted() {
        // · SetTicketWorkflowId calls getTicketWorkflow
        this.setTicketWorkflowId()
        this.getTicketStates()
        this.getSlas()
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

        getSlas(){
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

        addStateToWorkflow(){
            if(this.selected_state){
                let state = this.ticket_states.filter(element => element.id === this.selected_state)[0]
                let new_node = {
                    next_states: this.default_states.closed.toString(),
                    visited: false,
                    ticket_state_id: state.id,
                    ticket_state_name: state.name
                }
                this.ticket_workflow.details[this.default_states.created].next_states+=`|${state.id}`
                this.$set(this.ticket_workflow.details, state.id, new_node)
                this.selected_state = null
            }
        },

        // · Checks if this is the only follow up state of the initial state
        // · node = state from which a follow up will be removed. If the user wants to remove from the workflow, this will be the initial state
        // · state_id = the id of the state the user wants to remove
        isRemovable(node, state_id){
            if(node.ticket_state_id == this.default_states.created){
                let initial_node = this.ticket_workflow.details[this.default_states.created]
                return initial_node.next_states != state_id
            }
            return true
        },

        deleteStateFromWorkflow(deleted_node){
            let id = deleted_node.ticket_state_id
            if(this.isRemovable(this.ticket_workflow.details[this.default_states.created], id)){
                this.$delete(this.ticket_workflow.details,id)
                for(let node_id in this.ticket_workflow.details){
                    let node = this.ticket_workflow.details[node_id]
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
            }else{
                this.alert(this.translations.edit.errors.unable_to_remove_state,'danger')
            }
        },

        addFollowUpState(){
            if(this.selected_follow_up_state){
                if(this.selected_node.next_states){
                    this.selected_node.next_states += `|${this.selected_follow_up_state}`
                }else{
                    this.selected_node.next_states = `${this.selected_follow_up_state}`
                }
                this.selected_follow_up_state = null
                this.rerender_chart = true
            }
        },
        
        selectNode(node){
            this.selected_node = node
        },

        deleteFollowUpState(node){
            let id = node.ticket_state_id
            if(this.isRemovable(this.selected_node, id)){
                this.selected_node.next_states = this.selected_node.next_states.replace(
                    new RegExp(`([^0-9]${id}$)|(^${id}[^0-9])|(^${id}$)`,'g'), ''
                ).replace(
                    new RegExp(`([^0-9]${id}[^0-9])`,'g'), '|'
                )
                this.rerender_chart = true
            }else{
                this.alert(this.translations.edit.errors.unable_to_remove_state,'danger')
            }
        },

        putTicketWorkflow(event){
            event.preventDefault()
            let data = {
                ticket_workflow: {
                    cloud_help_slas_id: this.ticket_workflow.cloud_help_slas_id,
                    details_attributes: Object.values(this.ticket_workflow.details)
                }
            }
            this.http.put(`/help/ticket_workflows/${this.ticket_workflow_id}`, data).then(result => {
                if (result.successful) {
                    this.alert(this.translations.edit.messages.update.successful)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        propagateSLA(workflow, sla_id){
            workflow.forEach((workflow_node)=>{
                workflow_node.cloud_help_slas_id = sla_id
            })
            return workflow
        }
    },
    computed: {
        ticketStates(){
            return [
                {id: null, name: this.translations.edit.labels.add_to_workflow}
            ].concat(this.ticket_states.filter((element)=>{
                return !this.ticket_workflow.details[element.id]
            }))
        },
        
        nextStatesOfSelectedNode(){
            let next_states = []
            if(this.selected_node.next_states){
                let next_states_ids = this.selected_node.next_states.split('|')
                next_states_ids.forEach((id)=>{
                    next_states.push(this.ticket_workflow.details[id])
                })
            }
            return next_states
        },

        possibleFollowUpStates(){
            let label = [{id: null, name: this.translations.edit.labels.add_follow_ups}]
            if(
                ! this.selected_node.ticket_state_id || 
                this.selected_node.ticket_state_id == this.default_states.closed
            ){
                return label
            }
            let follow_up_states  = this.selected_node.next_states.split('|').map((element)=>{
                return parseInt(element)
            })
            return label.concat(this.ticket_states.filter(element => {
                return ! (
                    follow_up_states.includes(element.id) ||
                    element.id == this.default_states.created
                ) && (
                    this.ticket_workflow.details[element.id]
                )
            }))
        }
    }
}
</script>
<template>
    <section v-if="ticket_workflow">
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
                        <p>
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.ticket_category_name}:` }}
                            </span>
                            {{ ticket_workflow.ticket_category_name }},
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.ticket_type_name}:` }}
                            </span>
                            {{ ticket_workflow.ticket_type_name }}
                        </p>
                    </div>
                </div>
                <form @submit="putTicketWorkflow">
                    <div class="columns">
                        <div class="column">
                            <b-field :label="translations.shared.fields.sla_name">
                                <b-select expanded v-model="ticket_workflow.cloud_help_slas_id">
                                    <option
                                        v-for="sla in slas"
                                        :value="sla.id"
                                        :key="sla.id"
                                    >
                                        {{ sla.name }}
                                    </option>
                                </b-select>
                            </b-field>
                        </div>
                    </div>
                    <div class="columns">
                        <div class="column">
                            <label class="label">{{translations.edit.titles.add_state}}</label>
                            <div class="columns">
                                <div class="column is-four-fifths">
                                    <b-field>
                                        <b-select expanded v-model="selected_state">
                                            <option
                                                v-for="ticket_state in ticketStates"
                                                :value="ticket_state.id"
                                                :key="ticket_state.id"
                                                :hidden="ticket_state.id == null"
                                                :disbled="ticket_state.id == null"
                                            >
                                                {{ ticket_state.name }}
                                            </option>
                                        </b-select>
                                    </b-field>
                                </div>
                                <div class="column is-one-fifths">
                                    <b-field class="has-text-right">
                                        <b-button type="is-success" expanded @click="addStateToWorkflow">
                                            {{translations.edit.actions.add_state}}
                                        </b-button>
                                    </b-field>
                                </div>
                            </div>
                        </div>
                        <div class="column">
                            <label class="label">{{translations.edit.titles.add_follow_up}}</label>
                            <div class="columns">
                                <div class="column is-four-fifths">
                                    <b-field>
                                        <b-select expanded v-model="selected_follow_up_state">
                                            <option
                                                v-for="ticket_state in possibleFollowUpStates"
                                                :value="ticket_state.id"
                                                :key="ticket_state.id"
                                                :hidden="ticket_state.id == null"
                                                :disbled="ticket_state.id == null"  
                                            >
                                                <component-workflow-state-name
                                                    :translations-shared-path="'cloud_help.ticket_states.shared'"
                                                    :name="ticket_state.name"
                                                    :initial="ticket_state.initial"
                                                    :final="ticket_state.final"
                                                >
                                                </component-workflow-state-name>
                                            </option>
                                        </b-select>
                                    </b-field>
                                </div>
                                <div class="column is-one-fifths">
                                    <b-field class="has-text-right">
                                        <b-button type="is-success" expanded @click="addFollowUpState">
                                            {{translations.edit.actions.add_follow_up}}
                                        </b-button>
                                    </b-field>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="columns">
                        <div class="column">
                            {{translations.edit.titles.current_state}}:
                            <div class="list is-hoverable">
                                <a 
                                    v-for="(node, key) in ticket_workflow.details"
                                    :key="key"
                                    class="list-item"
                                    @click="selectNode(node)"
                                    :class="{'is-active':selected_node.ticket_state_id == node.ticket_state_id}"
                                >
                                    <component-workflow-state-name
                                        :name="node.ticket_state_name"
                                        :translations-shared-path="'cloud_help.ticket_states.shared'"
                                    />
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
                            {{translations.edit.titles.follow_up}}:
                            <div class="list is-hoverable">
                                <a v-for="(node, key) in nextStatesOfSelectedNode" :key="key" class="list-item">
                                    <component-workflow-state-name
                                        :name="node.ticket_state_name"
                                        :translations-shared-path="'cloud_help.ticket_states.shared'"
                                    />
                                    <button type="button" class="delete is-pulled-right" @click="deleteFollowUpState(node)"></button>
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
                <hr>
                <component-workflow-chart :workflow="ticket_workflow.details" :rerender.sync="rerender_chart">
                </component-workflow-chart>
            </div>
        </div>
    </section>
</template>
