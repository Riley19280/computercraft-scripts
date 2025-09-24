import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

let scene, camera, renderer, controls;
const voxelSize = 1;
let geometries = []; // Store the voxel cubes

// const initialVoxels = [
//     { x: 0, y: 0, z: 0 },
//     { x: 1, y: 0, z: 0 },
//     { x: 2, y: 1, z: 0 },
//     { x: 3, y: 1, z: 0 },
//     { x: 4, y: 2, z: 0 },
//     { x: 5, y: 2, z: 0 }
// ];

const initialVoxels = [
    { x: 0, y: 0, z: 0 },
    { x: 1, y: 0, z: 0 },
    { x: 0, y: 1, z: 0 },
    { x: 1, y: 1, z: 0 },
    { x: 0, y: 2, z: 0 },
    { x: 1, y: 2, z: 0 },
    { x: 2, y: 3, z: 0 },
    { x: 3, y: 3, z: 0 },
    { x: 2, y: 3, z: 1 },
    { x: 3, y: 3, z: 1 },
];

function init() {
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    renderer = new THREE.WebGLRenderer({
        antialias: true
    });
    renderer.setSize(window.innerWidth / 2, window.innerHeight / 2);
    document.getElementById('renderer').appendChild(renderer.domElement);

    // Add light
    const light = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(light);

    const axes = new THREE.AxesHelper(10);
    scene.add(axes);

    const dl = new THREE.DirectionalLight(0xffffff, 2.5);
    dl.castShadow = true
    camera.position.z = 5;
    camera.add( dl );

    // Add orbit controls for panning and zooming
    controls = new OrbitControls(camera, renderer.domElement);

    window.addEventListener('resize', onWindowResize, false);
    window.addEventListener('renderer/data', onDataReceived, false);

    // Create initial voxels
    const initialMeshes = initialVoxels.map(v => ({...v, width: 1, height: 1, depth: 1}))
    addMergedVoxels(greedyMesh(greedyMesh(greedyMesh(initialMeshes, 'x'), 'y'), 'z'));
    animate();
}

function greedyMesh(meshList, dimension) {
    const meshes = new Set(meshList.map(v => `${v.x},${v.y},${v.z},${v.width},${v.height},${v.depth}`))
    const visited = new Set();

    const mergedMeshes = []

    for(const mesh of meshList) {
        if (visited.has(`${mesh.x},${mesh.y},${mesh.z},${mesh.width},${mesh.height},${mesh.depth}`))
            continue
        visited.add(`${mesh.x},${mesh.y},${mesh.z},${mesh.width},${mesh.height},${mesh.depth}`)
        
        let shiftX = dimension == 'x' ? mesh.width : 0
        let shiftY = dimension == 'y' ? mesh.height : 0
        let shiftZ = dimension == 'z' ? mesh.depth : 0

        while(meshes.has(`${mesh.x + shiftX},${mesh.y + shiftY},${mesh.z + shiftZ},${mesh.width},${mesh.height},${mesh.depth}`)) {
            visited.add(`${mesh.x + shiftX},${mesh.y + shiftY},${mesh.z + shiftZ},${mesh.width},${mesh.height},${mesh.depth}`)
            shiftX += dimension == 'x' ? 1 : 0
            shiftY += dimension == 'y' ? 1 : 0
            shiftZ += dimension == 'z' ? 1 : 0
        }

        mergedMeshes.push({
            x: mesh.x,
            y: mesh.y,
            z: mesh.z,
            width: dimension == 'x' ? shiftX : mesh.width,
            height: dimension == 'y' ? shiftY : mesh.height,
            depth: dimension == 'z' ? shiftZ : mesh.depth
        })
    }

    console.log(mergedMeshes)
    return mergedMeshes

}

function addMergedVoxels(mergedVoxels) {
    mergedVoxels.forEach(voxel => {
        const geometry = new THREE.BoxGeometry(voxel.width * voxelSize, voxel.height * voxelSize, voxel.depth * voxelSize);
        const material = new THREE.MeshStandardMaterial({ color: Math.random() * 0xffffff });
        const mesh = new THREE.Mesh(geometry, material);
        mesh.position.set(
            voxel.x + (voxel.width / 2) + (voxelSize / 2),
            voxel.y + (voxel.height / 2) + (voxelSize / 2),
            voxel.z + (voxel.depth / 2) + (voxelSize / 2),
        );
        scene.add(mesh);
        geometries.push(mesh);
    });
}

function onDataReceived(evt) {
    const data = evt.detail;
    console.log('Data received:', data);
    updateVoxels(data);
}

function updateVoxels(newVoxelData) {
    // Remove existing cubes from the scene
    geometries.forEach(cube => scene.remove(cube));
    geometries = [];

    newVoxelData = newVoxelData.map(v => ({...v, width: 1, height: 1, depth: 1}))
    // Add merged voxels
    addMergedVoxels(greedyMesh(greedyMesh(greedyMesh(newVoxelData, 'x'), 'y'), 'z'));
}

function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

function animate() {
    requestAnimationFrame(animate);
    controls.update();
    renderer.render(scene, camera);
}

// Initialize the scene
init();
