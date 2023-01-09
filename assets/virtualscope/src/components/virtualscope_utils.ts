import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

export type ModelsRegistry = {
    "base": { path: "/models/base.glb", ref: null | any },
    "lowend": { path: "/models/lowend.glb", ref: null | any },
    "top": { path: "/models/top.glb", ref: null | any },
    "tripod": { path: "/models/tripod.glb", ref: null | any },
};

export const loadModels = async (scene: THREE.Scene, timeout = 5000): Promise<ModelsRegistry> => {
    return new Promise((resolve, reject) => {
        const registry: ModelsRegistry = {
            'base': { path: '/models/base.glb', ref: null },
            'lowend': { path: '/models/lowend.glb', ref: null },
            'top': { path: '/models/top.glb', ref: null },
            'tripod': { path: '/models/tripod.glb', ref: null },
        };
        const loader = new GLTFLoader();
        Object.keys(registry).forEach((key) => {
            const k = key as 'base' | 'lowend' | 'top' | 'tripod';
            loader.load(registry[k].path, function (gltf) {
                registry[k].ref = gltf.scene;
                scene.add(gltf.scene);
            }, undefined, function (error) {
                console.error(error);
            });
        });
        const tout = setTimeout(reject, timeout);
        const interval = setInterval(() => {
            const flag = Object.entries(registry)
                .reduce((
                    out: boolean,
                    entry: [string, any]
                ) => {
                    return out && entry[1].ref !== null
                }, true);
            if (flag) {
                clearInterval(interval);
                clearTimeout(tout);
                resolve(registry);
            }
        }, 16);
    });
};