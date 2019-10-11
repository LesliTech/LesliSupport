<script>
export default {
    data() {
        return {
            tickets: [],
            columns: [{
                field: 'id',
                label: 'ID',
                width: '40',
                numeric: true
            }, {
                field: 'first_name',
                label: 'First Name',
            }, {
                field: 'last_name',
                label: 'Last Name',
            }, {
                field: 'date',
                label: 'Date',
                centered: true
            }, {
                field: 'gender',
                label: 'Gender'
            }]
        }
    },
    mounted() {
        this.getTickets()
    },
    methods: {

        getTickets() {

            this.http.get("/help/api/ticket").then(result => {
                if (result.successful) {
                    this.tickets = result.data
                }
            }).catch(error => {
                console.log(error)
            })

        }

    }
}
</script>
<template>
    <section class="section">
        <b-table :data="tickets" :columns="columns"></b-table>
    </section>
</template>
