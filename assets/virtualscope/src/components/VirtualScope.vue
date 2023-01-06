<script setup lang="ts">
import { onMounted, ref, Ref, watch } from 'vue'
import * as THREE from 'three';
import * as Vueuse from "@vueuse/core";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

const sceneTarget: Ref<null | HTMLDivElement> = ref(null);
const sceneRendererDims = Vueuse.useElementSize(sceneTarget);
const renderer = new THREE.WebGLRenderer({ antialias: true });
const light = new THREE.AmbientLight(0x404040, 5); // soft white light
let camera;
const scene = new THREE.Scene();

const light2 = new THREE.PointLight(0xff0000, 2, 0);
light2.position.set(50, 50, 50);
scene.add(light2);
scene.add(light);
const sleep = async (ms: number) => new Promise(r => setTimeout(r, ms));
onMounted(async () => {
  await sleep(1000);
  camera = new THREE.PerspectiveCamera(70, sceneRendererDims.width.value / sceneRendererDims.height.value, 0.01, 10);
  const controls = new OrbitControls(camera, renderer.domElement);
  const registry = {};
  const loader = new GLTFLoader();
  [
    '/models/base.glb',
    '/models/lowend.glb',
    '/models/top.glb',
    '/models/tripod.glb',
  ].forEach((model) => {
    loader.load(model, function (gltf) {
      registry[model] = gltf.scene;
      scene.add(gltf.scene);
    }, undefined, function (error) {
      console.error(error);
    });
  });
  setTimeout(() => {
    console.log(registry);
    draw();
    renderer.setAnimationLoop(animation);
    function animation(time: number) {
      registry['/models/base.glb'].rotation.y += 0.01;
      registry['/models/lowend.glb'].rotation.y += 0.01;
      registry['/models/top.glb'].rotation.y += 0.01;
      renderer.render(scene, camera);
    };
  }, 1500);
});

watch(sceneRendererDims.width, () => {
  if (camera) {
    camera.aspect = sceneRendererDims.width.value / sceneRendererDims.height.value;
    camera.updateProjectionMatrix();
    renderer.setSize(sceneRendererDims.width.value, sceneRendererDims.height.value);
    renderer.render(scene, camera);
  }
}, { deep: true });

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
