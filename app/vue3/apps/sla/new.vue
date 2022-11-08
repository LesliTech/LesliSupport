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
import { onMounted } from "vue"
import { useRouter } from 'vue-router'

// . import components
import slaForm from './components/sla-form.vue'

// · import lesli stores
import { useSlas } from "CloudHelp/stores/sla"

const router = useRouter()

// · implement stores
const storeSla = useSlas()

//·
const translations = {
    main: I18n.t('help.slas'),
    core: I18n.t('core.shared')
}

const props = defineProps({
    appMountPath: {
        type: String,
        required: false,
        default: "help/tickets",
    }
})

// · initializing

</script>
<template>
    <section class="application-component">

        <lesli-header :title="translations.main.view_title_main">
            <lesli-button :to="url.help('slas')" icon="list">
                {{translations.core.view_btn_list}}
            </lesli-button>
        </lesli-header>
        <sla-form></sla-form>

    </section>
</template>
