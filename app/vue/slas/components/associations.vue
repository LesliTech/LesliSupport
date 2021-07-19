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
        slaId: {
            required: true
        },
        slaEditable: {
            type: Boolean,
            default: true
        }
    },

    data(){
        return {
            active_tab: 1,
            main_route: '/help/slas',
            options_route: '/help/slas/associations/options.json',
            translations: {
                main: I18n.t('help.slas'),
                core: I18n.t('core.shared'),
                ticket_types: I18n.t('help.catalog/ticket_types'),
                roles: I18n.t('core.roles')
            },
            loading: {
                options: false
            },
            search: '',
            pagination: {
                current_page: 1,
                range_before: 3,
                range_after: 3,
                per_page: 8
            },
            association_options: {
                ticket_types: []
            },
            sla: {},
            associations: []
        }
    },

    mounted(){
        this.setSla()
        this.getOptions()
    },

    methods: {
        setSla(){
            this.sla = this.data.slas.sla
        },

        getOptions(){
            this.loading.options = true

            this.http.get(this.options_route).then(result => {
                this.loading.options = false
                if (result.successful) {
                    this.association_options = result.data
                    this.markAssociations()
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        clearSearch(sla){
            if(sla){
                sla.prslaDefault()
            }
            
            this.search = ''
        },

        submitAssociation(ticket_type){
            if(ticket_type.checked){
                this.postAssociation(ticket_type)
            }else{
                this.deleteAssociation(ticket_type)
            }
        },

        postAssociation(ticket_type){
            let url = `${this.main_route}/${this.slaId}/associations`
            let data = {
                sla_association: {
                    cloud_help_catalog_ticket_types_id: ticket_type.id
                }
            }
            this.$set(ticket_type, 'submitting', true)

            this.http.post(url, data).then(result => {
                this.$set(ticket_type, 'submitting', false)

                if (result.successful) {
                    this.$set(ticket_type, 'checked', true)
                    this.$set(ticket_type, 'association_id', result.data.id)
                    this.sla.association_attributes.push({
                        id: result.data.id,
                        assignable_name: ticket_type.name || ticket_type.email,
                        cloud_help_catalog_ticket_types_id: ticket_type.id
                    })
                    this.alert(this.translations.main.messages_success_association_created, 'success')

                    this.reloadSlaRecord()
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        deleteAssociation(association){
            // If it is clicked from the main tab, the association object received will have the id in the 'association_id' field
            let association_id = association.association_id
            // However, if it is not clicked from the main tab, the object received will have the id in the 'id' field
            if(! association_id){
                association_id = association.id
            }
            let url = `${this.main_route}/${this.slaId}/associations/${association_id}`
            this.$set(association, 'submitting', true)

            this.http.delete(url).then(result => {
                this.$set(association, 'submitting', false)
                if (result.successful) {
                    this.alert(this.translations.main.messages_success_association_destroyed, 'success')
                    
                    this.sla.association_attributes = this.sla.association_attributes.filter((association)=>{
                        return association.id != association_id
                    })

                    let ticket_type = this.association_options.ticket_types.find((ticket_type)=>{
                        return ticket_type.association_id == association_id
                    })
                    ticket_type.association_id = null
                    ticket_type.checked = false
                    
                    this.reloadSlaRecord()
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        clearOptions(){
            this.association_options.ticket_types.forEach((ticket_type)=>{
                this.$set(ticket_type, 'checked', false)
            })
        },

        markAssociations(){
            let ticket_types = this.association_options.ticket_types
            this.sla.association_attributes.forEach((association)=>{
                let ticket_type = ticket_types.find((ticket_type)=>{
                    return ticket_type.id == association.cloud_help_catalog_ticket_types_id
                })

                this.$set(ticket_type, 'association_id', association.id)
                this.$set(ticket_type, 'checked', true)
            })
        },

        reloadSlaRecord(){
            this.data.slas.reload.activities = true
        }
    },

    computed: {
        filteredTicketTypes(){
            let search_field = this.search.toLowerCase()
            return this.association_options.ticket_types.filter((ticket_type)=>{
                return ticket_type.name.toLowerCase().includes(search_field)
            })
        },

        currentTicketTypePage(){
            if(this.filteredTicketTypes.length <= this.pagination.per_page){
                return this.filteredTicketTypes
            }else{
                let data = this.filteredTicketTypes.slice(
                    (this.pagination.current_page - 1) * this.pagination.per_page,
                    (this.pagination.current_page) * this.pagination.per_page
                )
                return data
            }
        }
    },

    watch: {
        slaId(){
            this.clearOptions()
        },

        slaEditable(){
            if(! this.slaEditable){
                this.active_tab = 1
            }
        },

        search(){
            this.pagination.current_page = 1
        },
    }
}
</script>
<template>
    <section>
        <b-field>
            <b-input :placeholder="translations.main.view_placeholder_filter"
                v-model="search"
                type="text"
                icon="search"
                icon-right="close-circle"
                icon-right-clickable
                @icon-right-click="clearSearch">
            </b-input>
        </b-field>
        <component-data-loading v-if="loading.options" />
        <component-data-empty v-if="!loading.options && association_options.ticket_types.length == 0" />
        <b-table :data="currentTicketTypePage">
            <template slot-scope="props">
                <b-table-column field="id" :label="translations.ticket_types.column_id">
                    {{ props.row.id }}
                </b-table-column>
                <b-table-column field="name" :label="translations.ticket_types.column_name">
                    {{ props.row.name }}
                </b-table-column>
                <b-table-column field="actions" label="">
                    <b-checkbox :disabled="props.row.submitting" size="is-small" v-model="props.row.checked" @input="submitAssociation(props.row)" />
                </b-table-column>
            </template>
        </b-table>
        <hr>
        <b-pagination
            :simple="false"
            :total="filteredTicketTypes.length"
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
    </section>
</template>
