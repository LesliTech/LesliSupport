<script setup>
/*
Copyright (c) 2023, all rights reserved.

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
import { inject, onMounted} from "vue"

// · import lesli stores
import { useSettings } from "CloudHelp/stores/settings"

// · import vue router composable
import { useRouter, useRoute } from "vue-router"

// · implement stores
const storeSettings = useSettings()

// · initialize/inject plugins
const router = useRouter()
const url = inject("url")
const route = useRoute()


// · 
const translations = {
    core: I18n.t('core.shared'),
    shared: I18n.t('help.shared')
}

onMounted(() => {
    storeSettings.getSettings()
})

</script>
<template>
    <form class="information"
        v-if="!storeSettings.loading"
        @submit.prevent="storeSettings.postSettings()"
    >
       
        <div class="columns">
            <div class="column">
                <label class="label">
                    Role assignment
                </label>
                <div class="control">
                    <lesli-select
                        v-if="storeSettings.options"
                        :options="storeSettings.options"
                        v-model="storeSettings.role_assignment.value"
                    ></lesli-select>
                </div>
            </div>

        </div>


        <div class="field is-horizontal is-expanded">
            <div class="field-label is-normal">
            </div>
            <div class="field-body">
                <div class="field">
                    <div class="control">
                        <lesli-button icon="save" :loading="storeSettings.loading">
                            save
                        </lesli-button>                 
                    </div>
                </div>
            </div>
        </div>
    </form>

</template>
