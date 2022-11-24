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
import priorityForm from './components/priority-form.vue'

// · import lesli stores
import { useTicketPriorities } from "CloudHelp/stores/catalog/priorities"

const router = useRouter()

// · implement stores
const storePriorities = useTicketPriorities()

//·
const translations = {
    main: I18n.t('help.catalog/ticket_priorities'),
    core: I18n.t('core.shared')
}

// · initializing


</script>
<template>
    <section class="application-component">
        <lesli-header :title="translations.main.view_title_new">
            <lesli-button :to="url.help('catalog/ticket_priorities')" icon="list">
                {{translations.core.view_btn_list}}
            </lesli-button>
        </lesli-header>
        <priority-form></priority-form>
    </section>
</template>
