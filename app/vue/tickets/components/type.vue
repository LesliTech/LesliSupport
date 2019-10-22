<script>
export default {
    data() {
        return {
            ticket_options: {
                types: []
            },
            ticket: {
                detail_attributes: {
                    cloud_help_ticket_types_id: null
                }
            }
        }
    },
    methods: {
        patchTicketType() {

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
                        @change="putTicketType()" 
                        v-model="ticket.detail_attributes.cloud_help_ticket_types_id">
                        <option 
                            v-for="(option, index) in ticket_options.types"
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
