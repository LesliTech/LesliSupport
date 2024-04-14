<script setup>
/*
Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · import vue tools
import { inject, onMounted, ref, onUnmounted } from "vue"


// · import vue router composable
import { useRouter, useRoute } from "vue-router"


// · initialize/inject plugins
const router = useRouter()
const route = useRoute()
const date = inject("date")
const url = inject("url")


// · 
import { LesliTextEditor } from "lesli-vue/components"


// · import lesli stores
import { useTickets } from "LesliSupport/vue/stores/tickets"
//import { useAssignments } from "LesliSupport/stores/tickets/assignment"


// · implement stores
const storeTickets = useTickets()
//const storeAssignments = useAssignments()


// · defining props
const props = defineProps({
    editable: {
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
    tickets: i18n.t("lesli_support.tickets"),
    lesli: { shared: i18n.t("lesli.shared") },

    users: I18n.t("core.users"),
    shared: I18n.t("core.shared"),
    main: I18n.t('help.tickets')
}


// · 
function onUpdate() {
    console.log("update")
    storeTickets.updateTicket()
}


// · 
const onCreate = () => {
    console.log("create")
    storeTickets.postTicket().then(result => {
        //this.msg.success(I18n.t("core.users.messages_success_operation"))
        router.push(url.support('tickets/:id', result.id).toString())
    }).catch(error => {
        this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
    })
}


// · 
onMounted(() => {

    if (route.params.id) {
        storeTickets.fetchTicket(route.params.id)
    }

    storeTickets.getOptions()
    // storeTickets.ticket = {}
    // storeTickets.tags = []
})
</script>
<template>
    <lesli-form 
        :editable="props.editable"
        @submit="route.params.id ? onUpdate() : onCreate()"
        disabled="storeTickets.ticket.status=='closed'">

        <!-- Ticket subject -->
        <div class="field" v-if="props.editable">
            <label class="label">
                {{ translations.tickets.column_subject }}
                <span class="is-danger">*</span>
            </label>
            <div class="control">
                <input name="subject" class="input" required v-model="storeTickets.ticket.subject">
            </div>
        </div>

        <fieldset v-if="route.params.id">
            <legend></legend>
        
            <!-- Ticket creator name -->
            <div class="field">
                <label class="label">ID</label>
                <div class="control">
                    <input class="input" disabled  v-model="storeTickets.ticket.id">
                </div>
            </div>

            <!-- Ticket reference url -->
            <div class="field" v-if="!props.editable">
                <label class="label">Reference URL</label>
                <div class="control">
                    <input name="reference_url" disabled type="text" class="input" v-model="storeTickets.ticket.reference_url">
                </div>
            </div>

            <!-- Ticket workspace -->
            <div class="field">
                <label class="label">Workspace</label>
                <div class="control">
                    <lesli-select
                        v-if="storeTickets.options.workspaces"
                        :options="storeTickets.options.workspaces"
                        v-model="storeTickets.ticket.catalog_workspace_id">
                    </lesli-select>
                </div>
            </div>
        </fieldset>

        <!-- Ticket assigned users 
        <div class="field" v-if="route.params.id">
            <label class="label">Assigned users</label>
            <div class="control">
                <div v-for="assignment in storeTickets.ticket.assignment_attributes" :key="assignment">
                    <span class="tag is-success">{{assignment.assignable_name}}
                        <button class="delete is-small" @click="storeAssignments.deleteAssignment(assignment.id)" type="button"></button>
                    </span>
                </div>
            </div>
        </div>
        -->

        <fieldset v-if="route.params.id">
            <legend></legend>
            <lesli-columns>

                <!-- Ticket types -->
                <lesli-column>
                    <div class="field">
                        <label class="label">
                            Type
                        </label>
                        <div class="control">
                            <lesli-select
                                :options="storeTickets.options.types"
                                v-model="storeTickets.ticket.catalog_type_id">
                            </lesli-select>
                        </div>
                    </div>
                </lesli-column>

                <!-- Ticket category -->
                <lesli-column>
                    <div class="field">
                        <label class="label">
                            Category
                        </label>
                        <div class="control">
                            <lesli-select
                                v-if="storeTickets.options.categories"
                                :options="storeTickets.options.categories"
                                v-model="storeTickets.ticket.catalog_category_id">
                            </lesli-select>
                        </div>
                    </div>
                </lesli-column>

                <!-- Ticket priority -->
                <lesli-column>
                    <div class="field">
                        <label class="label">
                            Priority
                        </label>
                        <div class="control">
                            <lesli-select
                                v-if="storeTickets.options.priorities"
                                :options="storeTickets.options.priorities"
                                v-model="storeTickets.ticket.catalog_priority_id">
                            </lesli-select>
                        </div>
                    </div>
                </lesli-column>
            </lesli-columns>


            <lesli-columns v-if="route.params.id">

                <!-- Ticket deadline -->
                <lesli-column>
                    <div class="field">
                        <label class="label">
                            Deadline
                        </label>
                        <div class="control">
                            <lesli-calendar mode="dateTime" v-model="storeTickets.ticket.deadline">
                            </lesli-calendar>
                        </div>
                    </div>
                </lesli-column>
            

                <!-- Ticket started at date -->
                <lesli-column>
                    <div class="field">
                        <label class="label">
                            Started At
                        </label>
                        <div class="control">
                            <lesli-calendar v-model="storeTickets.ticket.started_at">
                            </lesli-calendar>
                        </div>
                    </div>
                </lesli-column>

                <!-- Ticket finished at date -->
                <lesli-column>
                    <div class="field">
                        <label class="label">
                            Completed at
                        </label>
                        <div class="control">
                            <lesli-calendar v-model="storeTickets.ticket.completed_at">
                            </lesli-calendar>
                        </div>
                    </div>
                </lesli-column>
            </lesli-columns>
        </fieldset>

        <!-- Ticket hours worked -->
        <div class="field" v-if="route.params.id">
            <label class="label">
                Hours worked
            </label>
            <div class="control">
                <input name="Hours_worked" class="input" type="number" step="any" v-model="storeTickets.ticket.hours_worked">
            </div>
        </div>

        <!-- Ticket description -->
        <div class="field">
            <label class="label">
                Description
            </label>
            <div class="control">
                <lesli-text-editor :editable="props.editable" mode="normal" v-model="storeTickets.ticket.description">
                </lesli-text-editor>
            </div>
        </div>


        <div class="field">
            <label class="label"></label>
            <div class="control">
                <lesli-button icon="save">
                    {{ translations.lesli.shared.button_save }}
                </lesli-button>
            </div>
        </div>
    </lesli-form>
</template>
