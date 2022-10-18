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

// · import vue router composable
import { useRouter, useRoute } from "vue-router"

// · implement stores
const storeTickets = useTickets()
const storeAssignments = useAssignments()

// · initialize/inject plugins
const router = useRouter()
const url = inject("url")
const route = useRoute()

// · defining props
const props = defineProps({
    isEditable: {
        type: Boolean,
        required: false,
        default: false,
    },
})

// · 
const translations = {
    users: I18n.t("core.users"),
    shared: I18n.t("core.shared")
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
    router.push(url.help('tickets').toString())
}


onMounted(() => {
    if (props.isEditable){
        storeTickets.fetchTicket(route.params?.id)
    } else {
        storeTickets.resetTicketStore()
    }
    storeTickets.getOptions()
})

</script>
<template>
    <div class="box">
        <form class="information" @submit.prevent="
                isEditable
                    ? onUpdate()
                    : onCreate()
        ">
            <div class="field is-horizontal">
                <div class="field-label">
                    <label class="label"> Workspace </label>
                </div>
                <div class="field-body">
                    <div class="field is-narrow">
                        <div class="control">
                            <lesli-select
                                v-if="!storeTickets.loading"
                                :options="storeTickets.options.workspaces"
                                v-model="storeTickets.ticket.cloud_help_catalog_ticket_workspaces_id"
                            ></lesli-select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="field is-horizontal" v-if="isEditable">
                <div class="field-label is-normal">
                    <label class="label"> 
                        Creator
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

            <div class="field is-horizontal" v-if="isEditable">
                <div class="field-label is-normal">
                    <label class="label"> 
                        Reference URL
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

            <div class="field is-horizontal" v-if="isEditable">
                <div class="field-label is-normal">
                    <label class="label"> Assigned users </label>
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

            <div class="field is-horizontal" v-if="isEditable">
                <div class="field-label is-normal">
                    <label class="label"> Assign myself</label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input type="checkbox" v-model="record.checked" @input="submitAssignment(record)">
                        </div>
                    </div>
                </div>
            </div>

            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> 
                        Subject
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

            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> Deadline </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="deadline"  class="input" type="date" v-model="storeTickets.ticket.deadline">
                        </div>
                    </div>
                </div>
            </div>

            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> 
                        Type 
                        <span class="is-danger">*</span>
                    </label>

                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-select
                                v-if="!storeTickets.loading"
                                :options="storeTickets.options.types"
                                v-model="storeTickets.ticket.cloud_help_catalog_ticket_types_id"
                            >
                            </lesli-select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> Category </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-select
                                v-if="!storeTickets.loading"
                                :options="storeTickets.options.categories"
                                v-model="storeTickets.ticket.cloud_help_catalog_ticket_categories_id"
                            ></lesli-select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> Priority </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-select
                                v-if="!storeTickets.loading"
                                :options="storeTickets.options.priorities"
                                v-model="storeTickets.ticket.cloud_help_catalog_ticket_priorities_id"
                            ></lesli-select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> Tags </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="tags"  class="input" v-model="storeTickets.ticket.tags">
                        </div>
                    </div>
                </div>
            </div>

            <div class="field is-horizontal" v-if="isEditable">
                <div class="field-label is-normal">
                    <label class="label"> Hour worked </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="Hours word" class="input" type="number" v-model="storeTickets.ticket.hours_worked">
                        </div>
                    </div>
                </div>
            </div>


            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> Description </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="description"  class="input" v-model="storeTickets.ticket.description">
                        </div>
                    </div>
                </div>
            </div>

            <div class="field is-horizontal">
                <div class="field-label is-normal">
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

        </form>
    </div>

</template>
