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

// · import vue router composable
import { useRouter, useRoute } from "vue-router"

// · import lesli stores
import { useTicketTypes } from "CloudHelp/stores/catalog/types"


// · implement stores
const storeTypes = useTicketTypes()

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
    }
})

// · 
const translations = {
    main: I18n.t('help.catalog/ticket_types'),
    core: I18n.t('core.shared'),
    shared: I18n.t('help.shared')
}

/**
 * @description This function is used to update the ticket type information
 */
const onUpdate = () => {
    storeTypes.updateTicketType()
}

/**
 * @description This function is used to create a new ticket type
 */
const onCreate = () => {
    storeTypes.postTicketType().then(() => {
        router.push(url.help('catalog/ticket_types').toString())
    })
}

/**
 * Checking if the form is for a new ticket type or for editing existing one
*/
if (props.isEditable){
    storeTypes.type = {}
    storeTypes.getType(route.params.id)
} else {
    storeTypes.type = {}
}

</script>
<template>
    <form class="information"
        v-if="!storeTypes.loading"
        @submit.prevent="isEditable ? onUpdate() : onCreate()"
    >
        <fieldset>
            <!-- Ticket type name -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"> 
                        {{translations.main.column_name}}
                    </label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <input class="input" v-model="storeTypes.type.name" required>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Save button -->
            <div class="field is-horizontal">
                <div class="field-label is-normal">
                    <label class="label"></label>
                </div>
                <div class="field-body">
                    <div class="field">
                        <div class="control">
                            <lesli-button icon="save">
                                {{ translations.core.view_btn_save }}
                            </lesli-button>                 
                        </div>
                    </div>
                </div>
            </div>

        </fieldset>
        
    </form>

</template>
