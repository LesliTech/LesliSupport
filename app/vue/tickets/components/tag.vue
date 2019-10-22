<script>
export default {
    data() {
        return {
            tags: null
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
                ellipsis
                icon="label"
                placeholder="Add a tag">
            </b-taginput>
        </div>
    </div>
</template>
