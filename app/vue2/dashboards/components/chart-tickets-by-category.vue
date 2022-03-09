<script>
/*
Copyright (c) 2020, all rights reserved.

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


// · Import frameworks, libraries and tools
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentChartBar from 'LesliCoreVue/components/charts/bar.vue'


// · 
export default {
    props: {
        dashboardId: {
            required: true
        },

        componentId: {
            required: true
        }
    },
    components: {
        'component-chart-bar': componentChartBar
    },
    data() {
        return {
            data_ready: false,
            tickets: {
                total: 0,
                labels: [],
                data: []
            },
            translations: {
                dashboards: I18n.t('help.dashboard/components'),
            },
            chart_options: {
                plotOptions:{
                    bar: {
                        dataLabels: {
                            position: 'top'
                        }
                    },
                },
                xaxis: {
                    labels: {
                        show: true,
                        rotate: -35,
                        rotateAlways: true,
                        style: {
                            fontSize: '10px'
                        }
                    }
                },
                dataLabels: {
                    enabled: true,
                    offsetY: -20,
                    style: {
                        colors: this.lesli.colors('charts')
                    }
                }
            }
        }
    },
    mounted() {
        this.getComponentData()
    },

    methods: {
        getComponentData() {
            let url =`/help/dashboards/${this.dashboardId}/components/${this.componentId}.json?view_type=render`
           
            this.http.get(url).then(result => {
                this.tickets.data  = []
                this.tickets.labels = []
                this.tickets.total = 0
                result.data.forEach(item => {
                    this.tickets.labels.push(item.category_name)
                    this.tickets.data.push(item.tickets_count)

                    this.tickets.total += item.tickets_count
                })
                

                this.tickets.data = [
                    {
                        name: this.translations.dashboards.view_title_tickets_by_category,
                        type: "column",
                        data: this.tickets.data
                    }
                ]

                this.data_ready = true
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-content has-text-centered has-text-dark">
            <div v-if="data_ready">
                <p class="is-size-5">{{ translations.dashboards.view_title_tickets_by_category }}</p>
                <p class="is-size-3">
                    {{ tickets.total > 0 
                        ? tickets.total 
                        : 0
                    }}
                </p>
                <component-chart-bar
                    :data-sources="tickets.data"
                    :data-labels="tickets.labels"
                    :options="chart_options"
                >
                </component-chart-bar>
                <a href="/help/tickets">
                    <span>{{ translations.dashboards.view_title_all_tickets }}</span>
                    <span class="icon">
                        <i class="fas fa-arrow-right"></i>
                    </span>
                </a>
            </div>
            <component-data-loading v-else>
            </component-data-loading>
        </div>
    </div>
</template>
