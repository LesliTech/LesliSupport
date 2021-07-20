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


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import treeList from '../components/tree_list.vue'

// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    props: {
        appMountPath: {
            type: String,
            default: ''
        }
    },
    
    components: {
        'tree-list': treeList
    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable ticket_categories [Array] An array of objects, each object represents a 
    //      Ticket category, with the same params as the associated rails model
    data(){
        return {
            main_route: '/help/catalog/ticket_categories',
            translations: {
                main: I18n.t('help.catalog/ticket_categories'),
                core: I18n.t('core.shared')
            },
            ticket_categories: [],
            loading: false,
            pagination: {
                ticket_categories_count: 0,
                current_page: 1,
                range_before: 3,
                range_after: 3
            },
            filters: {
                query: '',
                per_page: 15
            },
            filters_ready: false,
            sorting: {
                field: 'created_at',
                order: 'desc'
            },
            index_abilities: this.abilities.privilege('catalog/ticket_categories', 'cloud_help')
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
        this.setSessionStorageFilters()
        this.getTicketCategories()
    },

    methods: {

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves a list of TicketPriority associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.ticket_categories) // will display null
        //      this.getTicketCategories()
        //      console.log(this.ticket_categories) // will display an array of objects, each representing a TicketPriority.

        setSessionStorageFilters(){
            let stored_filters = this.storage.local("filters")

            if(stored_filters){
                for(let key in stored_filters){
                    this.$set(this.filters, key, stored_filters[key])
                }
            }
            
            this.$nextTick(()=>{
                this.filters_ready = true
            })
        },

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves a list of Ticket category associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.ticket_categories) // will display null
        //      this.getTicketCategories()
        //      console.log(this.ticket_categories) // will display an array of objects, each representing a Ticket category.
        getTicketCategories(reset_current_page = true) {
            this.loading = true
            this.storage.local("filters", this.filters)
            let url = `${this.main_route}/list.json`

            let data = {
                filters: {
                    query: this.filters.query
                },
                order: this.sorting.order,
                orderColumn: this.sorting.field,
                perPage: this.filters.per_page
            }
            if(reset_current_page){
                this.pagination.current_page = 1
                data.filters.get_total_count = true
            }else{
                data.filters.get_total_count = false
            }
            data.page = this.pagination.current_page

            this.http.post(url, data).then(result => {
                this.loading = false
                if (result.successful) {
                    this.ticket_categories = result.data.ticket_categories

                    if(result.data.total_count != null){
                        this.pagination.ticket_categories_count = result.data.total_count
                    }
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        reloadTicketCategories(){
            this.loading = true
            this.getTicketCategories()
        },

        searchTicketCategories(text) {
            this.filters.query = text
            this.getTicketCategories()
        },

        sortTicketCategories(field, order){
            if(this.sorting.field == field){
                if(this.sorting.order == 'asc'){
                    this.sorting.order = 'desc'
                }else{
                    this.sorting.order = 'asc'
                }
            }else{
                this.sorting.field = field
                this.sorting.order = 'desc'
            }
            this.getTicketCategories()
        }
    },

    watch: {
        'pagination.current_page': function(){
            if(! this.loading){
                this.getTicketCategories(false)
            }
        },
        
        'filters.per_page'(){
            if(this.filters_ready){
                this.getTicketCategories(true)
            }
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="translations.main.view_title_main">
            <div class="buttons">
                <button class="button" @click="reloadTicketCategories()">
                    <b-icon icon="sync" size="is-small" :custom-class="loading ? 'fa-spin' : ''" />
                    <span> {{ translations.core.view_text_btn_reload }}</span>
                </button>
                <router-link class="button" tag="button" :to="`${appMountPath}/new`" v-if="index_abilities.grant_create">
                    <b-icon icon="plus" size="is-small" />
                    <span>{{ translations.main.view_btn_create }}</span>
                </router-link>
            </div>
        </component-header>

        <component-toolbar
            v-if="filters_ready"
            :search-text="translations.main.view_placeholder_text_filter"
            @search="searchTicketCategories"
            :initial-value="filters.query"
        >
            <div class="control">
                <div class="select">
                    <select v-model="filters.per_page">
                        <option :value="10">10</option>
                        <option :value="15">15</option>
                        <option :value="30">30</option>
                        <option :value="50">50</option>
                    </select>
                </div>
            </div>
        </component-toolbar>

        <div class="card">
            <div class="card-content">
                

                <component-data-loading v-if="loading"></component-data-loading>
                <component-data-empty v-if="!loading && ticket_categories.length == 0"></component-data-empty>

                <tree-list v-if="!loading && ticket_categories.length > 0" :trees="ticket_categories" :app-mount-path="appMountPath">
                    <template v-slot:actions="{node}">
                        <router-link :to="`${appMountPath}/${node.id}`" class="button is-small">
                            <i class="fas fa-eye"></i>
                        </router-link>
                        &nbsp;
                        <router-link :to="`${appMountPath}/${node.id}/edit`" class="button is-small">
                            <i class="fas fa-edit"></i>
                        </router-link>
                    </template>
                </tree-list>
            </div>
        </div>
    </section>
</template>
