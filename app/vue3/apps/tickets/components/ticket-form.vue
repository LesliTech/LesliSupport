<script setup>
/*
Copyright (c) 2022, all rights reserved.

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


// · import vue tools
import { inject, onMounted, ref, onUnmounted } from "vue"

// · import lesli stores
import { useTickets } from "CloudHelp/stores/tickets/tickets"
import { useAssignments } from "CloudHelp/stores/tickets/assignment"

import editorRichText from "LesliVue/components/editors/richtext.vue"

// · import vue router composable
import { useRouter, useRoute } from "vue-router"

// · implement stores
const storeTickets = useTickets()
const storeAssignments = useAssignments()

// · initialize/inject plugins
const router = useRouter()
const url = inject("url")
const date = inject("date")
const route = useRoute()

// · defining props
const props = defineProps({
    isEditable: {
        type: Boolean,
        required: false,
        default: false,
    },
    path: {
        type: String,
        required: false,
        default: "help/tickets",
    }
})

// · 
const translations = {
    users: I18n.t("core.users"),
    shared: I18n.t("core.shared"),
    main: I18n.t('help.tickets')
}

/**
 * @description This function is used to update the ticket information
 */
const onUpdate = () => {
    storeTickets.updateTicket()
}

/**
 * @description This function is used to create a new ticket
 */
const onCreate = () => {
    storeTickets.postTicket()
    router.push(url.root(props.path).toString())
}


/**
 * Checking if the form is for a new ticket or for editing existing one
*/
if (props.isEditable){
    storeTickets.ticket = {}
    storeTickets.fetchTicket(route.params.id)
} else {
    storeTickets.ticket = {}
    storeTickets.tags = []
}

</script>
<template>
    <form class="information"
        v-if="!storeTickets.loading"
        @submit.prevent="isEditable ? onUpdate() : onCreate()"
    >

        <!-- On closed tickets -->
        <fieldset disabled v-if="storeTickets.ticket.status=='closed'">

            <!-- Ticket creator name -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> 
                        {{translations.main.column_users_id}}
                    </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input class="input" v-model="storeTickets.ticket.user_creator_name">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket reference url -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> 
                        {{translations.main.column_reference_url}}
                    </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="reference_url"  type="text" class="input" v-model="storeTickets.ticket.reference_url">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket assigned users -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> {{translations.main.view_title_assigned_users}} </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <div v-for="assignment in storeTickets.ticket.assignment_attributes" :key="assignment">
                                <span class="tag is-success">{{assignment.assignable_name}}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket subject -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> 
                        {{translations.main.column_subject}}
                        <span class="is-danger">*</span>
                    </label>
                    
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="subject" class="input" v-model="storeTickets.ticket.subject">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket deadline -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> {{translations.main.column_deadline}} </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="deadline"  class="input" type="date" v-model="storeTickets.ticket.deadline">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket types -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> 
                        {{translations.main.column_cloud_help_catalog_ticket_types_id}} 
                        <span class="is-danger">*</span>
                    </label>

                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-select
                                :options="storeTickets.options.types"
                                v-model="storeTickets.ticket.cloud_help_catalog_ticket_types_id"
                            >
                            </lesli-select>                        
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket category -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> {{translations.main.column_cloud_help_catalog_ticket_categories_id}} </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-select
                                v-if="storeTickets.options.categories"
                                :options="storeTickets.options.categories"
                                v-model="storeTickets.ticket.cloud_help_catalog_ticket_categories_id"
                            ></lesli-select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket priority -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> {{translations.main.column_cloud_help_catalog_ticket_priorities_id}} </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-select
                                v-if="storeTickets.options.priorities"
                                :options="storeTickets.options.priorities"
                                v-model="storeTickets.ticket.cloud_help_catalog_ticket_priorities_id"
                            ></lesli-select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket tags -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label">{{translations.main.column_tags}}</label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-input-tag 
                                v-model="storeTickets.tags"
                                placeholder="tags"
                                :options="[ 
                                    {
                                        name: 'Bug'
                                    },
                                    {
                                        name: 'Report'
                                    },
                                    {
                                        name: 'Performance'
                                    }
                                ]"
                                :filterFields="['name']"
                                showField="name"
                            />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket hours worked -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label">{{translations.main.column_hours_worked}}</label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="Hours word" class="input" type="number" v-model="storeTickets.ticket.hours_worked">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket description -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label">{{translations.main.column_description}}</label>
                </div>

                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <editor-rich-text mode="small" v-model="storeTickets.ticket.description">
                            </editor-rich-text>
                        </div>
                    </div>
                </div>
            </div>
        </fieldset>


        <!-- Show ticket info -->
        <fieldset v-else>
            <!-- Ticket creator name -->
            <div class="field is-horizontal" v-if="isEditable">
                <div class="field-label is-normal">
                    <label class="label"> 
                        {{translations.main.column_users_id}}
                    </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input class="input" disabled  v-model="storeTickets.ticket.user_creator_name">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket reference url -->
            <div class="field is-horizontal" v-if="isEditable">
                <div class="field-label is-normal">
                    <label class="label"> 
                        {{translations.main.column_reference_url}}
                    </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="reference_url" disabled type="text" class="input" v-model="storeTickets.ticket.reference_url">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket assigned users -->
            <div class="field is-horizontal" v-if="isEditable">
                <div class="field-label is-normal">
                    <label class="label"> {{translations.main.view_title_assigned_users}} </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <div v-for="assignment in storeTickets.ticket.assignment_attributes" :key="assignment">
                                <span class="tag is-success">{{assignment.assignable_name}}
                                    <button class="delete is-small" @click="storeAssignments.deleteAssignment(assignment.id)"></button>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket subject -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> 
                        {{translations.main.column_subject}}
                        <span class="is-danger">*</span>
                    </label>
                    
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="subject" class="input" required v-model="storeTickets.ticket.subject">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket deadline -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> {{translations.main.column_deadline}} </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="deadline"  class="input" type="date" v-model="storeTickets.ticket.deadline">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket types -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> 
                        {{translations.main.column_cloud_help_catalog_ticket_types_id}} 
                        <span class="is-danger">*</span>
                    </label>

                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-select
                                :options="storeTickets.options.types"
                                v-model="storeTickets.ticket.cloud_help_catalog_ticket_types_id"
                            >
                            </lesli-select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket category -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> {{translations.main.column_cloud_help_catalog_ticket_categories_id}} </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-select
                                v-if="storeTickets.options.categories"
                                :options="storeTickets.options.categories"
                                v-model="storeTickets.ticket.cloud_help_catalog_ticket_categories_id"
                            ></lesli-select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket priority -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> {{translations.main.column_cloud_help_catalog_ticket_priorities_id}} </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-select
                                v-if="storeTickets.options.priorities"
                                :options="storeTickets.options.priorities"
                                v-model="storeTickets.ticket.cloud_help_catalog_ticket_priorities_id"
                            ></lesli-select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket tags -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label">{{translations.main.column_tags}}</label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-input-tag 
                                v-model="storeTickets.tags"
                                placeholder="tags"
                                :options="[ 
                                    {
                                        name: 'Bug'
                                    },
                                    {
                                        name: 'Report'
                                    },
                                    {
                                        name: 'Performance'
                                    }
                                ]"
                                :filterFields="['name']"
                                showField="name"
                            />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket hours worked -->
            <div class="field is-horizontal" v-if="isEditable">
                <div class="field-label is-normal">
                    <label class="label">{{translations.main.column_hours_worked}}</label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="Hours_worked" class="input" type="number" v-model="storeTickets.ticket.hours_worked">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ticket description -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label">{{translations.main.column_description}}</label>
                </div>

                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <editor-rich-text mode="small" v-model="storeTickets.ticket.description">
                            </editor-rich-text>
                        </div>
                    </div>
                </div>

            </div>

            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"></label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-button icon="save">
                                {{ translations.shared.view_btn_save }}
                            </lesli-button>                 
                        </div>
                    </div>
                </div>
            </div>

        </fieldset>
        
    </form>

</template>
