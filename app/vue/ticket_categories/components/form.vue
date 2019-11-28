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
    components: {
        'tree-list': treeList
    },

    data() {
        return {
            translations: {
                form: I18n.t('cloud_help.ticket_categories.form'),
                shared: I18n.t('cloud_help.ticket_categories.shared'),
            },
            ticket_category_id: null,
            ticket_category: {
                parent_id: null
            },
            ticket_categories: []
        }
    },
    mounted() {
        this.setTicketCategoryId()
        this.getTicketCategories()
    },
    methods: {

        getTicketCategories() {
            this.http.get("/help/ticket_categories.json").then(result => {
                if (result.successful) {
                    this.ticket_categories = result.data
                    this.showTicketCategoryPath()
                }else{
                    this.alert(result.error,'danger')
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
            this.http.put(`/help/ticket_categories/${this.ticket_category_id}`, {
                ticket_category: this.ticket_category
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.form.messages.update.successful,'success')
                    this.$router.push(`/${this.ticket_category_id}`)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        postTicketCategory() {
            this.http.post("/help/ticket_categories", {
                ticket_category: this.ticket_category
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.form.messages.create.successful,'success')
                    this.$router.push(`/${result.data.id}`)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        getTicketCategory() {
            this.http.get(`/help/ticket_categories/${this.ticket_category_id}.json`).then(result => {
                if (result.successful) {
                    this.ticket_category = result.data
                }else{
                    this.alert(result.error,'danger')
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
        }
    }
}
</script>
<template>
    <section>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    {{translations.shared.name}}
                </h2>
                <div class="card-header-icon">
                    <router-link v-if="ticket_category_id" :to="`/${ticket_category_id}`">
                        <i class="fas fa-eye"></i>
                        {{translations.shared.actions.show}}
                    </router-link>
                    <router-link :to="`/`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        {{translations.shared.actions.return}}
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <form @submit="submitTicketCategory">
                    <div class="columns">
                        <div class="column">
                            <b-field :label="translations.shared.fields.parent_category">
                                <tree-list :trees="ticket_categories" :scrollable="true" :default_card="true">
                                    <template v-slot:default_content>
                                        {{translations.form.titles.no_subcategory}}
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
                                        <b-radio 
                                            v-model="ticket_category.parent_id"
                                            name="parent_category"
                                            :native-value="node.id"
                                            :disabled="disableChildren(node)"
                                        >
                                        </b-radio>
                                    </template>
                                </tree-list>
                            </b-field>
                        </div>
                        <div class="column">
                            <b-field :label="translations.shared.fields.name">
                                <b-input v-model="ticket_category.name" required="true"></b-input>
                            </b-field>
                        </div>
                    </div>
                    <div class="columns">
                        <div v-if="ticket_category_id" class="column">
                            <div class="field">
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
                        </div>
                        <div class="column">
                            <div class="field">
                                <div class="actions has-text-right">
                                    <button class="button is-primary" type="submit">
                                        <span v-if="ticket_category_id">{{translations.form.actions.update}}</span>
                                        <span v-else>{{translations.form.actions.create}}</span>
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
