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
import componentActivity from 'LesliCoreVue/cloud_objects/activity-simple.vue'

export default {
    props: {
        ticketId: {
            required: true
        }
    },

    data(){
        return {
            translations: {
                core: I18n.t('core.shared')
            }
        }
    },

    components: {
        'component-activity': componentActivity
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <div class="card-header-title is-shadowless">
                <h4 class=" title is-4">
                {{translations.core.view_btn_activities}}
                </h4>
            </div>
        </div>
        <div class="card-content is-paddingless activities">
            <component-activity cloud-module="help/ticket" :cloud-id="ticketId"></component-activity>
        </div>
    </div>
</template>
