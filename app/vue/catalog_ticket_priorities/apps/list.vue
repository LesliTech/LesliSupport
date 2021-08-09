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
export default {
    props: {
        appMountPath: {
            type: String,
            default: ''
        }
    },
    
    components: {

    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable ticket_priorities [Array] An array of objects, each object represents a 
    //      Ticket priority, with the same params as the associated rails model
    data(){
        return {
            main_route: '/help/catalog/ticket_priorities',
            translations: {
                main: I18n.t('help.catalog/ticket_priorities'),
                core: I18n.t('core.shared')
            },
            ticket_priorities: [],
            loading: false,
            pagination: {
                ticket_priorities_count: 0,
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
            index_abilities: this.abilities.privilege('catalog/ticket_priorities', 'cloud_help')
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
        this.setSessionStorageFilters()
       this.getTicketPriorities()
    },

    methods: {

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves a list of TicketPriority associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.ticket_priorities) // will display null
        //      this.getTicketPriorities()
        //      console.log(this.ticket_priorities) // will display an array of objects, each representing a TicketPriority.

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
        // @description Connects to the backend using HTTP and retrieves a list of Ticket priority associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.ticket_priorities) // will display null
        //      this.getTicketPriorities()
        //      console.log(this.ticket_priorities) // will display an array of objects, each representing a Ticket priority.
        getTicketPriorities(reset_current_page = true) {
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
                    this.ticket_priorities = result.data.ticket_priorities

                    if(result.data.total_count != null){
                        this.pagination.ticket_priorities_count = result.data.total_count
                    }
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        // @return [void]
        // @param ticket_priority [Object] The object representation of the selected Ticket priority
        // @description Redirects the router to show the selected Ticket priority
        // @example
        //      this.showTicketPriority(this.ticket_priorities[1])
        //      // Asume the id of the Ticket priority is 4
        //      // The user will be redirected to the url /help/catalog/ticket_priorities/4
        showTicketPriority(ticket_priority) {
            this.$router.push(`${this.appMountPath}/${ticket_priority.id}`)
        },

        reloadTicketPriorities(){
            this.loading = true
            this.getTicketPriorities()
        },

        searchTicketPriorities(text) {
            this.filters.query = text
            this.getTicketPriorities()
        },

        sortTicketPriorities(field, order){
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
            this.getTicketPriorities()
        }
    },

    watch: {
        'pagination.current_page': function(){
            if(! this.loading){
                this.getTicketPriorities(false)
            }
        },
        
        'filters.per_page'(){
            if(this.filters_ready){
                this.getTicketPriorities(true)
            }
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header 
            :title="translations.main.view_title_main">
            <div class="buttons">
                <button class="button" @click="reloadTicketPriorities()">
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
            @search="searchTicketPriorities"
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

                <component-data-loading v-if="loading" />
                <component-data-empty v-if="!loading && ticket_priorities.length == 0" />
                
                <b-table
                    :data="ticket_priorities"
                    @click="showTicketPriority"
                    :hoverable="true"
                    v-if="!loading && ticket_priorities.length > 0"
                    @sort="sortTicketPriorities"
                    backend-sorting
                >
                    <template slot-scope="props">
                        <b-table-column field="id" :label="translations.main.column_id" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'id'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.id}}
                        </b-table-column>

                        <b-table-column field="name" :label="translations.main.column_name" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'name'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.name}}
                        </b-table-column>

                        <b-table-column field="weight" :label="translations.main.column_weight" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'weight'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.weight}}
                        </b-table-column>

                        <b-table-column field="created_at" :label="translations.main.column_created_at" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'created_at'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.created_at}}
                        </b-table-column>
                    </template>
                </b-table>
                <hr>
                <b-pagination
                    :simple="false"
                    :total="pagination.ticket_priorities_count"
                    :current.sync="pagination.current_page"
                    :range-before="pagination.range_before"
                    :range-after="pagination.range_after"
                    :per-page="filters.per_page"
                    order="is-centered"
                    icon-prev="chevron-left"
                    icon-next="chevron-right"
                    aria-next-label="Next page"
                    aria-previous-label="Previous page"
                    aria-page-label="Page"
                    aria-current-label="Current page"
                >
                </b-pagination>
            </div>
        </div>
    </section>
</template>
