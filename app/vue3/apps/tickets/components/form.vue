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

// · import vue router composable
import { useRouter, useRoute } from "vue-router"

// · implement stores
const storeTickets = useTickets()

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
 * @description This function is used to update the user information
 */
const onUpdate = () => {
    storeTickets.updateTicket()
    // storeUser.updateInformation()
}

/**
 * @description This function is used to create a new user
 */
const onCreate = () => {
    storeTickets.postTicket()
    router.push(url.help('tickets').toString())
}


onMounted(() => {
    if (!props.isEditable){
        storeTickets.resetTicketStore()
    } else {
        storeTickets.fetchTicket(route.params?.id)
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
                            <input name="user_email" type="email" class="input" disabled  v-model="storeTickets.ticket.user_creator_name">
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
                            <input name="first_name"  type="text" class="input">
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
                            <input name="last_name"  class="input">
                        </div>
                    </div>
                </div>
            </div>

            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> Subject </label>
                    <span class="is-danger">*</span>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input name="user_alias"  class="input" required v-model="storeTickets.ticket.subject">
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
                            <input name="user_number"  class="input" type="date" v-model="storeTickets.ticket.deadline">
                        </div>
                    </div>
                </div>
            </div>

            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> Type </label>
                    <span class="is-danger">*</span>
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

            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> Category </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-select
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
                            <input name="user_title"  class="input">
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
                            <input name="user_title" class="input">
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
                            <input name="user_title"  class="input">
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

    <h2>SLA</h2>
    <div class="box"></div>


    <h2>SLA</h2>
    <div class="box"></div>

</template>
