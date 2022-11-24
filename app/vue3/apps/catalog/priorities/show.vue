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
import { onMounted, computed } from "vue"
import { useRouter, useRoute } from 'vue-router'

// . import components
import priorityForm from './components/priority-form.vue'

// · import lesli stores
import { useTicketPriorities } from "CloudHelp/stores/catalog/priorities"

// · initialize/inject plugins
const route = useRoute()
const router = useRouter()

// · implement stores
const storePriorities = useTicketPriorities()

//·
const translations = {
    main: I18n.t('help.catalog/ticket_priorities'),
    core: I18n.t('core.shared')
}


const title = computed(() => `${storePriorities.priority.id} - ${storePriorities.priority.name}`)

/**
 * @description This function is used to delete a priority
 */
const onDelete = () => {
    storePriorities.deletePriority(route.params.id)
    router.push(url.help('catalog/ticket_priorities').toString())
}

// · initializing
onMounted(() => {
    storePriorities.getPriority(route.params.id)
})


</script>
<template>

    <section class="application-component">
        <lesli-header
            :title="title"
        >
            <button class="button is-fullwidth has-text-centered is-danger" @click="onDelete">
                {{translations.core.view_tab_title_delete_section}}
            </button>
            <lesli-button :to="url.help('catalog/ticket_priorities')" icon="list">
                {{translations.main.view_title_main}}
            </lesli-button>
        </lesli-header>
        <priority-form is-editable></priority-form>


    </section>

</template>
