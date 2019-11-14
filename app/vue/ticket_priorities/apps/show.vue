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


// · Component list
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentForm from '../components/form.vue'


export default {
    data() {
        return {
            translations: I18n.t('cloud_help.ticket_priorities.shared'),
            ticket_priority: {},
            ticket_priority_id: null
        }
    },
    components: {
        'component-form': componentForm
    },
    mounted() {
        // · SetTicketPriorityId calls getTicketPriority
        this.setTicketPriorityId()
    },
    methods: {
        
        setTicketPriorityId(){
            if (this.$route.params.id) {
                this.ticket_priority_id = this.$route.params.id
                this.getTicketPriority()
            }
        },

        getTicketPriority() {
            this.http.get(`/help/api/ticket_priorities/${this.ticket_priority_id}`).then(result => {
                if (result.successful) {
                    this.ticket_priority = result.data
                }else{
                    this.alert(result.error,'danger')
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
                    Ticket Priority
                </h2>
                <div class="card-header-icon">
                    <router-link :to="`/${ticket_priority_id}/edit`">
                        <i class="fas fa-edit"></i>
                        Edit Priority
                    </router-link>
                    <router-link :to="`/`">
                        &nbsp;&nbsp;&nbsp;
                        <i class="fas fa-undo"></i>
                        Return
                    </router-link>
                </div>
            </div>
            <div class="card-content">
                <form>
                    <div class="columns">
                        <div class="column">
                            <p>
                                <span class="has-text-weight-bold">
                                    {{ `${translations.fields.name}:` }}
                                </span>
                                {{ ticket_priority.name }},
                                <span class="has-text-weight-bold">
                                    {{ `${translations.fields.weight}:` }}
                                </span>
                                {{ ticket_priority.weight }}
                            </p>
                        </div>
                    </div>
                    <div class="columns">
                        <div class="column">
                            <small>
                                <span class="has-text-weight-bold">
                                    {{ `${translations.fields.created_at}:` }}
                                </span>
                                {{ ticket_priority.created_at }}
                                <br>
                                <span class="has-text-weight-bold">
                                    {{ `${translations.fields.updated_at}:` }}
                                </span>
                                {{ ticket_priority.updated_at }}
                            </small>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</template>
