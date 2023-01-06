<script setup lang="ts">
import ScopeImage from './components/ScopeImage.vue';
import VirtualRemote from './components/VirtualRemote.vue';
import VirtualScope from './components/VirtualScope.vue';


</script>

<template>
  <div style="width: 100%; height: 100%; position: fixed; display: flex;">
    <div style="flex: 0 0 40%; display: flex; flex-direction: column;">
      <div style="flex: 0 0 50%; padding: 16px; background: lightcoral;">
        <ScopeImage></ScopeImage>
      </div>
      <div style="flex: 0 0 50%;  padding: 16px;background: lightblue;">
        <VirtualRemote></VirtualRemote>
      </div>
    </div>
    <div style="flex: 0 0 60%; padding: 16px; position: relative; background: lightgreen;">
      <VirtualScope></VirtualScope>
    </div>
  </div>
</template>

<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
}

.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}

.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}
</style>
