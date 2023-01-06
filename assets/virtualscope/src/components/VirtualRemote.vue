<script setup lang="ts">
import { ref } from 'vue'
</script>

<template>
  <div style="background: gray;padding:16px;border-radius:8px; display: flex;">
    <div class="screen" style="width: 320px; height: 240px; background: black;border:1px solid #666;">

    </div>
    <div class="nav-buttons" style="height: 100%; width: 200px; height: 240px; position: relative;background: lightblue; margin-left: 10px;">
      <button>&uarr;</button>
      <button>&rarr;</button>
      <button>x</button>
      <button>&darr;</button>
      <button>&larr;</button>
    </div>
  </div>
</template>

<style>

</style>
