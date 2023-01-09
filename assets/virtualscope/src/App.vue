<script setup lang="ts">
import { onMounted, ref, Ref } from 'vue';
import ScopeImage from './components/ScopeImage.vue';
import VirtualRemote from './components/VirtualRemote.vue';
import VirtualScope from './components/VirtualScope.vue';
import { socket } from './user_socket';
import type { Telescope } from './types';
import { Channel } from 'phoenix';

const scope: Ref<null | Telescope> = ref(null);
const chan: Ref<Channel | null> = ref(null);

onMounted(() => {
  chan.value = socket.channel("scope_control:lobby", {})
  chan.value.join()
    .receive("ok", resp => {
      chan.value.push("show_status", {})
        .receive("ok", (payload) => {
          scope.value = payload as Telescope;
        }).receive("error", () => { });
      chan.value.on("scope_status", payload => {
        scope.value = payload
      });
    })
    .receive("error", resp => { console.log("Unable to join", resp) });
});

const sendCmd = (cmd: string) => {
  console.log(cmd);
  chan.value.push(cmd, {});
}
</script>

<template>
  <div style="width: 100%; height: 100%; position: fixed; display: flex;" v-if="scope">
    <div style="flex: 0 0 40%; display: flex; flex-direction: column;">
      <div style="flex: 0 0 50%; padding: 16px;">
        <ScopeImage :scope="scope"></ScopeImage>
      </div>
      <div style="flex: 0 0 50%;  padding: 16px;background: lightblue;">
        <VirtualRemote :scope="scope" @command="sendCmd"></VirtualRemote>
      </div>
    </div>
    <div style="flex: 0 0 60%; padding: 16px; position: relative; background: lightgreen;">
      <VirtualScope :scope="scope"></VirtualScope>
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
