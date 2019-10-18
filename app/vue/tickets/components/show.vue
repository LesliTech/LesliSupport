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

@dev      Luis Donis <ldonis@lesli.tech>
@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/



// · Import modules, components and apps
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentAppDiscussions from 'LesliCloud/vue/apps/discussions.vue'
import componentAppActions from 'LesliCloud/vue/apps/actions.vue'



// · Component show
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'component-app-discussions': componentAppDiscussions,
        'component-app-actions': componentAppActions
    },
    data() {
        return {
            ticket_id: null,
            ticket: {},
            test:0
        }
    },
    mounted() {
        this.ticket_id = this.$route.params.id
    },
    methods: {
        getTicket() {
            this.http.get(`/help/tickets/${this.ticket_id}`).then(result => {
                if (result.successful) {
                    this.ticket = result.data
                }
            }).catch(error => {
                console.log(error)
            })
        }
    },
    watch: {
        ticket_id(ticket_id) {
            this.getTicket()
        }
    }
}
</script>
<template>
    <section class="section">
        <div class="columns">
            <div class="column is-8">
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-header-title">
                            {{ ticket.subject }}
                        </h2>
                        <router-link :to="`/${ticket.id}/edit`" class="card-header-icon">
                            edit
                        </router-link>
                    </div>
                    <div class="card-content">
                        <b-field label="">
                            <b-autocomplete
                                :data="['Luis Donis', 'Jorge Santos']"
                                placeholder="Search and assign employee"
                                icon="magnify">
                                <template slot="empty">No results found</template>
                            </b-autocomplete>
                        </b-field>
                    </div>
                    <div class="card-content" v-html="ticket.description">
                    </div>
                </div>
            </div>
            <div class="column is-4">
                <div class="card">
                    <div class="card-header">
                        <h4 class="card-header-title">
                            Open
                        </h4>
                    </div>
                    <div class="card-content">
                        <div class="field">
                            <input class="is-checkradio is-success" type="radio" checked="checked">
                            <label for="">first response due</label>
                            <p>by Thu, 26 Sep 2019, 12:00 PM</p>
                        </div>
                        <div class="field">
                            <input class="is-checkradio" type="radio" checked="checked">
                            <label for="">resolution due</label>
                            <p>by Thu, 26 Sep 2019, 12:00 PM</p>
                        </div>
                    </div>
                </div>
                <br>
                <div class="card">
                    <div class="card-header">
                        <h4 class="card-header-title">
                            Properties
                        </h4>
                    </div>
                    <div class="card-content">
                        <b-field label="Tags">
                            <input type="text" class="input">
                            
                        </b-field>
                        <div class="field">
                            <span class="tag is-link">Tag 1</span>
                            <span class="tag is-link">Tag 2</span>
                            <span class="tag is-link">Tag 3</span>
                            <span class="tag is-link">Tag 4</span>
                        </div>
                        <b-field label="Type">
                            <b-select placeholder="Select a name" expanded>
                                <option v-for="(option, index) in [0,0,0,0,0]" :key="index" :value="index">
                                    type {{ index }}
                                </option>
                            </b-select>
                        </b-field>
                        <b-field label="Status">
                            <b-select placeholder="Select a name" expanded>
                                <option v-for="(option, index) in [0,0,0,0,0]" :key="index" :value="index">
                                    status {{ index }}
                                </option>
                            </b-select>
                        </b-field>
                        <b-field label="Priority">
                            <b-select placeholder="Select a name" expanded>
                                <option v-for="(option, index) in [0,0,0,0,0]" :key="index" :value="index">
                                    priority {{ index }}
                                </option>
                            </b-select>
                        </b-field>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>

