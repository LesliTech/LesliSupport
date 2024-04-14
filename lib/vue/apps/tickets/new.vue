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
import { onMounted, inject } from "vue"
import { useRouter } from "vue-router"
import { useLesliMsg } from "/Users/ldonis/code/Lesli/lesli-vue/source/composables/msg/msg.js"

const msg = useLesliMsg()


// . 
const url = inject("url")


// . import components
import formTicket from "./components/form.vue"


// · import lesli stores
import { useTickets } from "LesliSupport/vue/stores/tickets"


// · initialize/inject plugins
const router = useRouter()


// · implement stores
const storeTickets = useTickets()


//·
const translations = {
    lesli: i18n.t("lesli"),
    tickets: i18n.t("lesli_support.tickets"),
}

</script>
<template>
    <lesli-application-container>
        <lesli-header title="Create new ticket">
            <lesli-button :to="url.support('list')" icon="list">
                {{ translations.lesli.shared.button_list }}
            </lesli-button>
        </lesli-header>
        <form-ticket editable></form-ticket>
    </lesli-application-container>
</template>
