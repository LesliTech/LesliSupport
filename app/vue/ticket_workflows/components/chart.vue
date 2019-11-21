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


// · Library List
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
const mermaid = require('mermaid')

export default {
    props: {
        workflow: {
            type: Object,
            default() {
                return {}
            }
        },
        rerender: {
            type: Boolean,
            default: false
        },
        ticket_state_created_id: {
            type:Number,
            default: 1
        },
        ticket_state_closed_id: {
            type: Number,
            default: 2
        }
    },
    data(){
        return {
            translations: I18n.t('cloud_help.ticket_states.shared'),
            workflow_graph: ''
        }
    },
    methods: {
        getIcon(node){
            let icon = 'fas:fa-forward'
            if(node.initial){
                icon = 'fas:fa-play'
            }else if(node.final){
                icon = 'fas:fa-stop'
            }
            return icon
        },

        generateWorkflow(){
            this.workflow_graph = `graph LR `
            // · Initial node will always have key = 1 because is the first entry on the database
            let initial_node = this.workflow[1]
            this.resetWorkflowNodes()
            this.workflowRecursion(initial_node)
            this.workflow_graph = `${this.workflow_graph};`
            document.getElementById('mermaid-chart').removeAttribute('data-processed');
            this.$nextTick(()=>{
                mermaid.init()
            })
        },

        resetWorkflowNodes(){
            for(let key in this.workflow){
                let node = this.workflow[key]
                node.visited = false
            }
        },

        workflowRecursion(node){
            if(node.next_states){
                if(node.visited){
                    return
                }
                node.visited = true
                let current_name = this.getNodeName(node)
                let current_icon = this.getIcon(node)
                let next_node_ids = node.next_states.split('|').map((element)=>{
                    return parseInt(element)
                })

                next_node_ids.forEach((next_node_id)=>{
                    let next_node = this.workflow[next_node_id]
                    let next_name = this.getNodeName(next_node)
                    let next_icon = this.getIcon(next_node)

                    this.workflow_graph+=`\n\t${node.ticket_state_id}[${current_icon} ${current_name}]-->${next_node.ticket_state_id}[${next_icon} ${next_name}]`
                    this.workflowRecursion(next_node)
                })
            }
        },

        getNodeName(node){
            if(node.ticket_state_id == this.ticket_state_created_id){
                return this.translations.default.names.created
            }
            if(node.ticket_state_id == this.ticket_state_closed_id){
                return this.translations.default.names.closed
            }
            return node.ticket_state_name
        }
    },
    watch: {
        workflow(){
            if(Object.keys(this.workflow).length > 0){
                this.generateWorkflow()
            }
        },
        rerender(){
            if(this.rerender){
                this.$emit('update:rerender', false)
                this.generateWorkflow()
            }
        }
    }
}
</script>
<template>
    <div class="mermaid" id="mermaid-chart" v-html="workflow_graph">
    </div>
</template>
