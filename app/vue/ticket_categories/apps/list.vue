<script>
/*
Lesli

Copyright (c) 2019, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@dev      Carlos Hermosilla
@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · Component list
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import treeList from '../components/tree_list.vue'

export default {
    components: {
        'tree-list': treeList
    },

    data() {
        return {
            translations:{
                shared: I18n.t('cloud_help.ticket_categories.shared')
            },
            ticket_categories: []
        }
    },
    mounted() {
        this.getTicketCategories()
    },
    methods: {

        getTicketCategories() {
            this.http.get("/help/ticket_categories.json").then(result => {
                if (result.successful) {
                    this.ticket_categories = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        showTicketCategory(ticket_category) {
            this.$router.push(`${ticket_category.id}`)
        }
    }
}
</script>
<template>
    <section class="section">
        <tree-list :trees="ticket_categories">
            <template v-slot:actions="{node}">
                <router-link :to="`/${node.id}`" class="button is-info is-small">
                    <i class="fas fa-eye"></i>&nbsp;{{translations.shared.actions.short.show}}
                </router-link>
                &nbsp;
                <router-link :to="`/${node.id}/edit`" class="button is-primary is-small">
                    <i class="fas fa-edit"></i>&nbsp;{{translations.shared.actions.short.edit}}
                </router-link>
            </template>
        </tree-list>
    </section>
</template>
