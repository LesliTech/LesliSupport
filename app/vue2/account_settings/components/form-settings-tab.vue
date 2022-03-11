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
export default {
    props: {
        settingsGroup: {
            type: String,
            required: true
        }
    },

    data() {
        return {
            loading: true,
            submitting: false,
            options: null,
            translations: {
                core: {
                    shared: I18n.t('core.shared'),
                },
                settings: I18n.t('help.account/settings'),
            },
            settings: {}
        }
    },

    mounted() {
        this.getOptions()
        this.getSettings()
    },

    methods: {
        getOptions(){
            let filters = {}
            filters[this.settingsGroup] = true

            let url = this.url.help('settings/options').filters(filters)
            this.loading = true

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.options = result.data
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.loading = false
            })
        },

        getSettings(){
            let filters = {}
            filters[this.settingsGroup] = true

            let url = this.url.help('settings').filters(filters)
            this.loading = true

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.settings = result.data
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.loading = false
            })
        },

        postSettings() {
            let url = this.url.help('settings')
            let data = {
                settings: this.settings
            }
            this.submitting = true

            this.http.post(url, data).then(result => {
                if (result.successful) {
                    this.msg.success(this.translations.settings.messages_success_settings_saved)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.submitting = false
            })
        }
    }

}
</script>
<template>
    <div class="box pr-6 settings-general">
        <div class="py-5 pl-2 pr-2" v-if="options">
            <form class="pr-6 mr-6" @submit.prevent="postSettings()">
                <fieldset :disabled="submitting" class="py-5 pl-2 pr-6 mr-6">
                    <b-field
                        horizontal
                        v-for="setting in settings"
                        :key="setting.id"
                        :message="translations.settings[`view_text_column_setting_${setting.key}_description`]"
                    >
                        <template v-slot:label>
                            {{translations.settings[`column_setting_${setting.key}`]}}
                            <sup v-if="options[setting.key].required" class="has-text-danger">*</sup>
                        </template>
                        <b-select
                            v-if="options[setting.key].type == 'Enum'"
                            :placeholder="translations.core.shared.view_text_select_option"
                            v-model="setting.value"
                            expanded
                        >
                            <option v-for="option in options[setting.key].values" :key="option.value" :value="option.value">
                                {{object_utils.translateEnum(translations.settings, 'column_enum_setting', `${setting.key}_${option.text}`, default_value = option.text)}}
                            </option>
                        </b-select>
                        <b-input
                            v-if="['String', 'Numeric'].includes(options[setting.key].type)"
                            v-model="setting.value"
                            :type="options[setting.key].type == 'String' ? 'text' : 'number'"
                            :step="options[setting.key].step"
                            :min="options[setting.key].min"
                            :max="options[setting.key].max"
                        >
                        </b-input>
                    </b-field>

                    <b-field class="has-text-right">
                        <b-button type="is-primary" native-type="submit">
                            <span v-if="submitting">
                                <b-icon icon="circle-notch" custom-class="fa-spin" size="is-small"></b-icon>
                                <span>{{translations.core.shared.view_btn_saving}}</span>
                            </span>
                            <span v-else>
                                <b-icon icon="save" size="is-small"></b-icon>
                                &nbsp;
                                <span>{{translations.core.shared.view_btn_save}}</span>
                            </span>
                        </b-button>
                    </b-field>
                    
                </fieldset>
            </form>
        </div>
        <component-data-loading v-else>
        </component-data-loading>
    </div>
</template>
