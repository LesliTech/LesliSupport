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
        ticketId: {
            required: true
        },
        ticketEditable: {
            type: Boolean,
            default: true
        }
    },

    data(){
        return {
            active_tab: 1,
            main_route: '/help/tickets',
            users_route: '/administration/users/list.json?role=support&type=include',
            translations: {
                main: I18n.t('help.ticket/assignments'),
                core: I18n.t('core.shared'),
                users: I18n.t('core.users'),
                roles: I18n.t('core.roles')
            },
            loading: {
                assignments: false,
                options: false
            },
            loaded: {
                assignments: false,
                assignment_options: false
            },
            search: '',
            pagination: {
                current_page: 1,
                range_before: 3,
                range_after: 3,
                per_page: 8
            },
            assignment_options: {
                users: []
            },
            ticket: {},
            assignments: []
        }
    },

    mounted(){
        this.setTicket()
        this.getUsers()
    },

    methods: {
        setTicket(){
            this.ticket = this.data.ticket
        },

        getUsers(){
            this.loading.options = true

            this.http.get(this.users_route).then(result => {
                this.loading.options = false
                if (result.successful) {
                    this.$set(this.assignment_options, 'users', result.data)
                    this.data.assignment_options = this.assignment_options
                    this.loaded.assignment_options = true
                    this.markAssignables()
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        clearSearch(ticket){
            if(ticket){
                ticket.prticketDefault()
            }
            
            this.search = ''
        },

        submitAssignment(user){
            if(user.checked){
                this.postAssignment(user)
            }else{
                this.deleteAssignment(user)
            }
        },

        postAssignment(user){
            let url = this.url.help(`/tickets/${this.ticketId}/assignments`)
            let data = {
                ticket_assignment: {
                    users_id: user.id,
                    assignment_type: 'user'
                }
            }
            this.$set(user, 'submitting', true)

            this.http.post(url, data).then(result => {
                this.$set(user, 'submitting', false)
                if (result.successful) {
                    this.$set(user, 'checked', true)
                    this.$set(user, 'assignment_id', result.data.id)
                    this.ticket.assignment_attributes.push({
                        id: result.data.id,
                        assignable_name: user.name || user.email,
                        users_id: user.id
                    })
                    this.alert(this.translations.main.messages_info_assignment_created, 'success')

                    // The user assigned the ticket to themselves, so we move to the edit view
                    if(user.id == lesli.current_user.id){
                        this.$router.push(`/${this.ticketId}/edit`).catch((error)=>{})
                    }

                    this.reloadTicketRecord()
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        deleteAssignment(assignment){
            // If it is clicked from the main tab, the assignment object received will have the id in the 'assignment_id' field
            let assignment_id = assignment.assignment_id
            // However, if it is not clicked from the main tab, the object received will have the id in the 'id' field
            if(! assignment_id){
                assignment_id = assignment.id
            }
            let url = `${this.main_route}/${this.ticketId}/assignments/${assignment_id}`
            this.$set(assignment, 'submitting', true)

            this.http.delete(url).then(result => {
                this.$set(assignment, 'submitting', false)
                if (result.successful) {
                    this.alert(this.translations.main.messages_info_assignment_deleted, 'success')
                    
                    this.ticket.assignment_attributes = this.ticket.assignment_attributes.filter((assignment)=>{
                        return assignment.id != assignment_id
                    })

                    let user = this.assignment_options.users.find((user)=>{
                        return user.assignment_id == assignment_id
                    })
                    user.assignment_id = null
                    user.checked = false
                    
                    this.reloadTicketRecord()
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        clearOptions(){
            this.assignment_options.users.forEach((user)=>{
                this.$set(user, 'checked', false)
            })
        },

        markAssignables(){
            let users = this.assignment_options.users
            this.ticket.assignment_attributes.forEach((assignment)=>{
                let user = users.find((user)=>{
                    return user.id == assignment.users_id
                })
                this.$set(user, 'assignment_id', assignment.id)
                this.$set(user, 'checked', true)
            })
        },

        reloadTicketRecord(){
            this.data.reload.activities = true
            this.data.reload.timelines = true
        }
    },

    computed: {
        filteredUsers(){
            let search_field = this.search.toLowerCase()
            return this.assignment_options.users.filter((user)=>{
                return user.email.toLowerCase().includes(search_field) ||
                    (
                        user.name &&
                        user.name.toLowerCase().includes(search_field)
                    ) ||
                    (
                        user.role &&
                        user.role.toLowerCase().includes(search_field)
                    )
            })
        },

        currentUserPage(){
            if(this.filteredUsers.length <= this.pagination.per_page){
                return this.filteredUsers
            }else{
                let data = this.filteredUsers.slice(
                    (this.pagination.current_page - 1) * this.pagination.per_page,
                    (this.pagination.current_page) * this.pagination.per_page
                )
                return data
            }
        }
    },

    watch: {
        ticketId(){
            this.loaded.assignments = false
            this.clearOptions()
        },

        ticketEditable(){
            if(! this.ticketEditable){
                this.active_tab = 1
            }
        },

        'assignment_options.users'(){
            let assignable = this.assignment_options.users.find((user)=>{
                return user.id == lesli.current_user.id
            })

            this.data.ticket_assignable = Boolean(assignable)
        },

        search(){
            this.pagination.current_page = 1
        },

        'data.events.post_auto_assignment'(){
            if(this.data.events.post_auto_assignment){
                this.data.events.post_auto_assignment = false

                let current_user = this.assignment_options.users.find((user)=>{
                    return user.id == lesli.current_user.id
                })

                if(current_user){
                    this.postAssignment(current_user)
                }

            }
        }
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
        <component-data-empty v-if="!loading.options && assignment_options.users.length == 0" />
        <b-table :data="currentUserPage">
            <template slot-scope="props">
                <b-table-column field="name" :label="translations.users.view_table_header_name">
                    {{ props.row.name }}
                </b-table-column>
                <b-table-column field="email" :label="translations.users.view_table_header_email">
                    {{ props.row.email }}
                </b-table-column>
                <b-table-column field="role" :label="translations.users.view_table_header_role">
                    <span>
                        <span v-for="role in props.row.roles" :key="`employee-${props.row.id}-${role.id}`">
                            <b-tooltip type="is-white" :label="object_utils.translateEnum(translations.roles, 'column_enum_role', role.name)">
                                <b-tag type="is-white">{{
                                    object_utils.extractInitials(object_utils.translateEnum(translations.roles, 'column_enum_role', role.name))
                                }}</b-tag>
                                &nbsp;
                            </b-tooltip>
                        </span>
                    </span>
                </b-table-column>
                <b-table-column field="actions" label="">
                    <b-checkbox :disabled="props.row.submitting" size="is-small" v-model="props.row.checked" @input="submitAssignment(props.row)" />
                </b-table-column>
            </template>
        </b-table>
        <hr>
        <b-pagination
            :simple="false"
            :total="filteredUsers.length"
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
