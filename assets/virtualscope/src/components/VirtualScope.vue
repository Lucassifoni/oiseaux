<script setup lang="ts">
import { computed, onMounted, ref, Ref, watch } from 'vue'
import * as THREE from 'three';
import * as Vueuse from "@vueuse/core";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { loadModels, ModelsRegistry } from './virtualscope_utils';
import { Telescope } from '../types';

const props = defineProps<{
  scope: Telescope
}>();

const sceneTarget: Ref<null | HTMLDivElement> = ref(null);
const sceneRendererDims = Vueuse.useElementSize(sceneTarget);
const renderer = new THREE.WebGLRenderer({ antialias: true });
const light = new THREE.AmbientLight(0x404040, 5); // soft white light
let camera = new THREE.PerspectiveCamera(70, 1, 0.01, 10);
const scene = new THREE.Scene();
let registry: ModelsRegistry | null = null;
const light2 = new THREE.PointLight(0xff0000, 2, 0);
light2.position.set(50, 50, 50);
scene.add(light2);
scene.add(light);
const sleep = async (ms: number) => new Promise(r => setTimeout(r, ms));
onMounted(async () => {
  await sleep(1000);
  const controls = new OrbitControls(camera, renderer.domElement);
  registry = await loadModels(scene);
  setTimeout(() => {
    draw();
    renderer.setAnimationLoop(animation);
    function animation(time: number) {
      renderer.render(scene, camera);
    };
  }, 1500);
});

watch(sceneRendererDims.width, () => {
  camera.aspect = sceneRendererDims.width.value / sceneRendererDims.height.value;
  camera.updateProjectionMatrix();
  renderer.setSize(sceneRendererDims.width.value, sceneRendererDims.height.value);
  renderer.render(scene, camera);
}, { deep: true });

const position_az = computed(() => props.scope.position_az);
const position_alt = computed(() => props.scope.position_alt);
watch(position_az, (val) => {
  registry.base.ref.rotation.y = val;
  registry.top.ref.rotation.y = val;
  registry.lowend.ref.rotation.y = val;
});

watch(position_alt, (val) => {
  registry.top.ref.rotation.z = val;
  registry.lowend.ref.rotation.z = val;
});

const draw = () => {
  camera.position.z = 1;
  renderer.setSize(sceneRendererDims.width.value, sceneRendererDims.height.value);
  if (sceneTarget.value) {
    sceneTarget.value.appendChild(renderer.domElement);
  }
};
</script>

<template>
  <div ref="sceneTarget" style="position: absolute; left: 0; top: 0; right: 0; bottom: 0;"></div>
</template>

<style>

</style>
