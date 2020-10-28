<script>
export default {
    props: {
        id: {
            default: null
        },

        subject: {
            default: null
        },

        status: {
            default: null
        }
    }
}
</script>
<template>
    <nav class="navbar component-header">
        <div class="navbar-menu">
            <div class="navbar-start">
                <div class="navbar-item">
                    <h4 class="is-size-3">
                        <span v-if="id">
                            {{id}}
                        </span>
                        -
                        <span v-if="subject">
                            {{subject}}
                        </span>
                        -
                        <span v-if="status">
                            {{status}}
                        </span>
                    </h4>
                </div>
            </div>
            <div class="navbar-end">
                <slot name="actions">
                </slot>
            </div>
        </div>
    </nav>
</template>
