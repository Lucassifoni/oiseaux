<script setup lang="ts">
import { ref } from 'vue'
import { Telescope } from '../types';

const props = defineProps<{
    scope: Telescope
}>();
</script>

<template>
    <div>
        <ul v-if="scope.position_alt !== -1">
            <li>Scope : {{  scope.name }} <span v-if="scope.moving !== 'no'">(moving {{  scope.moving }})</span></li>
            <li>Lower alt endstop : {{ scope.lower_alt_stop ? 'engaged' : 'released' }}</li>
            <li>Upper alt endstop : {{ scope.upper_alt_stop ? 'engaged' : 'released' }}</li>
            <li>Alt position : {{  (scope.position_alt * (180 / Math.PI)).toFixed(2) }}°</li>
            <li>Az position : {{  (scope.position_az * (180 / Math.PI)).toFixed(2) }}°</li>
            <li>Focuser lower endstop : {{  scope.lower_focus_stop ? 'engaged' : 'released'}}</li>
            <li>Focuser upper endstop : {{  scope.upper_focus_stop ? 'engaged' : 'released'}}</li>
            <li>Focuser position : {{ scope.position_focus.toFixed(2) }}mm</li>
        </ul>
        <ul v-else>
            <li>Scope is in an undefined state. <strong>Home it</strong></li>
        </ul>
    </div>
</template>

<style>

</style>
