<script>
/*

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

*/


// · Component list
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentTreeList from '../components/tree_list.vue'


export default {
    props: {
        appMountPath: {
            type: String,
            default: ''
        }
    },
    
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
            <div class="navbar-item">
                <div class="buttons">
                    <router-link class="button" :to="`${appMountPath}/`">
                        <b-icon icon="list" size="is-small" />
                        <span>{{ translations.core.view_btn_list }}</span>
                    </router-link>
                    <router-link class="button" :to="`${appMountPath}/${ticket_category_id}/edit`">
                        <b-icon icon="edit" size="is-small" />
                        <span>{{translations.core.view_btn_edit}}</span>
                    </router-link>
                </div>
            </div>
        </component-header>
        <div class="card">
            <div class="card-content">
                <div class="columns">
                    <div class="column">
                        <span>
                            <span class="has-text-weight-bold">
                                {{ translations.main.column_name }}:
                            </span>
                            {{ ticket_category.name }}
                            <hr>
                            <span class="has-text-weight-bold">
                                {{ translations.main.view_text_category_path }}:
                            </span>
                            <component-tree-list :trees="category_tree" :scrollable="true" :app-mount-path="appMountPath">
                            </component-tree-list>
                        </span>
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
