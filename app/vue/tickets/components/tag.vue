<script>
export default {
    props: {
        ticket: {
            required: true
        }
    },
    data() {
        return {
            translations: I18n.t('cloud_help.tickets.tag'), 
            tags: null
        }
    },
    mounted() {
        this.setTags()
    },
    methods: {
        setTags(){
            if (this.ticket && this.ticket.detail_attributes.tags) {
                this.tags = this.ticket.detail_attributes.tags.split(',')
            }
        },

        patchTicket() {
            this.http.patch(`/help/tickets/${this.ticket.id}`, {
                ticket: {
                    detail_attributes: {
                        tags: this.tags.join(',')
                    }
                }
            }).then(result => {
                if (result.successful) {
                    this.alert(this.translations.messages.update.successful)
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }
    },
    watch: {
        ticket(){
            this.setTags()
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <h4 class="card-header-title">
                {{translations.title}}
            </h4>
        </div>
        <div class="card-content">
            <b-taginput v-model="tags" ellipsis @input="patchTicket" />
        </div>
    </div>
</template>
