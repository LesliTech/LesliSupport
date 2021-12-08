<script>
/*
Copyright (c) 2021, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// ·
*/


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import DatePicker from 'v-calendar/lib/components/date-picker.umd'
import componentUserAutocomplete from 'LesliVue/components/forms/users-autocomplete.vue'

export default {
    components: {
        'vc-date-picker': DatePicker,
        'component-users-autocomplete': componentUserAutocomplete
    },

    data(){
        return {
            translations: {
                core: I18n.t('core.shared')
            },

            filters: {
                tickets: {
                    start_date: this.date.todayAtMidnight(),
                    end_date: this.date.todayAtMidnight(),
                    users_id: null,
                    user_name: ''
                }
            },
            date_selection_shortcut: null,
            support_role: 'support',
            users: []
        }
    },

    mounted(){
        this.getUsers()
    },

    methods: {
        getUsers(){
            this.http.get(`/administration/users/list.json?role=${this.support_role}`).then(result => {
                if (result.successful) {
                    this.users = result.data
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        selectUser(user){
            if(user){
                this.filters.tickets.users_id = user.id
            }else{
                this.filters.tickets.users_id = null
            }
        },

        setManualDateRange(){
            this.date_selection_shortcut = null
        }
    },

    watch: {
        date_selection_shortcut(){
            if(this.date_selection_shortcut){
                switch(this.date_selection_shortcut){
                    case 'daily':
                        this.filters.tickets.start_date = this.date.todayAtMidnight()
                        this.filters.tickets.end_date = this.date.todayAtMidnight()
                        break
                    case 'monthly':
                        this.filters.tickets.start_date = this.date.beginingOfMonth()
                        this.filters.tickets.end_date = this.date.endOfMonth()
                        break
                    case 'weekly':
                        this.filters.tickets.start_date = this.date.beginingOfWeek(lesli.settings.datetime.start_week_on)
                        this.filters.tickets.end_date = this.date.endOfWeek(lesli.settings.datetime.start_week_on)
                        console.log(this.filters.tickets.start_date)
                        console.log(this.filters.tickets.end_date)
                        break
                }
            }
        }
    },

    computed: {
        filteredUsers(){
            return this.users.filter((user) => {
                return (user.name || '').toLowerCase().includes((this.filters.tickets.user_name || '').toLowerCase())
            })
        },

        queryFilters(){
            let query_filters = []

            for(let key in this.filters.tickets){
                if(this.filters.tickets[key]){
                    if(this.filters.tickets[key] instanceof Date){
                        query_filters.push(`filters[${key}]=${this.filters.tickets[key].toISOString()}`)
                    }else{
                        query_filters.push(`filters[${key}]=${this.filters.tickets[key]}`)
                    }
                }
            }

            return query_filters.join('&')
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="'(T) Reportes'">
        </component-header>


        <div class="card">
            <div class="card-content">
                <b-tabs>
                    <b-tab-item :label="'(T) Tickets'">
                        <div class="columns is-multiline">
                            <div class="column is-4">
                                <b-field
                                    :label="'(T) Usuario'"
                                    :message="'(T) Se mostrará información de todos los usuarios si no seleccionas uno en específico'"
                                >
                                    <b-autocomplete
                                        :placeholder="translations.core.view_placeholder_select_option"
                                        v-model="filters.tickets.user_name"
                                        keep-first
                                        field="name"
                                        @select="selectUser"
                                        :data="filteredUsers"
                                    >
                                    </b-autocomplete>
                                </b-field>
                            </div>
                            <div class="column is-2">
                                <b-field :label="'(T) Rango de Fechas'" :message="'(T) El rango semanal empieza en lunes y termina en doming'">
                                    <b-select expanded v-model="date_selection_shortcut">
                                        <option :value="null">
                                            Manual
                                        </option>
                                        <option value="daily">
                                            Este Día
                                        </option>
                                        <option value="weekly">
                                            Esta Semana
                                        </option>
                                        <option value="monthly">
                                            Este Mes
                                        </option>
                                    </b-select>
                                </b-field>
                            </div>
                            <div class="column is-3">
                                <b-field>
                                    <template v-slot:label>
                                        (T) Fecha de Inicio <sup class="has-text-danger">*</sup>
                                    </template>
                                    <vc-date-picker
                                        v-model="filters.tickets.start_date"
                                        :locale="date.vcDatepickerConfig()"
                                        :popover="{ visibility: 'focus' }"
                                        @input="setManualDateRange"
                                    >
                                        <template v-slot="{ inputValue, inputEvents }">
                                            <input
                                                class="input is-default"
                                                v-on="inputEvents"
                                                :value="inputValue"
                                                :placeholder="translations.core.view_text_select_date"
                                            />
                                        </template>
                                    </vc-date-picker>
                                </b-field>
                            </div>
                            <div class="column is-3">
                                <b-field>
                                    <template v-slot:label>
                                        (T) Fecha de Fin <sup class="has-text-danger">*</sup>
                                    </template>
                                    <vc-date-picker
                                        v-model="filters.tickets.end_date"
                                        :locale="date.vcDatepickerConfig()"
                                        :popover="{ visibility: 'focus' }"
                                        @input="setManualDateRange"
                                    >
                                        <template v-slot="{ inputValue, inputEvents }">
                                            <input
                                                class="input is-default"
                                                v-on="inputEvents"
                                                :value="inputValue"
                                                :placeholder="translations.core.view_text_select_date"
                                            />
                                        </template>
                                    </vc-date-picker>
                                </b-field>
                            </div>
                            <div class="column is-12">
                                <div class="buttons" v-if="filters.tickets.start_date && filters.tickets.end_date">
                                    <a
                                        class="button is-info is-light has-text-dark"
                                        :href="`/help/reports/tickets_general.xlsx?${queryFilters}`"
                                        target="_blank"
                                    >
                                        <b-icon icon="file-download"></b-icon>
                                        <span >(T) Reporte General</span>
                                    </a>
                                    <a
                                        class="button is-info is-light has-text-dark"
                                        :href="`/help/reports/tickets_open.xlsx?${queryFilters}`"
                                        target="_blank"
                                    >
                                        <b-icon icon="file-download"></b-icon>
                                        <span >(T) Tickets Abiertos</span>
                                    </a>
                                    <a
                                        class="button is-info is-light has-text-dark"
                                        :href="`/help/reports/tickets_overdue.xlsx?${queryFilters}`"
                                        target="_blank"
                                    >
                                        <b-icon icon="file-download"></b-icon>
                                        <span >(T) Tickets Atrasados</span>
                                    </a>
                                </div>
                                <div class="buttons" v-else>
                                    <button disabled class="button is-info is-light has-text-dark" >
                                        <b-icon icon="file-download"></b-icon>
                                        <span >(T) Reporte General</span>
                                    </button>
                                    <button disabled class="button is-info is-light has-text-dark" >
                                        <b-icon icon="file-download"></b-icon>
                                        <span >(T) Tickets Abiertos</span>
                                    </button>
                                    <button disabled class="button is-info is-light has-text-dark" >
                                        <b-icon icon="file-download"></b-icon>
                                        <span >(T) Tickets Atrasados</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </b-tab-item>
                </b-tabs>
            </div>
        </div>
    </section>
</template>
