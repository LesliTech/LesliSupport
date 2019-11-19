<script>
/*
Lesli

Copyright (c) 2019, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@dev      Carlos Hermosilla
@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/
export default {
    data() {
        return {
            translations: I18n.t('cloud_help.ticket_states.shared')
        }
    },
    props: {
        name: {
            type: String,
            default: ''
        },
        initial: {
            type: Boolean,
            default: false
        },
        final: {
            type: Boolean,
            default: false
        }
    }
}
</script>
<template>
    <span v-if="initial || final">
        {{translations.default.names[name]}}
        <span v-if="initial">
            ({{translations.default.types.initial}})
        </span>
        <span v-else>
            ({{translations.default.types.final}})
        </span>
    </span>
    <span v-else>
        {{name}}
    </span>
</template>
