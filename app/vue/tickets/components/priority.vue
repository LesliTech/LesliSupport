<script>
export default {
    props: ['ticket_id', 'ticket_priority', 'options'],
    data() {
        return {
            priority: null,
            ticket_priorities: []
        }
    },
    methods: {
        patchTicket() {
            this.http.patch(`/help/tickets/${this.ticket_id}`, {
                ticket: {
                    detail_attributes: {
                        id: this.ticket_id,
                        cloud_help_ticket_priorities_id: this.priority
                    }
                }
            }).then(result => {
                if (result.successful) {
                    this.alert("Priority succesfuly updated")
                }
            }).catch(error => {
                console.log(error)
            })
        }
    },
    watch: {
        ticket_priority(ticket_priority) {
            this.priority = ticket_priority
        },
        options(options) {
            this.ticket_priorities = options
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <h4 class="card-header-title">
                Priority 
            </h4>
        </div>
        <div class="card-content">
            <div class="control is-expanded">
                <div class="select is-fullwidth">
                    <select 
                        @change="patchTicket" 
                        v-model="priority">
                        <option 
                            v-for="(option, index) in ticket_priorities"
                            :key="index" 
                            :value="option.id">
                            {{ option.name }}
                        </option>
                    </select>
                </div>
            </div>
        </div>
    </div>        
</template>
