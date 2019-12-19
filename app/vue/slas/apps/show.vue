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
            translations: {
                show: I18n.t('cloud_help.slas.show'),
                shared: I18n.t('cloud_help.slas.shared'),
            },
            sla: {},
            sla_id: null,
            modal:{
                active: false
            }
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
        },

        deleteSla(){
            this.modal.active = false
            this.http.delete(`/help/slas/${this.sla_id}`).then(result => {
                if(result.successful){
                    this.alert(this.translations.show.messages.delete.successful,'success')
                    this.$router.push('/')
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
        <b-modal 
            :active.sync="modal.active"
            has-modal-card
            trap-focus
            aria-role="dialog"
            aria-modal
        >
            <div class="card">
                <div class="card-header is-danger">
                    <h2 class="card-header-title">
                        {{ translations.show.modal.title }}
                    </h2>
                </div>
                <div class="card-content">
                    {{ translations.show.modal.body }}
                </div>
                <div class="card-footer has-text-right">
                    <button class="card-footer-item button is-danger" @click="deleteSla">
                        {{ translations.show.modal.actions.delete }}
                    </button>
                    <button class="card-footer-item button is-secondary" @click="modal.active=false">
                        {{ translations.show.modal.actions.cancel }}
                    </button>
                </div>
            </div>
        </b-modal>
        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    {{ translations.shared.name }}
                </h2>
                <div class="card-header-icon">
                    <router-link :to="`/${sla_id}/edit`">
                        <i class="fas fa-edit"></i>
                        {{ translations.shared.actions.edit }}
                    </router-link>
                    <router-link :to="`/`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        {{ translations.shared.actions.return }}
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <div class="columns">
                    <div class="column">
                        <div>
                            <span class="has-text-weight-bold">
                                {{translations.shared.fields.id}}:
                                {{ sla.id }}
                            </span>
                            <br>
                            <span class="has-text-weight-bold">
                                {{translations.shared.fields.name}}:
                            </span>
                            {{ sla.name }}
                            <br>
                            <span class="has-text-weight-bold">
                                {{translations.shared.fields.expected_response_time}}:
                                <span class="has-text-danger">
                                    {{ sla.expected_response_time }}
                                </span>
                            </span>,
                            <span class="has-text-weight-bold">
                                {{translations.shared.fields.expected_resolution_time}}:
                                <span class="has-text-danger">
                                    {{ sla.expected_resolution_time }}
                                </span>
                            </span>
                        </div>
                        <hr>
                        <div>
                            <span class="has-text-weight-bold">
                                {{translations.shared.fields.body}}:
                            </span>
                            <p class="segment" v-html="sla.body">
                            </p>
                        </div>
                        <hr>
                        <div>
                            <span class="has-text-weight-bold">
                                {{translations.shared.fields.provider_repercussions}}:
                            </span>
                            <p class="segment" v-html="sla.provider_repercussions">
                            </p>
                        </div>
                        <hr>
                        <div>
                            <span class="has-text-weight-bold">
                                {{translations.shared.fields.exceptions}}:
                            </span>
                            <p class="segment" v-html="sla.exceptions">
                            </p>
                        </div>
                    </div>
                </div>
                <div class="columns">
                    <div class="column">
                        <small>
                            <span class="has-text-weight-bold">
                                {{ translations.shared.fields.created_at }}:
                            </span>
                            {{ date.toLocalFormat(sla.created_at,false,true) }}
                            <br>
                            <span class="has-text-weight-bold">
                                {{ translations.shared.fields.updated_at }}:
                            </span>
                            {{ date.toLocalFormat(sla.updated_at,false,true) }}
                        </small>
                    </div>
                    <div class="column">
                        <div class="field">
                            <div class="actions has-text-right">
                                <button class="button is-danger" @click="modal.active = true">
                                    {{ translations.shared.actions.delete }}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>
<style>
    .segment ol{
        padding-left: 2%;
    }
    .segment div{
        text-align: justify;
    }
</style>
