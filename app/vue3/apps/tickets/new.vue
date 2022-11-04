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
import formTicket from './components/ticket-form.vue'

// · import lesli stores
import { useTickets } from "CloudHelp/stores/tickets/tickets"

// · initialize/inject plugins
const router = useRouter()

// · implement stores
const storeTickets = useTickets()

//·
const translations = {
    main: I18n.t('help.tickets'),
    core: {
        shared: I18n.t('core.shared')
    }
}

const props = defineProps({
    appMountPath: {
        type: String,
        required: false,
        default: "help/tickets",
    }
})

// · initializing
storeTickets.getOptions()

</script>
<template>
    <section class="application-component">

        <lesli-header :title="translations.main.view_title_main">
            <lesli-button :to="url.root(props.appMountPath)" icon="list">
                {{translations.core.shared.view_btn_list}}
            </lesli-button>
        </lesli-header>
        <form-ticket></form-ticket>

    </section>
</template>
