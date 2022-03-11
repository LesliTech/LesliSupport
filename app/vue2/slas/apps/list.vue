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
    // @data_variable slas [Array] An array of objects, each object represents a 
    //      Sla type, with the same params as the associated rails model
    data(){
        return {
            main_route: '/help/slas',
            filters_route: '/help/slas/options?filters[include]=statuses',
            translations: {
                main: I18n.t('help.slas'),
                core: I18n.t('core.shared')
            },
            slas: [],
            loading: false,
            pagination: {
                slas_count: 0,
                current_page: 1,
                range_before: 3,
                range_after: 3
            },
            filters: {
                search_type: 'all',
                query: '',
                per_page: 15,
                statuses: []
            },
            sla_filters: {
                statuses: []
            },
            filtered_statuses: [],
            filters_ready: false,
            sorting: {
                field: 'id',
                order: 'asc'
            },
            index_abilities: this.abilities.privilege('slas', 'cloud_help')
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
        this.setSessionStorageFilters()
        this.getSlasFilters()
       this.getSlas()
    },

    methods: {

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves a list of Sla associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.slas) // will display null
        //      this.getSlas()
        //      console.log(this.slas) // will display an array of objects, each representing a Sla.

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
        // @description Connects to the backend using HTTP and retrieves a list of Sla type associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.slas) // will display null
        //      this.getSlas()
        //      console.log(this.slas) // will display an array of objects, each representing a Sla type.
        getSlas(reset_current_page = true) {
            this.loading = true
            this.storage.local("filters", this.filters)
            let url = `${this.main_route}/list.json`

            let data = {
                filters: {
                    statuses: this.filters.statuses,
                    search_type: this.filters.search_type,
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
                    this.slas = result.data.slas

                    if(result.data.total_count != null){
                        this.pagination.slas_count = result.data.total_count
                    }
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        // @return [void]
        // @param sla [Object] The object representation of the selected Sla type
        // @description Redirects the router to show the selected Sla type
        // @example
        //      this.showSla(this.slas[1])
        //      // Asume the id of the Sla type is 4
        //      // The user will be redirected to the url /help/slas/4
        showSla(sla) {
            if(sla.editable){
                this.$router.push(`${this.appMountPath}/${sla.id}/edit`)
            }else{
                this.$router.push(`${this.appMountPath}/${sla.id}`)
            }
        },

        reloadSlas(){
            this.loading = true
            this.getSlas()
        },

        searchSlas(text) {
            this.filters.query = text
            this.getSlas()
        },

        sortSlas(field, order){
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
            this.getSlas()
        },

        getFilteredStatuses(text){
            text = text.toLowerCase()
            this.filtered_statuses = this.sla_filters.statuses.filter((status) => {
                return status.text.toLowerCase().includes(text)
            })
        },

        getSlasFilters(){
            this.http.get(this.filters_route).then(result => {
                if (result.successful) {
                    this.sla_filters = result.data
                    this.getFilteredStatuses('')
                }else{
                    this.msg.error(result.error.message)
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
                this.getSlas(false)
            }
        },
        
        'filters.per_page'(){
            if(this.filters_ready){
                this.getSlas(true)
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
                <button class="button" @click="reloadSlas()">
                    <b-icon icon="sync" size="is-small" :custom-class="loading ? 'fa-spin' : ''" />
                    <span> {{ translations.core.view_text_btn_reload }}</span>
                </button>
                <router-link class="button" tag="button" :to="`${this.appMountPath}/new`" v-if="index_abilities.create">
                    <b-icon icon="plus" size="is-small" />
                    <span>{{ translations.main.view_btn_create }}</span>
                </router-link>
            </div>
        </component-header>

        <component-toolbar
            v-if="filters_ready"
            :search-text="translations.main.view_placeholder_text_filter"
            @search="searchSlas"
            :initial-value="filters.query"
        >
            <div class="control is-expanded">
                <b-taginput
                    name="slas-filters-statuses"
                    autocomplete
                    :open-on-focus="true"
                    field="text"
                    v-model="filters.statuses"
                    :data="filtered_statuses"
                    :placeholder="translations.core.view_placeholder_status_filter"
                    @typing="getFilteredStatuses"
                    @input="getSlas"
                />
            </div>
            <div class="control">
                <div class="select">
                    <select v-model="filters.search_type" @change="getSlas" name="slas-filters-search-type">
                        <option value="all">{{translations.main.view_text_filter_all_slas}}</option>
                        <option value="active">{{translations.main.view_text_filter_active_slas}}</option>
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
                <component-data-empty v-if="!loading && slas.length == 0" />
                
                <b-table
                    :data="slas"
                    @click="showSla"
                    :hoverable="true"
                    v-if="!loading && slas.length > 0"
                    @sort="sortSlas"
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

                        <b-table-column field="default" :label="translations.main.column_default" sortable>
                            <template slot="header" slot-scope="{ column }">
                                <span>
                                    {{ column.label }}
                                    <span v-if="sorting.field == 'default'">
                                        <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                        <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                    </span>
                                </span>
                            </template>
                            <span v-if="props.row.default">
                                <b>{{translations.core.view_text_yes}}</b>
                            </span>
                            <span v-else>
                                {{translations.core.view_text_no}}
                            </span>
                        </b-table-column>

                        <b-table-column field="status" :label="translations.main.column_cloud_help_workflow_statuses_id" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'status'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{object_utils.translateEnum(translations.core, 'column_enum_status', props.row.status)}}
                        </b-table-column>

                        <b-table-column field="expected_response_time" :label="translations.main.column_expected_response_time" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'expected_response_time'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.expected_response_time}}
                        </b-table-column>

                        <b-table-column field="expected_resolution_time" :label="translations.main.column_expected_resolution_time" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'expected_resolution_time'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.expected_resolution_time}}
                        </b-table-column>
                    </template>
                </b-table>
                <hr>
                <b-pagination
                    :simple="false"
                    :total="pagination.slas_count"
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
