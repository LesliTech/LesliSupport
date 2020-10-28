<script>
/*
Copyright (c) 2020, Lesli Technologies, S. A.

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

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description App that allows the user to create a new Ticket category

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentForm from '../components/form.vue'


export default {
    components: {
        'component-form': componentForm
    },

    data(){
        return {
            translations: {
                main: I18n.t('help.catalog/ticket_categories')
            },
            index_abilities: this.abilities.privilege('catalog/ticket_categories', 'cloud_help')
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header 
            :title="translations.main.view_title_main"
        >
            <div class="buttons">
                <router-link class="button" tag="button" to="/new" v-if="index_abilities.grant_create">
                    <b-icon icon="plus" size="is-small" />
                    <span>{{ translations.main.view_btn_create }}</span>
                </router-link>
            </div>
        </component-header>
        <component-form view-type="edit"></component-form>
    </section>
</template>
