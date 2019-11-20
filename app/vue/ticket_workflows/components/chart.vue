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
        }
    },
    data(){
        return {
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
            this.workflowRecursion(initial_node)
            this.workflow_graph = `${this.workflow_graph};`
            this.$nextTick(()=>{
                mermaid.init()
            })
        },

        workflowRecursion(node){
            if(node.next_states){
                if(node.visited){
                    return
                }
                node.visited = true

                let current_name = node.ticket_state_name
                let current_icon = this.getIcon(node)
                let next_node_ids = node.next_states.split('|').map((element)=>{
                    return parseInt(element)
                })

                next_node_ids.forEach((next_node_id)=>{
                    let next_node = this.workflow[next_node_id]
                    let next_name = next_node.ticket_state_name
                    let next_icon = this.getIcon(next_node)

                    this.workflow_graph+=`\n\t${node.ticket_state_id}[${current_icon} ${current_name}]-->${next_node.ticket_state_id}[${next_icon} ${next_name}]`
                    this.workflowRecursion(next_node)
                })
            }
        }
    },
    watch: {
        workflow(){
            if(Object.keys(this.workflow).length > 0){
                this.generateWorkflow()
            }
        }
    }
}
</script>
<template>
    <div class="mermaid" v-html="workflow_graph">
    </div>
</template>
