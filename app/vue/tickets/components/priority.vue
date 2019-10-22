<script>
export default {
    data() {
        return {
            ticket_options: {
                priorities: null
            },
            ticket: {
                detail_attributes: {
                    cloud_help_ticket_priorities_id: null
                }
            }
        }
    },
    methods: {

        putTicketPriorities() {
            
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
                        @change="putTicketPriorities()" 
                        v-model="ticket.detail_attributes.cloud_help_ticket_priorities_id">
                        <option 
                            v-for="(option, index) in ticket_options.priorities"
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
