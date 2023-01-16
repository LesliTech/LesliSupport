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
import { onMounted, inject } from "vue"
import { useRouter } from 'vue-router'


// · import lesli stores
import { useSettings } from "CloudHelp/stores/settings"

// . import components
import settingsForm from "./components/settings-form.vue"

// · initialize/inject plugins
const router = useRouter()

// · implement stores
const storeSettings = useSettings()

//·
const translations = {
    core: {
        shared: I18n.t('core.shared'),
    },
    account: {
        settings: I18n.t('help.account/settings'),
    }
}

// · initializing
onMounted(() => {
    storeSettings.getOptions()
})


</script>
<template>
    <section class="application-component">
        <lesli-header :title="translations.account.settings.view_title_account_settings"></lesli-header>
        <div class="box">
            <settings-form></settings-form>
        </div>
    </section>
</template>
