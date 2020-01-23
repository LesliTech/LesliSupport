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
import componentWorkflowAssignments from 'LesliCloud/vue/cloud_object/workflows/components/assignments.vue'
import componentTreeList from '../components/tree_list.vue'


export default {
    components: {
        'component-tree-list': componentTreeList,
        'component-workflow-assignments': componentWorkflowAssignments
    },

    data() {
        return {
            translations: {
                show: I18n.t('cloud_help.ticket_categories.show'),
                shared: I18n.t('cloud_help.ticket_categories.shared')
            },
            ticket_category: {},
            ticket_path: [],
            ticket_category_id: null,
            modal:{
                active: false
            }
        }
    },

    mounted() {
        // · SetTicketCategoryId calls getTicketCategory
        this.setTicketCategoryId()
    },
    
    methods: {
        
        setTicketCategoryId(){
            if (this.$route.params.id) {
                this.ticket_category_id = this.$route.params.id
                this.getTicketCategory()
            }
        },

        getTicketCategory() {
            this.http.get(`/help/ticket_categories/${this.ticket_category_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket_category = result.data
                    this.getTicketCategoryTree()
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        getTicketCategoryTree(){
            this.http.get(`/help/api/ticket_categories/${this.ticket_category_id}/tree`).then(result => {
                if (result.successful) {
                    this.ticket_path = result.data;
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        deleteTicketCategory(){
            this.modal.active = false
            this.http.delete(`/help/ticket_categories/${this.ticket_category_id}`).then(result => {
                if(result.successful){
                    this.alert(this.translations.show.messages.delete.successful,'success')
                    this.$router.push('/')
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        emitShowWorkflowAssignments(){
            this.bus.publish('show:/module/app/workflow-assignments')
        }
    }
}
</script>
<template>
    <section>
        <b-modal 
            :active.sync="modal.active"
            has-modal-card
            trap-focus
            aria-role="dialog"
            aria-modal
        >
            <div class="card">
                <div class="card-header is-danger">
                    <h2 class="card-header-title">
                        {{ translations.show.modal.title }}
                    </h2>
                </div>
                <div class="card-content">
                    {{ translations.show.modal.body }}
                </div>
                <div class="card-footer has-text-right">
                    <button class="card-footer-item button is-danger" @click="deleteTicketCategory">
                        {{ translations.show.modal.actions.delete }}
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modal.active=false">
                        {{ translations.show.modal.actions.cancel }}
                    </button>
                </div>
            </div>
        </b-modal>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    {{ translations.shared.name }}
                </h2>
                <div class="card-header-icon">
                    <a tabindex="0" role="button" @click="emitShowWorkflowAssignments">
                        <i class="fas fa-project-diagram"></i>
                        {{ translations.shared.actions.assign_workflow }}
                    </a>
                    <router-link :to="`/${ticket_category_id}/edit`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-edit"></i>
                        {{ translations.shared.actions.edit }}
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
                                {{ `${translations.shared.fields.name}:` }}
                            </span>
                            {{ ticket_category.name }}
                            <br>
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.path}:` }}
                            </span>
                            <component-tree-list :trees="ticket_path" :scrollable="true">
                            </component-tree-list>
                        </p>
                    </div>
                </div>
                <div class="columns">
                    <div class="column">
                        <small>
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.created_at}:` }}
                            </span>
                            {{ date.toLocalFormat(ticket_category.created_at, false, true) }}
                            <br>
                            <span class="has-text-weight-bold">
                                {{ `${translations.shared.fields.updated_at}:` }}
                            </span>
                            {{ date.toLocalFormat(ticket_category.updated_at, false, true) }}
                        </small>
                    </div>
                    <div class="column">
                        <div class="field">
                            <div class="actions has-text-right">
                                <button class="button is-danger" @click="modal.active = true">
                                    {{ translations.shared.actions.delete }}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <component-workflow-assignments
            :cloud-module="'help'"
            :cloud-object="'ticket'"
            :cloud-workflow-key-name="'category'"
        />
    </section>
</template>
<style scoped>
section.scrollable {
    height: 23rem;
    overflow-y: scroll;
}
.margin-left {
    margin-left: 2rem;
}
.l-shape {
    border-left: 2px solid black;
    border-bottom: 2px solid black;
    margin-bottom: 1px;
}
</style>
