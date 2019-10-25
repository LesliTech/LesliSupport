<script>
export default {
    props: {
        ticket: {
            required: true
        }
    },
    data() {
        return {
            tags: null
        }
    },
    mounted() {
        this.tags = this.ticket.detail_attributes.tags.split(',')
    },
    methods: {
        patchTicket() {
            this.http.patch(`/help/tickets/${this.ticket.id}`, {
                ticket: {
                    detail_attributes: {
                        id: this.ticket.id,
                        tags: this.tags.join(',')
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
        tags(database_tags, current_tags) {
            // current tags are null on the first load
            // through this way we can avoid to send tags on the very first load
            if (current_tags) {
                this.patchTicket()
            }
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <h4 class="card-header-title">
                Tags
            </h4>
        </div>
        <div class="card-content">
            <b-taginput
                v-model="tags"
                ellipsis>
            </b-taginput>
        </div>
    </div>
</template>
