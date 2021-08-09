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

// · Component list
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import treeList from '../components/tree_list.vue'

export default {
    props: {
        viewType: {
            type: String,
            default: 'new'
        },

        appMountPath: {
            type: String,
            required: true
        }
    },

    components: {
        'tree-list': treeList
    },

    data() {
        return {
            main_route: '/help/catalog/ticket_categories',
            translations: {
                main: I18n.t('help.catalog/ticket_categories'),
                core: I18n.t('core.shared'),
                shared: I18n.t('help.shared')
            },
            ticket_category_id: null,
            ticket_category: {
                parent_id: null
            },
            submitting: false,
            deleting: false,
            ticket_categories: []
        }
    },
    mounted() {
        this.setTicketCategoryId()
        this.getTicketCategories()
    },
    methods: {

        getTicketCategories() {
            this.http.get("/help/catalog/ticket_categories.json").then(result => {
                if (result.successful) {
                    this.ticket_categories = result.data.ticket_categories
                    this.showTicketCategoryPath()
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        showTicketCategoryPath(){
            if(this.ticket_category.ancestry){
                let path_ids = this.ticket_category.ancestry.split('/').map((item)=>{
                    return parseInt(item)
                })
                let path = this.ticket_categories.filter((element)=>{
                    return path_ids.includes(element.id) || this.ticket_category_id == element.id
                })
                path.map((node)=>{
                    node.active = true
                    if(node.id != this.ticket_category_id){
                        node.children_active = true
                    }
                })
            }
        },

        setTicketCategoryId(){
            if (this.$route.params.id) {
                this.ticket_category_id = this.$route.params.id
                this.getTicketCategory()
            }
        },

        submitTicketCategory(event){
            if (event) { event.preventDefault() }
            if(this.ticket_category_id){
                this.putTicketCategory()
            }else{
                this.postTicketCategory()
            }
        },

        putTicketCategory() {
            let url = `${this.main_route}/${this.ticket_category_id}`
            let data = {
                ticket_category: this.ticket_category
            }

            this.submitting = true
            this.http.put(url, data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.getTicketCategories()
                    this.msg.success(this.translations.main.messages_info_ticket_category_updated)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })

        },

        postTicketCategory() {
            let data = {
                ticket_category: this.ticket_category
            }
            
            this.submitting = true
            this.http.post(this.main_route, data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.msg.success(this.translations.main.messages_info_ticket_category_created,'success')
                    this.$router.push(`${this.appMountPath}/${result.data.id}/edit`)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })

        },

        getTicketCategory() {
            this.http.get(`/help/catalog/ticket_categories/${this.ticket_category_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket_category = result.data.filter(category => category.id == this.ticket_category_id)[0]
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        disableChildren(node){
            if(! this.ticket_category_id){
                return false;
            }
            return (
                node.id == this.ticket_category_id
            ) || (
                node.ancestry && node.ancestry.split('/').includes(this.ticket_category_id)
            )
        },

        // @return [void]
        // @description Connects to the backend using HTTP to delete an existing Ticket category under the current user's
        //      account. The id of the Ticket category is provided in the *id* route param. If the HTTP request fails,
        //      an error message is shown
        // @example
        //      this.deleteTicketCategory() // will delete the record and redirect to the list app
        deleteTicketCategory() {
            let url = `${this.main_route}/${this.ticket_category_id}`
            this.deleting = true

            this.http.delete(url).then(result => {
                this.deleting = false
                if (result.successful) {
                    this.msg.success(this.translations.main.messages_info_ticket_category_destroyed)
                    this.$router.push(`${this.appMountPath}/`)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-content">
            <b-tabs>
                <b-tab-item :label="translations.shared.view_tab_title_general_information">
                    <form @submit="submitTicketCategory">
                        <b-field>
                            <template v-slot:label>
                                {{translations.main.column_name}}
                                <sup class="has-text-danger">*</sup>
                            </template>
                            <b-input v-model="ticket_category.name" required="true"></b-input>
                        </b-field>
                        <hr>
                        <b-field :label="translations.main.view_text_select_parent_category">
                            <tree-list
                                :trees="ticket_categories"
                                :scrollable="true"
                                :default_card="true"
                                :add_links="false"
                                :app-mount-path="appMountPath"
                            >
                                <template v-slot:default_content>
                                    {{translations.main.view_text_no_parent_category}}
                                </template>
                                <template v-slot:default_actions>
                                    <b-radio
                                        v-model="ticket_category.parent_id"
                                        name="parent_category"
                                        checked
                                        :native-value="null"
                                    >
                                    </b-radio>
                                </template>
                                <template v-slot:actions="{node}">
                                    <b-tooltip 
                                        :active="disableChildren(node)"
                                        :label="translations.main.messages_info_cannot_assign_child_as_parent"
                                        position="is-left"
                                        multilined
                                    >
                                        <b-radio 
                                            v-model="ticket_category.parent_id"
                                            name="parent_category"
                                            :native-value="node.id"
                                            :disabled="disableChildren(node)"
                                        >
                                        </b-radio>
                                    </b-tooltip>
                                </template>
                            </tree-list>
                        </b-field>
                        <div class="columns">
                            <div v-if="ticket_category_id" class="column">
                                <div class="field">
                                    <small>
                                        <span class="has-text-weight-bold">
                                            {{ translations.main.column_created_at }}:
                                        </span>
                                        {{ ticket_category.created_at }}
                                        <br>
                                        <span class="has-text-weight-bold">
                                            {{ translations.main.column_updated_at }}:
                                        </span>
                                        {{ ticket_category.updated_at }}
                                    </small>
                                </div>
                            </div>
                            <div class="column has-text-right">
                                <b-field v-if="viewType == 'new' || viewType == 'edit'">
                                    <b-button type="is-primary" native-type="submit" :disabled="submitting">
                                        <span v-if="submitting">
                                            <i class="fas fa-circle-notch fa-spin"></i>
                                            &nbsp; {{translations.core.view_btn_saving}}
                                        </span>
                                        <span v-else>
                                            <i class="fas fa-save"></i>
                                            &nbsp; {{translations.core.view_btn_save}}
                                        </span>
                                    </b-button>
                                </b-field>
                            </div>
                        </div>
                    </form>
                </b-tab-item>
                <b-tab-item :label="translations.shared.view_tab_title_delete_section" v-if="viewType != 'new'">
                    <span class="has-text-danger">
                        {{translations.main.view_text_delete_confirmation}}
                    </span>
                    <br>
                    <br>
                    <!---------------------------------- START DELETE BUTTON ---------------------------------->
                    <b-field v-if="viewType != 'new'">
                        <b-button type="is-danger" @click="deleteTicketCategory" expanded class="submit-button" :disabled="deleting">
                            <span v-if="deleting">
                                <i class="fas fa-spin fa-circle-notch"></i> {{translations.core.view_btn_deleting}}
                            </span>
                            <span v-else>
                                <i class="fas fa-trash-alt"></i> {{translations.core.view_btn_delete}}
                            </span>
                        </b-button>
                    </b-field>
                    <!----------------------------------  END DELETE BUTTON  ---------------------------------->
                </b-tab-item>
            </b-tabs>
        </div>
    </div>
</template>
