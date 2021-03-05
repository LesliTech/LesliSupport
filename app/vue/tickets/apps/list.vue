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
export default {
    props: {

    },
    
    components: {

    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable tickets [Array] An array of objects, each object represents a 
    //      Ticket type, with the same params as the associated rails model
    data(){
        return {
            filters_route: '/help/tickets/options?filters[include]=statuses',
            translations: {
                main: I18n.t('help.tickets'),
                core: I18n.t('core.shared')
            },
            tickets: [],
            loading: false,
            pagination: {
                tickets_count: 0,
                current_page: 1,
                range_before: 3,
                range_after: 3
            },
            filters: {
                search_type: null,
                user_type: 'own',
                query: '',
                per_page: 15,
                statuses: [],
                sorting_field: 'deadline',
                sorting_order: 'desc'
            },
            ticket_filters: {
                statuses: []
            },
            filtered_statuses: [],
            filters_ready: false,
            index_abilities: this.abilities.privilege('tickets', 'cloud_help')
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
        this.setSessionStorageFilters()
        this.getTicketsFilters()
       this.getTickets()
    },

    methods: {

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves a list of Ticket associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.tickets) // will display null
        //      this.getTickets()
        //      console.log(this.tickets) // will display an array of objects, each representing a Ticket.

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
        // @description Connects to the backend using HTTP and retrieves a list of Ticket type associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.tickets) // will display null
        //      this.getTickets()
        //      console.log(this.tickets) // will display an array of objects, each representing a Ticket type.
        getTickets(reset_current_page = true) {
            this.loading = true
            this.storage.local("filters", this.filters)
            if(reset_current_page){
                this.pagination.current_page = 1
            }

            let url = this.url.help('tickets').order(
                this.filters.sorting_field,
                this.filters.sorting_order
            ).paginate(
                this.pagination.current_page,
                this.filters.per_page
            ).filters({
                statuses: this.filters.statuses,
                search_type: this.filters.search_type,
                user_type: this.filters.user_type,
                query: this.filters.query
            })

            this.http.get(url).then(result => {
                this.loading = false
                if (result.successful) {
                    this.tickets = result.data.tickets
                    this.pagination.tickets_count = result.data.total_count
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        // @return [void]
        // @param ticket [Object] The object representation of the selected Ticket type
        // @description Redirects the router to show the selected Ticket type
        // @example
        //      this.showTicket(this.tickets[1])
        //      // Asume the id of the Ticket type is 4
        //      // The user will be redirected to the url /help/tickets/4
        showTicket(ticket) {
            if(ticket.editable){
                this.$router.push(`/${ticket.id}/edit`)
            }else{
                this.$router.push(`/${ticket.id}`)
            }
        },

        reloadTickets(){
            this.loading = true
            this.getTickets()
        },

        searchTickets(text) {
            this.filters.query = text
            this.getTickets()
        },

        sortTickets(field, order){
            if(this.filters.sorting_field == field){
                if(this.filters.sorting_order == 'asc'){
                    this.filters.sorting_order = 'desc'
                }else{
                    this.filters.sorting_order = 'asc'
                }
            }else{
                this.filters.sorting_field = field
                this.filters.sorting_order = 'desc'
            }
            this.getTickets()
        },

        getFilteredStatuses(text){
            text = text.toLowerCase()
            this.filtered_statuses = this.ticket_filters.statuses.filter((status) => {
                return status.text.toLowerCase().includes(text)
            })
        },

        getTicketsFilters(){
            this.http.get(this.filters_route).then(result => {
                if (result.successful) {
                    this.ticket_filters = result.data
                    this.getFilteredStatuses('')
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        extractInitials(name){
            return name.split(" ").map((word)=>{
                if(word){
                    return word[0].toUpperCase()
                }else{
                    return ''
                }
            }).join("")
        }
    },

    watch: {
        'pagination.current_page': function(){
            if(! this.loading){
                this.getTickets(false)
            }
        },
        
        'filters.per_page'(){
            if(this.filters_ready){
                this.getTickets(true)
            }
        },
    }
}
</script>
<template>
    <section class="application-component">
        <component-header 
            :title="translations.main.view_title_main">
            <div class="buttons">
                <button class="button" @click="reloadTickets()">
                    <b-icon icon="sync" size="is-small" :custom-class="loading ? 'fa-spin' : ''" />
                    <span> {{ translations.core.view_text_btn_reload }}</span>
                </button>
                <router-link class="button" tag="button" to="/new" v-if="index_abilities.grant_create">
                    <b-icon icon="plus" size="is-small" />
                    <span>{{ translations.main.view_btn_create }}</span>
                </router-link>
            </div>
        </component-header>

        <component-toolbar
            v-if="filters_ready"
            :search-text="translations.main.view_placeholder_text_filter"
            @search="searchTickets"
            :initial-value="filters.query"
        >
            <div class="control is-expanded">
                <b-taginput
                    name="tickets-filters-statuses"
                    autocomplete
                    :open-on-focus="true"
                    field="text"
                    v-model="filters.statuses"
                    :data="filtered_statuses"
                    :placeholder="translations.main.view_placeholder_status_filter"
                    @typing="getFilteredStatuses"
                    @input="getTickets"
                />
            </div>
            <div class="control">
                <div class="select">
                    <select v-model="filters.user_type" @change="getTickets" name="tickets-filters-user-type">
                        <option :value="null">{{translations.main.view_text_filter_everyones_tickets}}</option>
                        <option value="own">{{translations.main.view_text_filter_own_tickets}}</option>
                    </select>
                </div>
            </div>
            <div class="control">
                <div class="select">
                    <select v-model="filters.search_type" @change="getTickets" name="tickets-filters-search-type">
                        <option :value="null">{{translations.main.view_text_filter_all_tickets}}</option>
                        <option value="active">{{translations.main.view_text_filter_active_tickets}}</option>
                        <option value="inactive">{{translations.main.view_text_filter_inactive_tickets}}</option>
                    </select>
                </div>
            </div>
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
                <component-data-empty v-if="!loading && tickets.length == 0" />
                
                <b-table
                    :data="tickets"
                    @click="showTicket"
                    :hoverable="true"
                    v-if="!loading && tickets.length > 0"
                    @sort="sortTickets"
                    backend-sorting
                    narrowed
                >
                    <template slot-scope="props">
                        <b-table-column field="id" :label="translations.main.column_id" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="filters.sorting_field == 'id'">
                                    <b-icon v-if="filters.sorting_order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.id}}
                        </b-table-column>

                        <b-table-column field="subject" :label="translations.main.column_subject" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="filters.sorting_field == 'subject'">
                                    <b-icon v-if="filters.sorting_order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.subject}}
                        </b-table-column>

                        <b-table-column field="deadline" :label="translations.main.column_deadline" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="filters.sorting_field == 'deadline'">
                                    <b-icon v-if="filters.sorting_order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.deadline}}
                        </b-table-column>

                        <b-table-column field="status_name" :label="translations.main.column_cloud_help_workflow_statuses_id" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="filters.sorting_field == 'status_name'">
                                    <b-icon v-if="filters.sorting_order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{object_utils.translateEnum(translations.core, 'column_enum_status', props.row.status_name)}}
                        </b-table-column>

                        <b-table-column field="type" :label="translations.main.column_cloud_help_catalog_ticket_types_id" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="filters.sorting_field == 'type'">
                                    <b-icon v-if="filters.sorting_order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.type}}
                        </b-table-column>

                        <b-table-column field="category" :label="translations.main.column_cloud_help_catalog_ticket_categories_id" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="filters.sorting_field == 'category'">
                                    <b-icon v-if="filters.sorting_order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.category}}
                        </b-table-column>

                        <b-table-column field="priority_weight" :label="translations.main.column_cloud_help_catalog_ticket_priorities_id" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="filters.sorting_field == 'priority_weight'">
                                    <b-icon v-if="filters.sorting_order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.priority}}
                        </b-table-column>

                        <b-table-column field="assignables" :label="translations.main.column_user_main_id">
                            <span v-if="props.row.assignables && props.row.assignables.length > 0">
                                <span v-for="(assignable, index) in props.row.assignables" :key="index">
                                    <b-tooltip type="is-white" :label="assignable">
                                        <b-tag>{{extractInitials(assignable)}}</b-tag>
                                        &nbsp;
                                    </b-tooltip>
                                </span>
                            </span>
                            <span v-else>
                                --
                            </span>
                        </b-table-column>
                    </template>
                </b-table>
                <hr>
                <b-pagination
                    :simple="false"
                    :total="pagination.tickets_count"
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
