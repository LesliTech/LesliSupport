<script>
export default {
    props: ['ticket_id', 'ticket_state', 'options'],
    data() {
        return {
            state: null,
            ticket_states: []
        }
    },
    methods: {
        patchTicket() {
            this.http.patch(`/help/tickets/${this.ticket_id}`, {
                ticket: {
                    detail_attributes: {
                        id: this.ticket_id,
                        cloud_help_ticket_states_id: this.state
                    }
                }
            }).then(result => {
                if (result.successful) {
                    this.alert("State succesfuly updated")
                }
            }).catch(error => {
                console.log(error)
            })
        }
    },
    watch: {
        ticket_state(ticket_state) {
            this.state = ticket_state
        },
        options(options) {
            this.ticket_states = options
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <h4 class="card-header-title">
                State 
            </h4>
        </div>
        <div class="card-content">
            <div class="control is-expanded">
                <div class="select is-fullwidth">
                    <select 
                        @change="patchTicket()" 
                        v-model="state">
                        <option 
                            v-for="(option, index) in ticket_states"
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
