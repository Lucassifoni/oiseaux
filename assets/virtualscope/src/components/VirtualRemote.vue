<script setup lang="ts">
import { ref, defineProps, computed } from 'vue'
import { Telescope } from '../types';

const props = defineProps<{
  scope: Telescope
}>();
const emit = defineEmits<{
  (event: 'command', payload: 'up' |
    'down' |
    'left' |
    'right' |
    'focus_in' |
    'focus_out' |
    'home' |
    'stop' |
    'stop_focus'): void,
  (event: 'stop_focus'): void
}>();
const stop = () => {
  emit('command', 'stop');
  emit('command', 'stop_focus');
};
const stop_focus = () => {
  emit('command', 'stop_focus')
  emit('stop_focus')
  setTimeout(() => {
    imgUrl.value = toImgUrl(props.scope.position_focus);
    blur.value = true;
  }, 32);
};
const toImgUrl = (focus_position: number): string => {
  return `http://nezha:4000/dof_simulation?scene_distance=20000.0&sensor_distance=${408.0 - focus_position}&pxsize=0.0028&radius=57.0&base_fl=400`;
};
const blur = ref(true);
const unblur = () => {
  blur.value = false;
};
const imgUrl = ref(toImgUrl(0));
</script>

<template>
  <div style="background: gray;padding:16px;border-radius:8px; display: flex;">
    <div class="screen" style="width: 320px; height: 180px; background: black;border:1px solid #666;">
      <img :src="imgUrl" @load="unblur" style="width: 100%; height: auto" :style="{filter: blur ? `blur(20px)` : ``}" alt="">
    </div>
    <div class="nav-buttons"
      style="height: 100%; width: 200px; height: 180px; position: relative; background: gray; margin-left: 10px;">
      <div class="directional-cross"
        style="position: relative; width: 130px; height: 130px; margin: 8px auto;">
        <button :disabled="scope.position_alt === -1 || scope.upper_alt_stop"
          style="position: absolute; width: 33.3%; height: 33.3%; left: 33.3%; top: 0;"
          @mouseup="emit('command', 'stop')" @mousedown="emit('command', 'up')">&uarr;</button>
        <button :disabled="scope.position_alt === -1"
          style="position: absolute; width: 33.3%; height: 33.3%; right: 0; top: 33.3%;"
          @mouseup="emit('command', 'stop')" @mousedown="emit('command', 'right')">&rarr;</button>
        <button :disabled="scope.position_alt === -1 || scope.lower_alt_stop"
          style="position: absolute; width: 33.3%; height: 33.3%; left: 33.3%; bottom: 0;"
          @mouseup="emit('command', 'stop')" @mousedown="emit('command', 'down')">&darr;</button>
        <button :disabled="scope.position_alt === -1"
          style="position: absolute; width: 33.3%; height: 33.3%; left: 0; top: 33.3%;"
          @mouseup="emit('command', 'stop')" @mousedown="emit('command', 'left')">&larr;</button>
        <button :disabled="scope.position_alt !== -1"
          style="position: absolute; width: 33.3%; height: 33.3%; left: 33.3%; top: 33.3%;"
          @click="emit('command', 'home')">h</button>
      </div>
      <div class="focuser-control" style="width: calc(100% - 2em); height: 18px;position: relative; margin: auto">
        <button class="focus-out" @mousedown="emit('command', 'focus_in')" @mouseup="stop_focus"
          :disabled="scope.lower_focus_stop" style="position: absolute; top: 0px; left: 0; z-index: 1;">
          &lt;
        </button>
        <div class="range"
          style="position: absolute; width: calc(100% - 45px); height: 4px; top: 50%; left: 50%; transform: translate(-50%, -50%); background: black;">
          <div class="cursor"
            style="width: 2px; height: 24px; top: -8px; background: red; position: absolute; transform: translate(-50%);"
            :style="{ left: `${((scope.position_focus + 10) / 20) * 100}%` }"></div>
        </div>
        <button class="focus-in" @mousedown="emit('command', 'focus_out')" @mouseup="stop_focus"
          :disabled="scope.upper_focus_stop" style="position: absolute; top: 0px; right: 0; z-index: 1;">
          &gt;
        </button>
      </div>
    </div>
  </div>
</template>

<style>

</style>
