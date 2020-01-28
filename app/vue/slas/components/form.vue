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



// · Import modules, components and apps
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentRichTextEditor from 'LesliCoreVue/components/forms/rich-text-editor.vue'


export default {
    components: {
        'component-rich-text-editor': componentRichTextEditor
    },
    data() {
        return {
            translations: {
                form: I18n.t('cloud_help.slas.form'),
                shared: I18n.t('cloud_help.slas.shared'),
            },
            sla_id: null,
            sla: { }
        }
    },
    mounted() {
        this.setSlaId()
    },
    methods: {

        setSlaId(){
            if (this.$route.params.id) {
                this.sla_id = this.$route.params.id
                this.getSla()
            }
        },

        submitSla(event){
            if (event) { event.preventDefault() }
            if(this.sla_id){
                this.putSla()
            }else{
                this.postSla()
            }
        },

        putSla() {
            this.http.put(`/help/slas/${this.sla_id}`, {
                sla: this.sla
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.form.messages.update.successful,'success')
                    this.$router.push(`/${this.sla_id}`)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        postSla() {
            this.http.post("/help/slas", {
                sla: this.sla
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.form.messages.create.successful,'success')
                    this.$router.push(`/${result.data.id}`)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        getSla() {
            this.http.get(`/help/slas/${this.sla_id}.json`).then(result => {
                if (result.successful) {
                    this.sla = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }

    }
}
</script>
<template>
    <section>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    {{translations.shared.name}}
                </h2>
                <div class="card-header-icon">
                    <router-link v-if="sla_id" :to="`/${sla_id}`">
                        <i class="fas fa-eye"></i>
                        {{translations.shared.actions.show}}
                    </router-link>
                    <router-link :to="`/`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        {{translations.shared.actions.return}}
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <form @submit="submitSla">
                    <div class="columns">
                        <div class="column is-5">
                            <b-field :label="translations.shared.fields.name">
                                <b-input v-model="sla.name" required="true"></b-input>
                            </b-field>
                        </div>
                        <div class="column is-3">
                            <b-field :label="translations.shared.fields.expected_response_time">
                                <b-input v-model="sla.expected_response_time" type="number" min="0" required="true"></b-input>
                            </b-field>
                        </div>
                        <div class="column is-3">
                            <b-field :label="translations.shared.fields.expected_resolution_time">
                                <b-input v-model="sla.expected_resolution_time" type="number" min="0" required="true"></b-input>
                            </b-field>
                        </div>
                        <div class="column is-1">
                            <div class="field">
                                <label class="label is-w-100">{{translations.shared.fields.default_sla}}</label>
                                <div class="has-text-centered">
                                    <input id="sla_default" class="is-checkradio" type="checkbox" v-model="sla.default">
                                    <label for="sla_default"></label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <b-field :label="translations.shared.fields.body">
                        <component-rich-text-editor v-model="sla.body" />
                    </b-field>
                    <b-field :label="translations.shared.fields.provider_repercussions">
                        <component-rich-text-editor v-model="sla.provider_repercussions" />
                    </b-field>
                    <b-field :label="translations.shared.fields.exceptions">
                        <component-rich-text-editor v-model="sla.exceptions" />
                    </b-field>
                    <div class="columns">
                        <div v-if="sla_id" class="column">
                            <div class="field">
                                <small>
                                    <span class="has-text-weight-bold">
                                        {{ `${translations.shared.fields.created_at}:` }}
                                    </span>
                                    {{ date.toLocalFormat(sla.created_at,false,true) }}
                                    <br>
                                    <span class="has-text-weight-bold">
                                        {{ `${translations.shared.fields.updated_at}:` }}
                                    </span>
                                    {{ date.toLocalFormat(sla.updated_at,false,true) }}
                                </small>
                            </div>
                        </div>
                        <div class="column">
                            <div class="field">
                                <div class="actions has-text-right">
                                    <button class="button is-primary" type="submit">
                                        <span v-if="sla_id">{{translations.form.actions.update}}</span>
                                        <span v-else>{{translations.form.actions.create}}</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</template>
<style scoped>
    .is-w-100{
        width: 100%;
    }
</style>
