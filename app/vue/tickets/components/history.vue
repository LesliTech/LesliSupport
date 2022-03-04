<script>
export default {
    props: {
        active: {
            type: Boolean,
            default: true
        },

        ticketId: {
            required: true
        }
    },

    data(){
        return {
            translations: {
                tickets: I18n.t('help.tickets'),
                core: I18n.t('core.shared'),
                main: I18n.t('help.ticket/histories')
            },
            object_name: null,
            loading: false,
            search: '',
            submitting_form: false,
            history: {
                content: '',
                label: null,
            },
            sort: {
                icon_size: 'is-small',
                direction: 'desc'
            },
            pagination: {
                current_page: 1,
                range_before: 3,
                range_after: 3,
                per_page: 6
            },
            histories: null
        }
    },

    mounted(){
        this.getBackendData()
    },

    methods: {
        getBackendData(){
            if(this.active){
                this.getHistories()
            }
        },

        getHistories() {
            let url = this.url.help(`tickets/${this.ticketId}/histories`)
            this.loading = true

            this.http.get(url).then(result => {
                this.loading = false
                if (result.successful) {
                    this.histories = result.data
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        postHistory(event) {
            if(event){
                event.preventDefault()
            }

            let url = this.url.help(`tickets/${this.ticketId}/histories`)
            let data = {
                ticket_history: this.history
            }
            this.submitting_form = true

            this.http.post(url, data).then(result => {
                if (result.successful) {
                    this.msg.success(this.translations.main.messages_info_history_created)

                    this.resetHistoryForm()
                    this.histories.push(result.data)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            }).finally(()=>{
                this.submitting_form = false
            })

        },

        resetHistoryForm(){
            this.history.content = ''
        },

        clearSearch(event){
            if(event){
                event.preventDefault()
            }

            this.search = ''
        },

        confirmCommentDeletion(comment) {
            window.scrollTo(0,0)
            this.$buefy.dialog.confirm({
                title: this.translations.main.messages_danger_delete_confirmation_title,
                message: this.translations.main.messages_danger_delete_confirmation_body,
                confirmText: this.translations.core.biew_btn_accept,
                cancelText: this.translations.core.view_btn_cancel,
                type: 'is-danger',
                hasIcon: true,
                onConfirm: () => this.deleteComment(comment)
            })
        },

        putHistory(comment){
            let url = this.url.help(`tickets/${this.ticketId}/histories/${comment.id}`)
            let data = {
                ticket_history: {
                    content: comment.new_content
                }
            }

            this.http.put(url, data).then(result => {
                if (result.successful) {
                    this.$set(comment, 'content', comment.new_content)
                    this.$set(comment, 'editing', false)
                    this.msg.success(this.translations.main.messages_info_history_updated)

                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        deleteComment(comment){
            let comment_id = comment.id
            let url = this.url.help(`tickets/${this.ticketId}/histories/${comment_id}`)

            this.http.delete(url).then(result => {
                if (result.successful) {
                    this.msg.success(this.translations.main.messages_info_history_destroyed)
                    
                    this.histories = this.histories.filter((history)=>{
                        return history.id != comment.id
                    })
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        showCommentEditForm(comment){
            this.$set(comment, 'new_content', comment.content)
            this.$set(comment, 'editing', true)
            this.$nextTick(()=>{
                this.$refs[`comment-input-${comment.id}`].focus()
            })
        }
    },

    computed: {
        filteredHistories(){
            let search_field = this.search.toLowerCase()
            this.pagination.current_page = 1
            return this.histories.filter((history)=>{
                return history.user_creator_email.toLowerCase().includes(search_field) ||
                    (
                        history.user_creator_name &&
                        history.user_creator_name.toLowerCase().includes(search_field)
                    ) ||
                    history.data.content.toLowerCase().includes(search_field)
            })
        }
    },

    watch: {
        ticketId(){
            this.getHistories()
        },

        active(){
            if(! this.histories){
                this.getBackendData()
            }
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <div class="card-header-title is-shadowless">
                <h4 class=" title is-4">
                {{translations.tickets.view_tab_title_histories}}
                </h4>
            </div>
        </div>
        <br>
        <div class="card-content">
            <form @submit="postHistory">
                <fieldset :disabled="submitting_form">
                    <b-field grouped>
                        <b-input required :placeholder="translations.main.view_placeholder_add_history" ref="input-comment" v-model="history.content" expanded>
                        </b-input>
                        <p class="control">
                            <b-button type="is-primary" native-type="submit">
                                <span v-if="submitting_form">
                                    <b-icon icon="circle-notch" custom-class="fa-spin" size="is-small" />
                                    &nbsp;
                                    {{translations.core.view_btn_saving}}
                                </span>
                                <span v-else>
                                    {{translations.core.view_btn_save}}
                                </span>
                            </b-button>
                        </p>
                    </b-field>
                </fieldset>
            </form>
            <br>
            <div class="columns">
                <div class="column is-7">
                    <b-field>
                        <b-input
                            :placeholder="translations.main.view_placeholder_search_text"
                            v-model="search"
                            type="text"
                            icon="search"
                            icon-right="close-circle"
                            icon-right-clickable
                            @icon-right-click="clearSearch">
                        </b-input>
                    </b-field>
                </div>
                <div class="column is-5 has-text-right">
                    <b-button @click="getHistories">
                        &nbsp;
                        <b-icon size="is-small" icon="sync">
                        </b-icon>
                        &nbsp;
                    </b-button>
                </div>
            </div>
            <component-data-loading v-if="loading" />
            <component-data-empty v-if="!loading && histories && histories.length == 0" />
            <b-table
                v-if="!loading && histories && histories.length > 0"
                :data="filteredHistories"
                :sort-icon-size="sort.icon_size"
                :default-sort-direction="sort.direction"
                :paginated="true"
                :per-page="pagination.per_page"
                :current-page.sync="pagination.current_page"
                :pagination-simple="false"
                pagination-position="bottom"
            >
                <template slot-scope="props">
                    <b-table-column field="data.created_at_raw" :label="translations.core.column_created_at" sortable>
                        <small>{{ props.row.created_at }}</small>
                    </b-table-column>

                    <b-table-column field="data.user_creator_name" :label="translations.main.column_users_id" sortable>
                        <small>
                            <span v-if="props.row.user_creator_name">
                                {{props.row.user_creator_name}}
                            </span>
                            <span v-else>
                                {{props.row.user_creator_email}}
                            </span>
                        </small>
                    </b-table-column>

                    <b-table-column field="data.content" :label="translations.main.column_content" sortable>
                        <span v-if="props.row.editing">
                            <b-field>
                                <b-input
                                    type="textarea"
                                    size="is-small"
                                    v-model="props.row.new_content"
                                    :ref="`comment-input-${props.row.id}`"
                                >
                                </b-input>
                            </b-field>
                        </span>
                        <span v-else>
                            <small>{{ props.row.content }}</small>
                        </span>
                    </b-table-column>

                    <b-table-column field="actions" :label="translations.core.view_table_header_actions" class="has-text-right">
                        <span v-if="props.row.editable">
                            <span v-if="props.row.editing">
                                <b-button size="is-small" outlined @click="putHistory(props.row)">
                                    <b-icon size="is-small" icon="check" />
                                </b-button>
                                <b-button size="is-small" type="is-danger" outlined @click="() => $set(props.row, 'editing', false)">
                                    <b-icon size="is-small" icon="times" />
                                </b-button>
                            </span>
                            <span v-else>
                                <b-button size="is-small" outlined @click="showCommentEditForm(props.row)">
                                    <b-icon size="is-small" icon="edit" />
                                </b-button>
                                <b-button size="is-small" type="is-danger" outlined @click="confirmCommentDeletion(props.row)">
                                    <b-icon size="is-small" icon="trash-alt" />
                                </b-button>
                            </span>
                        </span>
                    </b-table-column>
                </template>
            </b-table>
        </div>
    </div>
</template>
