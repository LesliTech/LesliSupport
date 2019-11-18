<script>
export default {
    props:{
        trees: {
            type: Array,
            default: []
        },
        scrollable: {
            type: Boolean,
            default: false
        },
        default_card: {
            type: Boolean,
            default: false
        }
    },
    methods: {

        toggleSubTrees(row){
            if(!row.has_children){
                return
            }
            let ancestry = row.id
            if(row.ancestry){
                ancestry = `${row.ancestry}/${ancestry}`
            }
            let sub_trees = this.trees.filter(element => {
                if(row.children_active){
                    return element.ancestry && element.ancestry.startsWith(ancestry)
                }else{
                    return element.ancestry == ancestry
                }
            })
            row.children_active = ! row.children_active
            sub_trees.forEach(element => {
                element.active = row.children_active
                if(! row.children_active){
                    element.children_active = false;
                }
            })
        }
    }
}
</script>
<template>
    <section :class="{'scrollable': scrollable}">
        <div v-if="default_card">
            <b-collapse>
                <div class="card">
                    <header class="card-header">
                        <p class="card-header-title">
                            <slot name="default_content">
                            </slot>
                        </p>
                        <span class="card-header-icon">
                            <slot name="default_actions">
                            </slot>
                        </span>
                    </header>
                </div>
            </b-collapse>
        </div>
        <div v-for="tree in trees" :key="tree.id">
            <b-collapse
                :open.sync="tree.active"
            >
                <div class="card">
                    <header class="card-header">
                        <span v-for="level in tree.depth" :key="level">
                            &nbsp;&nbsp;&nbsp;
                        </span>
                        <p class="card-header-title">
                            <i v-if="tree.children_active" class="fas fa-chevron-down"></i>
                            <i 
                                v-else :class="{'has-text-white': !tree.has_children}"
                                class="fas fa-chevron-right"
                            ></i>
                            &nbsp;&nbsp;
                            <a v-if="tree.has_children" @click="toggleSubTrees(tree)" class="has-text-weight-bold">
                                <slot name="content" :node="tree">
                                    {{tree.index}} - {{tree.name}}
                                </slot>
                            </a>
                            <span v-else>
                                <slot name="content" :node="tree">
                                    {{tree.index}} - {{tree.name}}
                                </slot>
                            </span>
                        </p>
                        <span class="card-header-icon">
                            <slot name="actions" :node="tree">
                            </slot>
                        </span>
                    </header>
                </div>
            </b-collapse>
        </div>
    </section>
</template>
<style scoped>
section.scrollable {
    height: 23rem;
    overflow-y: scroll;
}
</style>
