<script>
/*
Copyright (c) 2020, all rights reserved.

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


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentForm from '../components/form.vue'

export default {
    components: {
        'component-form': componentForm
    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable sla_type [Object] An object representing a Sla type, with
    //      the same params as the associated rails model
    data(){
        return {
            translations: {
                main: I18n.t('help.slas'),
                core: I18n.t('core.shared')
            },
            sla: null,
        }
    },

    mounted(){
        this.initializeSla()
    },

    methods: {
        initializeSla(){
            this.data.slas.sla = null
            this.sla = {
                name: null,
                body: null,
                expected_response_time: 48,
                expected_resolution_time: 120,
                provider_repercussions: null,
                exceptions: null,
                default: false,
                user_main_id: null
            }
            this.$nextTick(()=>{
                this.data.slas.sla = this.sla
            })
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="translations.main.view_title_main" >
            <div class="navbar-item">
                <div class="buttons">
                    <router-link class="button" to="/">
                        <b-icon icon="list" size="is-small" />
                        <span>{{ translations.core.view_btn_list }}</span>
                    </router-link>
                </div>
            </div>
        </component-header>
        <component-form v-if="data.slas.sla" view-type="new"></component-form>
    </section>
</template>
