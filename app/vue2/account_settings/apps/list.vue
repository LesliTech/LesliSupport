<script>
/*
Copyright (c) 2021, all rights reserved.

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


// ·
import componentFormSettingsTab from '../components/form-settings-tab.vue'

// ·
export default {
    components: {
        'component-form-settings-tab': componentFormSettingsTab,
    },

    data() {
        return {
            loading: false,
            translations: {
                core: {
                    shared: I18n.t('core.shared'),
                },
                account: {
                    settings: I18n.t('help.account/settings'),
                }
            }
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="translations.account.settings.view_title_account_settings"></component-header>
        <component-data-loading v-if="loading"></component-data-loading>
        <b-tabs v-else>
            <b-tab-item>
                <template v-slot:header>
                    <b-icon size="is-small" icon="ticket-alt">
                    </b-icon>
                    <span>{{translations.account.settings.view_tab_title_tickets}}</span>
                </template>
                <component-form-settings-tab settings-group="tickets"></component-form-settings-tab>
            </b-tab-item>
        </b-tabs>
    </section>
</template>
