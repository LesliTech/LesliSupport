<script>
export default {
    data() {
        return {
            ticket: {
                detail_attributes: {
                    subject: ""
                }
            }
        }
    },
    methods: {

        postTicket(e) {

            e.preventDefault()

            this.http.post("/help/tickets", {
                ticket: this.ticket
            }).then(result => {
                console.log(result)
            }).catch(error => {
                console.log(error)
            })

        }

    }
}
</script>
<template>
    <section class="section">
        <div class="card">
            <div class="card-header">
                <div class="card-header-title">
                    Create new ticket
                </div>
            </div>
            <div class="card-content">
                <form>
                    <b-field label="Subject">
                        <b-input v-model="ticket.detail_attributes.subject"></b-input>
                    </b-field>
                    <div class="field">
                        <button class="button is-primary" @click="postTicket">
                            Create ticket
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </section>
</template>
