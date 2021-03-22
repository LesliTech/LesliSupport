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
import componentGeneralChart from 'LesliCoreVue/components/charts/general.vue'


// · 
export default {
    props: {
        dashboardId: {
            required: true
        },

        componentId: {
            required: true
        },

        name: {
            required: true
        }
    },

    components: {
        'component-chart-general': componentGeneralChart
    },

    data() {
        return {
            data_ready: false,
            hours_worked: {
                total: 0,
                labels: [],
                data: [],
                stroke_width: [],
                colors: [],
                types: []
            },
            translations: {
                dashboards: I18n.t('deutscheleibrenten.dashboards')
            }
        }
    },

    mounted() {
        this.getDataForChartRequestValuation()
    },

    methods: {

        getDataForChartRequestValuation(start = null, end = null) {
            let url =`/help/dashboards/${this.dashboardId}/components/${this.componentId}.json?view_type=render`

            if (start && end){
                url += `&start_at=${start.toISOString()}&end_at=${end.toISOString()}`
            }
            this.http.get(url).then(result => {
                if(result.successful){
                    this.hours_worked.labels = result.data.months
                    
                    for(let i = 0; i < result.data.records.length; i++){
                        let element = result.data.records[i]
                        this.hours_worked.total += parseFloat(element.hours_worked || 0)
                        let dataset = {}

                        if(i % result.data.months.length == 0){
                            dataset.name = element.type
                            dataset.type = 'column'
                            dataset.data = [parseFloat(element.hours_worked || 0)]
                            this.hours_worked.data.push(dataset)
                        }else{
                            dataset = this.hours_worked.data[this.hours_worked.data.length - 1]
                            dataset.data.push(parseFloat(element.hours_worked || 0))
                        }
                    }

                    this.hours_worked.total = this.hours_worked.total.toFixed(2)
                    this.hours_worked.types = result.data.types
                    this.hours_worked.stroke_width = new Array(this.hours_worked.labels.length).fill(0)
                    this.hours_worked.colors = this.generateColors(this.hours_worked.types.length)


                    this.data_ready = true
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        generateColors(num_colors){
            let initial_color = [0, 83,128]
            let final_color = [196,219,255]

            let colors = []

            for(let i = 0; i < num_colors; i++){
                let color = []

                for(let rgb_index = 0; rgb_index < 3; rgb_index++){
                    let rgb_value = initial_color[rgb_index]

                    rgb_value += i * (final_color[rgb_index] - initial_color[rgb_index]) / num_colors

                    color.push(Math.floor(rgb_value))
                }
                colors.push(`rgb(${color.join(', ')})`)
            }

            return colors
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-content has-text-centered has-text-dark">
            <div v-if="data_ready">
                <p class="is-size-5">{{ name }}</p>
                <p class="is-size-3">
                    {{ hours_worked.total > 0 
                        ? hours_worked.total 
                        : 0
                    }}
                </p>
                <component-chart-general
                    :data-sources="hours_worked.data"
                    :data-labels="hours_worked.labels"
                    :stroke-width="hours_worked.stroke_width"
                    :colors="hours_worked.colors"
                >
                </component-chart-general>
                <a href="/crm/projects?status=hours_worked">
                    <span>{{ translations.dashboards.chart_see_all_notary_appoinments }}</span>
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
