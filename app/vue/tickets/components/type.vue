<script>
export default {
    props: ['ticket_id', 'ticket_type', 'options'],
    data() {
        return {
            type: null,
            ticket_types: []
        }
    },
    methods: {
        patchTicket() {
            this.http.patch(`/help/tickets/${this.ticket_id}`, {
                ticket: {
                    detail_attributes: {
                        id: this.ticket_id,
                        cloud_help_ticket_types_id: this.type
                    }
                }
            }).then(result => {
                if (result.successful) {
                    this.alert("Tags succesfuly updated")
                }
            }).catch(error => {
                console.log(error)
            })
        }
    },
    watch: {
        ticket_type(ticket_type) {
            this.type = ticket_type
        },
        options(options) {
            this.ticket_types = options
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <h4 class="card-header-title">
                Type
            </h4>
        </div>
        <div class="card-content">
            <div class="control is-expanded">
                <div class="select is-fullwidth">
                    <select 
                        @change="patchTicket()" 
                        v-model="type">
                        <option 
                            v-for="(option, index) in ticket_types"
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
