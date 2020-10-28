<script>
/*
Copyright (c) 2020, Lesli Technologies, S. A.

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

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description App that allows the user to create a new Ticket category

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · Component list
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentTreeList from '../components/tree_list.vue'


export default {
    components: {
        'component-tree-list': componentTreeList
    },

    data() {
        return {
            translations: {
                main: I18n.t('help.catalog/ticket_categories'),
                core: I18n.t('core.shared'),
                shared: I18n.t('help.shared')
            },
            ticket_category: {},
            category_tree: [],
            ticket_category_id: null,
            index_abilities: this.abilities.privilege('catalog/ticket_categories', 'cloud_help')
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
        
        getTicketCategory(){
            this.http.get(`/help/catalog/ticket_categories/${this.ticket_category_id}.json`).then(result => {
                if (result.successful) {
                    this.category_tree = result.data
                    this.ticket_category = this.category_tree.filter(category => category.id == this.ticket_category_id)[0]
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <section class="application-component" v-if="ticket_category_id">
        <component-header 
            :title="translations.main.view_title_main"
        >
            <div class="buttons">
                <router-link class="button" tag="button" to="/new" v-if="index_abilities.grant_create">
                    <b-icon icon="plus" size="is-small" />
                    <span>{{ translations.main.view_btn_create }}</span>
                </router-link>
            </div>
        </component-header>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    {{ translations.main.view_title_show }}
                </h2>
                <div class="card-header-icon">
                    <router-link :to="`/${ticket_category_id}/edit`">
                        <i class="fas fa-edit"></i>
                        {{translations.core.view_btn_edit}}
                    </router-link>
                    <router-link to="/">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        {{translations.core.view_btn_return}}
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <div class="columns">
                    <div class="column">
                        <p>
                            <span class="has-text-weight-bold">
                                {{ translations.main.column_name }}:
                            </span>
                            {{ ticket_category.name }}
                            <hr>
                            <span class="has-text-weight-bold">
                                {{ translations.main.view_text_category_path }}:
                            </span>
                            <component-tree-list :trees="category_tree" :scrollable="true">
                            </component-tree-list>
                        </p>
                    </div>
                </div>
                <div class="columns">
                    <div class="column">
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
            </div>
        </div>
    </section>
</template>
<style scoped>
.margin-left {
    margin-left: 2rem;
}
.l-shape {
    border-left: 2px solid black;
    border-bottom: 2px solid black;
    margin-bottom: 1px;
}
</style>
