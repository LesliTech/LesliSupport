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
export default {
    props: {
        ticketDeadline: {
            type: String,
            default: null
        }
    },
    
    data() {
        return {
            show: false,
            ticket_id: null,
            translations: I18n.t('cloud_help.tickets.deadline'),
            deadline: null
        }
    },
    
    mounted(){
        this.bus.subscribe("show:/help/ticket/deadline", () => this.show = !this.show )
        this.ticket_id = this.$route.params.id
        this.setTicketDeadline()
    },

    methods: {
        putTicketDeadline(){
            let deadline = this.deadline.toISOString()
            let data = {
                ticket: {
                    detail_attributes: {
                        deadline: deadline
                    }
                }
            }
            this.show = false
            this.http.patch( `/help/tickets/${this.ticket_id}.json`, data).then(result => {
                if (result.successful) {
                    this.msg.success(this.translations.messages.put_deadline.successful)
                    this.bus.publish("patch:/help/ticket/deadline", deadline)
                } else {
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        setTicketDeadline(){
            if(this.ticketDeadline){
                this.deadline = new Date(this.ticketDeadline)
            }
        }
    },

    watch: {
        ticketDeadline(){
            this.setTicketDeadline()
        }
    }
}
</script>
<template>
    <section>
        <div :class="[{ 'is-active': show }, 'quickview']">
            <header class="quickview-header" @click="show = false">
                <p class="title">
                    {{translations.title}}
                </p>
                <i class="fas fa-chevron-right clickable"></i>
            </header>
            <div class="quickview-body">
                <div class="quickview-block">
                    <div class="section">
                        <b-field :label="translations.labels.select_date">
                            <b-datetimepicker
                                v-model="deadline"
                                inline
                                class="has-text-centered"
                                size="is-small"
                                icon="calendar-day"
                                :min-datetime="new Date()"
                            />
                        </b-field>
                        <hr>
                        <b-field>
                            <b-button class="card-footer-item button is-primary" @click="putTicketDeadline" expanded>
                                {{translations.actions.put_deadline}}
                            </b-button>
                        </b-field>
                    </div>
                </div>
            </div>
            <footer class="quickview-footer">
            </footer>
        </div>
    </section>
</template>
<style scoped>
.clickable{
    cursor: pointer;
}
</style>
