<script>
/*
Lesli

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

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~

// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    props: {
        cloudEngine: {
            type: String,
            required: true
        },

        engineNamespace: {
            type: String,
            required: true
        }
    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable workflows [Array] An array of objects, each object represents a 
    //      Workflow, with the same params as the associated rails model
    data(){
        return {
            main_route: `/${this.engineNamespace}/workflows`,
            translations: {
                main: I18n.t(`${this.engineNamespace}.workflows`),
                shared: I18n.t(`${this.engineNamespace}.shared`),
                core: I18n.t('core.shared'),
                workflows: I18n.t('core.workflows')
            },
            pagination: {
                workflows_count: 0,
                current_page: 1,
                per_page: 15,
                range_before: 3,
                range_after: 3
            },
            filters: {
                query: ''
            },
            sorting: {
                field: 'name',
                order: 'desc'
            },
            workflows: [],
            loading: false,
            workflows_abilities: this.abilities.privilege('workflows', this.object_utils.toSnakeCase(this.cloudEngine))
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted(){
       this.getWorkflows()
    },

    methods: {
        // @return [void]
        // @description Connects to the backend using HTTP and retrieves a list of Workflow associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.workflows) // will display null
        //      this.getWorkflows()
        //      console.log(this.workflows) // will display an array of objects, each representing a Workflow.
        getWorkflows(reset_current_page = true) {
            this.loading = true

            let url = `${this.main_route}/list.json`

            let data = {
                filters: this.filters,
                perPage: this.pagination.per_page,
                order: this.sorting.order,
                orderColumn: this.sorting.field
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
                this.$emit('loading-done')
                
                if (result.successful) {
                    this.workflows = result.data.workflows
                    if(result.data.total_count){
                        this.pagination.workflows_count = result.data.total_count
                    }

                    if(result.data.total_count != null){
                        this.pagination.workflows_count = result.data.total_count
                    }
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        // @return [void]
        // @param workflow [Object] The object representation of the selected Workflow
        // @description Redirects the router to show the selected Workflow
        // @example
        //      this.showWorkflow(this.workflows[1])
        //      // Asume the id of the Workflow is 4
        //      // The user will be redirected to the url /crm/workflows/4
        showWorkflow(workflow) {
            this.$router.push(`/${workflow.id}?module=${this.mainRoutePrefix}`)
        },

        sortWorkflows(field, order){
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
            this.getWorkflows()
        },

        reloadWorkflows(){
            this.getWorkflows()
        },

        searchWorkflows(text){
            this.filters.query = text
            this.getWorkflows()
        }
    },

    watch: {
        'pagination.current_page': function(){
            if(! this.loading){
                this.getWorkflows(false)
            }
        },
        
        'filters.per_page'(){
            if(this.filters_ready){
                this.getWorkflows(true)
            }
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header 
            :title="translations.main.list_title">
            <div class="buttons">
                <button class="button" @click="reloadWorkflows()" :disabled="loading.global">
                    <b-icon icon="sync" size="is-small" :custom-class="loading.global ? 'fa-spin' : ''" />
                    <span>{{translations.shared.btn_reload}}</span>
                </button>
                <router-link class="button" tag="button" to="/new" v-if="workflows_abilities.grant_create">
                    <b-icon icon="plus" size="is-small" />
                    <span>{{ translations.main.list_button_create_title }}</span>
                </router-link>
            </div>
        </component-header>

        <component-toolbar
            :search-text="translations.main.list_filter_text_placeholder"
            @search="searchWorkflows"
            :initial-value="filters.query"
        >
        </component-toolbar>

        <div class="card">
            <div class="card-content">
                <component-data-loading v-if="loading" />
                <component-data-empty v-if="!loading && workflows.length == 0" />
                
                <b-table
                    v-if="!loading && workflows.length > 0"
                    :data="workflows"
                    :hoverable="true"
                    backend-sorting
                    @sort="sortWorkflows"
                    @click="showWorkflow"
                >
                    <template slot-scope="props">
                        <b-table-column field="name" :label="translations.shared.text_name" sortable>
                            <template slot="header" slot-scope="{ column }">
                                <span>
                                    {{ column.label }}
                                    <span v-if="sorting.field == 'name'">
                                        <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                        <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                    </span>
                                </span>
                            </template>
                            {{ props.row.name }}
                        </b-table-column>

                        <b-table-column field="default" :label="translations.main.field_default" sortable>
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
                                <b>{{translations.shared.text_yes}}</b>
                            </span>
                            <span v-else>
                                {{translations.shared.text_no}}
                            </span>
                        </b-table-column>

                        <b-table-column field="id" :label="translations.shared.text_created_at" sortable>
                            <template slot="header" slot-scope="{ column }">
                                <span>
                                    {{ column.label }}
                                    <span v-if="sorting.field == 'id'">
                                        <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                        <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                    </span>
                                </span>
                            </template>
                            {{ props.row.created_at }}
                        </b-table-column>
                    </template>
                </b-table>
                <hr>
                <b-pagination
                    :simple="false"
                    :total="pagination.workflows_count"
                    :current.sync="pagination.current_page"
                    :range-before="pagination.range_before"
                    :range-after="pagination.range_after"
                    :per-page="pagination.per_page"
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
