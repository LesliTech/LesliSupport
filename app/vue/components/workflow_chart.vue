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
import Vue from 'vue'
import VueMermaid from 'vue-mermaid'
Vue.use(VueMermaid)

export default {
    props: {
        workflow: {
            type: Object,
            default: ()=>{
                return {}
            }
        },
        selected_node: {
            type: Number,
            default: null
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
            parsed_workflow: []
        }
    },
    mounted(){
        this.generateWorkflow()
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
            if(this.workflow){
                this.$emit('update:rerender', false)
                let data = []
                Object.values(this.workflow).forEach( node => {
                    let parsed_node = {
                        id: node.ticket_state_id,
                        text: `${this.getIcon(node)} ${this.getNodeName(node)}`
                    }
                    if(node.next_states){
                        parsed_node.next = node.next_states.split("|")
                    }
                    if(this.selected_node == node.ticket_state_id){
                        parsed_node.style = 'fill:#EFFD5F,stroke:#FCE205'
                    }
                    data.push(parsed_node)
                })
                this.parsed_workflow = data
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
        selected_node(){
            this.generateWorkflow()
        },

        workflow(){
            this.generateWorkflow()
        },
        
        rerender(){
            if(this.rerender){
                this.generateWorkflow()
            }
        }
    }
}
</script>
<template>
    <vue-mermaid
        :nodes="parsed_workflow"
        type="graph LR"
    >
    </vue-mermaid>
</template>
