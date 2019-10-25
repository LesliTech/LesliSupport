<script>
export default {
    props: {
        ticket: {
            required: true
        },
        options: {
            required: true
        }
    },
    methods: {
        patchTicket() {
            this.http.patch(`/help/tickets/${this.ticket.id}`, {
                ticket: {
                    detail_attributes: {
                        id: this.ticket.id,
                        cloud_help_ticket_types_id: this.ticket.detail_attributes.cloud_help_ticket_types_id
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
                        @change="patchTicket" 
                        v-model="ticket.detail_attributes.cloud_help_ticket_types_id">
                        <option 
                            v-for="(option, index) in options.types"
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
