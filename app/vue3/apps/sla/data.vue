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
import { useTickets } from "CloudHelp/stores/slas/sla"

// · import vue router composable
import { useRouter, useRoute } from "vue-router"

// · implement stores
const storeSla = useSlas()

// · initialize/inject plugins
const router = useRouter()
const url = inject("url")
const route = useRoute()

// · 
const translations = {
    users: I18n.t("core.users"),
    shared: I18n.t("core.shared")
}

/**
 * @description This function is used to update the user information
 */
 const onUpdate = () => {


}

/**
 * @description This function is used to create a new user
 */
const onCreate = () => {

}



onMounted(() => {

})

</script>
<template>
    <div class="box">
        <form class="information" @submit.prevent="
                isEditable
                    ? onUpdate()
                    : onCreate()
        ">
            

        </form>
    </div>

</template>
