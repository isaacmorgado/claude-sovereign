'use client';

import { useEffect, useRef, useState } from 'react';
import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js';
import { OutlinePass } from 'three/examples/jsm/postprocessing/OutlinePass.js';
import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass.js';
import { RGBShiftShader } from 'three/examples/jsm/shaders/RGBShiftShader.js';

// Score color gradient function
function getScoreColorRGB(score: number): string {
  if (typeof score !== 'number') return 'rgb(37, 99, 235)';
  const clamp = Math.max(1, Math.min(10, score));
  const stops = [
    { t: 1, c: [185, 28, 28] },
    { t: 2, c: [220, 53, 53] },
    { t: 3, c: [239, 88, 88] },
    { t: 4, c: [245, 130, 75] },
    { t: 5, c: [251, 175, 60] },
    { t: 6, c: [220, 200, 80] },
    { t: 7, c: [140, 215, 100] },
    { t: 8, c: [74, 222, 128] },
    { t: 9, c: [40, 205, 170] },
    { t: 10, c: [6, 182, 212] }
  ];
  let out = stops[stops.length - 1].c;
  for (let i = 0; i < stops.length - 1; i++) {
    const a = stops[i], b = stops[i + 1];
    if (clamp >= a.t && clamp <= b.t) {
      const f = (clamp - a.t) / (b.t - a.t);
      out = [
        Math.round(a.c[0] + f * (b.c[0] - a.c[0])),
        Math.round(a.c[1] + f * (b.c[1] - a.c[1])),
        Math.round(a.c[2] + f * (b.c[2] - a.c[2]))
      ];
      break;
    }
  }
  return `rgb(${out[0]}, ${out[1]}, ${out[2]})`;
}

// Create vertical gradient texture for walls
function createVerticalGradientTexture(topHex: string, bottomHex: string): THREE.CanvasTexture {
  const canvas = document.createElement('canvas');
  canvas.width = 1;
  canvas.height = 256;
  const ctx = canvas.getContext('2d')!;
  const grad = ctx.createLinearGradient(0, 0, 0, 256);
  grad.addColorStop(0, topHex);
  grad.addColorStop(1, bottomHex);
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, 1, 256);
  const tex = new THREE.CanvasTexture(canvas);
  tex.wrapS = THREE.ClampToEdgeWrapping;
  tex.wrapT = THREE.ClampToEdgeWrapping;
  return tex;
}

interface HeadSceneProps {
  className?: string;
}

export default function HeadScene({ className = '' }: HeadSceneProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const sceneRef = useRef<{
    scene: THREE.Scene;
    camera: THREE.PerspectiveCamera;
    renderer: THREE.WebGLRenderer;
    composer: EffectComposer;
    headModel: THREE.Group | null;
    roomGroup: THREE.Group;
    outlinePass: OutlinePass;
    bloomPass: UnrealBloomPass;
    rgbShiftPass: ShaderPass;
    pointer: { x: number; y: number };
    pointerTarget: { x: number; y: number };
    currentScore: number;
    targetScore: number;
    currentYaw: number;
    targetYaw: number;
    cameraBaseZ: number;
    cameraBaseY: number;
    cameraTargetY: number;
    gridColorsAttr: THREE.Float32BufferAttribute | null;
    floorY: number;
  } | null>(null);
  const animationRef = useRef<number | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Setup and cleanup
  useEffect(() => {
    if (!containerRef.current) return;

    const container = containerRef.current;
    const rect = container.getBoundingClientRect();
    const width = rect.width || window.innerWidth * 0.5;
    const height = rect.height || window.innerHeight;

    // Scene
    const scene = new THREE.Scene();

    // Camera
    const camera = new THREE.PerspectiveCamera(45, width / height, 0.01, 500);

    // Renderer
    const renderer = new THREE.WebGLRenderer({
      antialias: window.devicePixelRatio <= 1.25,
      alpha: false
    });
    renderer.setClearColor(0x000000, 1);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
    renderer.setSize(width, height);
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.05;

    renderer.domElement.style.display = 'block';
    renderer.domElement.style.position = 'absolute';
    renderer.domElement.style.top = '0';
    renderer.domElement.style.left = '0';
    renderer.domElement.style.width = '100%';
    renderer.domElement.style.height = '100%';

    container.appendChild(renderer.domElement);

    // Effect Composer
    const composer = new EffectComposer(renderer);
    composer.setSize(width, height);
    composer.addPass(new RenderPass(scene, camera));

    // Outline Pass
    const outlinePass = new OutlinePass(new THREE.Vector2(width, height), scene, camera);
    outlinePass.edgeStrength = 1.3;
    outlinePass.edgeThickness = 1.2;
    outlinePass.pulsePeriod = 3;
    outlinePass.visibleEdgeColor.set(0xffffff);
    outlinePass.hiddenEdgeColor.set(0x000000);
    composer.addPass(outlinePass);

    // Bloom Pass
    const bloomPass = new UnrealBloomPass(new THREE.Vector2(width, height), 0.2, 0.3, 0.88);
    composer.addPass(bloomPass);

    // RGB Shift Pass
    const rgbShiftPass = new ShaderPass(RGBShiftShader);
    rgbShiftPass.uniforms['amount'].value = 0.0015;
    composer.addPass(rgbShiftPass);

    // Lighting
    const hemiLight = new THREE.HemisphereLight(0xffffff, 0xffffff, 0.35);
    scene.add(hemiLight);

    const keyLight = new THREE.DirectionalLight(0xfff1e0, 1.2);
    keyLight.position.set(10, 20, 15);
    scene.add(keyLight);

    const fillLight = new THREE.DirectionalLight(0xe8f0ff, 0.5);
    fillLight.position.set(-5, 3, 5);
    scene.add(fillLight);

    const rimLight = new THREE.DirectionalLight(0xcfe8ff, 0.8);
    rimLight.position.set(2, 3, -5);
    scene.add(rimLight);

    // Room Group
    const roomGroup = new THREE.Group();
    const floorY = -30;

    // Floor
    const floorGeometry = new THREE.PlaneGeometry(400, 400);
    const floorMaterial = new THREE.MeshStandardMaterial({
      color: 0x19212c,
      roughness: 1.0,
      metalness: 0.0
    });
    const floor = new THREE.Mesh(floorGeometry, floorMaterial);
    floor.rotation.x = -Math.PI / 2;
    floor.position.y = floorY;
    roomGroup.add(floor);

    // Grid
    const gridSize = 400;
    const gridDivisions = 20;
    const gridPoints: number[] = [];
    const step = gridSize / gridDivisions;
    const halfSize = gridSize / 2;

    for (let i = 0; i <= gridDivisions; i++) {
      const pos = -halfSize + i * step;
      gridPoints.push(-halfSize, 0, pos, halfSize, 0, pos);
      gridPoints.push(pos, 0, -halfSize, pos, 0, halfSize);
    }

    const gridGeometry = new THREE.BufferGeometry();
    gridGeometry.setAttribute('position', new THREE.Float32BufferAttribute(gridPoints, 3));
    const gridColorsAttr = new THREE.Float32BufferAttribute(new Float32Array(gridPoints.length), 3);
    gridGeometry.setAttribute('color', gridColorsAttr);

    const gridMaterial = new THREE.LineBasicMaterial({
      color: 0xffffff,
      transparent: true,
      opacity: 0.3,
      vertexColors: true,
      blending: THREE.AdditiveBlending,
      depthWrite: false
    });

    const gridLines = new THREE.LineSegments(gridGeometry, gridMaterial);
    gridLines.position.y = floorY + 0.1;
    roomGroup.add(gridLines);

    // Back Wall
    const wallBackGeometry = new THREE.PlaneGeometry(400, 400);
    const wallBackMaterial = new THREE.MeshStandardMaterial({
      color: 0xffffff,
      roughness: 1.0,
      metalness: 0.0
    });
    wallBackMaterial.map = createVerticalGradientTexture('#2a344a', '#0f141d');
    const wallBack = new THREE.Mesh(wallBackGeometry, wallBackMaterial);
    wallBack.position.set(0, 170, -200);
    roomGroup.add(wallBack);

    // Side Walls
    const wallLeftMaterial = new THREE.MeshStandardMaterial({
      color: 0xffffff,
      roughness: 1.0,
      metalness: 0.0
    });
    wallLeftMaterial.map = createVerticalGradientTexture('#253145', '#0d121a');
    const wallLeft = new THREE.Mesh(new THREE.PlaneGeometry(400, 400), wallLeftMaterial);
    wallLeft.rotation.y = Math.PI / 2;
    wallLeft.position.set(-200, 170, 0);
    roomGroup.add(wallLeft);

    const wallRightMaterial = new THREE.MeshStandardMaterial({
      color: 0xffffff,
      roughness: 1.0,
      metalness: 0.0
    });
    wallRightMaterial.map = createVerticalGradientTexture('#253145', '#0d121a');
    const wallRight = new THREE.Mesh(new THREE.PlaneGeometry(400, 400), wallRightMaterial);
    wallRight.rotation.y = -Math.PI / 2;
    wallRight.position.set(200, 170, 0);
    roomGroup.add(wallRight);

    scene.add(roomGroup);

    // Set initial camera position
    camera.position.set(0, 10, 100);
    camera.lookAt(0, 0, 0);
    camera.updateProjectionMatrix();

    // Store refs
    const sceneData = {
      scene,
      camera,
      renderer,
      composer,
      headModel: null as THREE.Group | null,
      roomGroup,
      outlinePass,
      bloomPass,
      rgbShiftPass,
      pointer: { x: 0, y: 0 },
      pointerTarget: { x: 0, y: 0 },
      currentScore: 0,
      targetScore: 4.27,
      currentYaw: 0,
      targetYaw: 0,
      cameraBaseZ: 50,
      cameraBaseY: 5,
      cameraTargetY: 0,
      gridColorsAttr,
      floorY
    };
    sceneRef.current = sceneData;

    // Animation loop
    const animateScene = () => {
      const {
        camera: cam,
        composer: comp,
        headModel: head,
        roomGroup: room,
        outlinePass: outline,
        bloomPass: bloom,
        rgbShiftPass: rgbShift,
        pointer: ptr,
        pointerTarget: ptrTarget,
        cameraBaseZ: camBaseZ,
        cameraBaseY: camBaseY,
        cameraTargetY: camTargetY,
        gridColorsAttr: gridColors
      } = sceneData;

      const t = performance.now() * 0.001;

      // Interpolate yaw
      sceneData.currentYaw = THREE.MathUtils.lerp(
        sceneData.currentYaw,
        sceneData.targetYaw,
        0.08
      );

      // Smooth pointer interpolation
      ptr.x += (ptrTarget.x - ptr.x) * 0.08;
      ptr.y += (ptrTarget.y - ptr.y) * 0.08;

      const isMobile = window.innerWidth <= 800;

      // Base pitch and yaw values
      const headBasePitch = isMobile ? -0.35 : -0.10;
      const headBaseYaw = isMobile ? 0.0 : 0.0;
      const roomBasePitch = isMobile ? -0.35 : -0.10;
      const roomBaseYaw = isMobile ? -0.2 : 0.0;

      // Head model - static position (cursor animation removed)
      if (head) {
        head.rotation.y = headBaseYaw - sceneData.currentYaw;
        head.rotation.x = headBasePitch;
      }

      // Room - static position (cursor animation removed)
      if (room) {
        room.rotation.y = roomBaseYaw;
        room.rotation.x = roomBasePitch;
      }

      // Camera - static position (cursor animation removed)
      cam.position.set(0, camBaseY, camBaseZ);
      cam.lookAt(0, camTargetY, 0);

      // Animate score
      sceneData.currentScore += (sceneData.targetScore - sceneData.currentScore) * 0.08;
      const scoreColor = getScoreColorRGB(sceneData.currentScore);

      // Update outline color
      if (outline) {
        outline.visibleEdgeColor.setStyle(scoreColor);
        outline.edgeStrength = 2.0 + 1.5 * (0.5 + 0.5 * Math.sin(t * 1.2));
      }

      // Update bloom
      if (bloom) {
        const targetBloom = 0.25 + Math.max(0, Math.min(1, (sceneData.currentScore - 5) / 5)) * 0.7;
        bloom.strength += (targetBloom - bloom.strength) * 0.05;
        bloom.radius = 0.4 + 0.2 * (0.5 + 0.5 * Math.sin(t * 0.6));
      }

      // Update RGB shift
      if (rgbShift) {
        rgbShift.uniforms['amount'].value = 0.0012 + 0.0008 * (0.5 + 0.5 * Math.sin(t * 0.75));
      }

      // Update grid colors
      if (gridColors) {
        const rgbMatch = scoreColor.match(/\d+/g);
        if (rgbMatch) {
          const r = parseInt(rgbMatch[0]) / 255;
          const g = parseInt(rgbMatch[1]) / 255;
          const b = parseInt(rgbMatch[2]) / 255;
          const arr = gridColors.array as Float32Array;
          for (let i = 0; i < arr.length; i += 3) {
            const wave = 0.3 + 0.7 * (0.5 + 0.5 * Math.sin(t * 0.5 + i * 0.01));
            arr[i] = r * wave;
            arr[i + 1] = g * wave;
            arr[i + 2] = b * wave;
          }
          gridColors.needsUpdate = true;
        }
      }

      comp.render();
      animationRef.current = requestAnimationFrame(animateScene);
    };

    // Event handlers
    const handlePointer = (e: PointerEvent) => {
      const rect = container.getBoundingClientRect();
      const nx = ((e.clientX - rect.left) / rect.width) * 2 - 1;
      const ny = ((e.clientY - rect.top) / rect.height) * 2 - 1;
      sceneData.pointerTarget.x = Math.max(-1, Math.min(1, nx));
      sceneData.pointerTarget.y = Math.max(-1, Math.min(1, ny));
    };

    const handleLeave = () => {
      sceneData.pointerTarget.x = 0;
      sceneData.pointerTarget.y = 0;
    };

    const handleResize = () => {
      const rect = container.getBoundingClientRect();
      const w = rect.width;
      const h = rect.height;

      camera.aspect = w / h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
      composer.setSize(w, h);
    };

    window.addEventListener('pointermove', handlePointer);
    window.addEventListener('pointerleave', handleLeave);
    window.addEventListener('resize', handleResize);

    // Load 3D Model
    const loader = new GLTFLoader();
    loader.load('/face.glb', (gltf) => {
      const model = gltf.scene;

      const meshes: THREE.Mesh[] = [];
      model.traverse((obj) => {
        if ((obj as THREE.Mesh).isMesh) {
          meshes.push(obj as THREE.Mesh);
        }
      });

      meshes.forEach((mesh) => {
        const skinMaterial = new THREE.MeshStandardMaterial({
          color: 0xf5f2ed,
          emissive: 0xffffff,
          emissiveIntensity: 0.08,
          metalness: 0.08,
          roughness: 0.4,
          transparent: false,
          opacity: 1,
          depthWrite: true,
          depthTest: true,
          side: THREE.FrontSide
        });

        skinMaterial.onBeforeCompile = (shader) => {
          shader.uniforms.uFresnelColor = { value: new THREE.Color(0xffffff) };
          shader.uniforms.uFresnelPower = { value: 1.8 };
          shader.uniforms.uFresnelIntensity = { value: 0.25 };
          shader.fragmentShader = shader.fragmentShader.replace(
            '#include <output_fragment>',
            `
            float fresnel = pow(1.0 - dot(normalize(vNormal), normalize(vViewPosition)), uFresnelPower);
            vec3 fres = uFresnelColor * fresnel * uFresnelIntensity;
            gl_FragColor = vec4( outgoingLight + fres, diffuseColor.a );
            `
          );
        };
        skinMaterial.needsUpdate = true;

        mesh.material = skinMaterial;
        mesh.castShadow = true;
        mesh.receiveShadow = true;

        if (mesh.geometry) {
          const overlayMaterial = new THREE.MeshBasicMaterial({
            color: 0xffffff,
            wireframe: true,
            transparent: true,
            opacity: 0.045,
            depthWrite: false
          });
          const overlayMesh = new THREE.Mesh(mesh.geometry, overlayMaterial);
          overlayMesh.renderOrder = (mesh.renderOrder || 0) + 1;
          mesh.add(overlayMesh);
        }
      });

      if (meshes.length === 0) {
        setIsLoading(false);
        return;
      }

      const scaleFactor = 3;
      model.scale.set(scaleFactor, scaleFactor, scaleFactor);
      model.updateMatrixWorld(true);

      const box = new THREE.Box3().setFromObject(model);
      const center = box.getCenter(new THREE.Vector3());

      const headGroup = new THREE.Group();
      headGroup.position.set(0, 0, 0);

      model.position.x = -center.x;
      model.position.y = -center.y;
      model.position.z = -center.z;
      model.rotation.x = 0;
      model.updateMatrixWorld(true);

      headGroup.add(model);

      const finalBox = new THREE.Box3().setFromObject(headGroup);
      scene.add(headGroup);

      sceneData.headModel = headGroup;
      sceneData.outlinePass.selectedObjects = [headGroup];

      const sphere = new THREE.Sphere();
      finalBox.getBoundingSphere(sphere);
      const modelSphereRadius = sphere.radius;

      const fovRad = (camera.fov * Math.PI) / 180;
      const baseDistance = (modelSphereRadius / Math.tan(fovRad / 2)) * 1.2;

      const isMobile = window.innerWidth <= 800;
      const zMult = isMobile ? 1.5 : 1.0;
      const finalZ = baseDistance * zMult;
      const finalY = finalZ * (isMobile ? 0.44 : 0.15);
      const targetY = isMobile ? modelSphereRadius * 1.1 : 0;

      sceneData.cameraBaseZ = finalZ;
      sceneData.cameraBaseY = finalY;
      sceneData.cameraTargetY = targetY;

      camera.position.set(0, finalY, finalZ);
      camera.lookAt(0, targetY, 0);
      camera.updateProjectionMatrix();

      setIsLoading(false);
    },
    undefined,
    (error) => {
      console.error('Error loading model:', error);
      setIsLoading(false);
    });

    // Start animation loop
    animationRef.current = requestAnimationFrame(animateScene);

    return () => {
      window.removeEventListener('pointermove', handlePointer);
      window.removeEventListener('pointerleave', handleLeave);
      window.removeEventListener('resize', handleResize);

      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }

      renderer.dispose();
      composer.dispose();
    };
  }, []);

  return (
    <div
      ref={containerRef}
      className={`relative ${className}`}
      style={{ width: '100%', height: '100%', minHeight: '100vh' }}
    >
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-black/50 z-10">
          <div className="w-8 h-8 border-2 border-blue-400 border-t-transparent rounded-full animate-spin" />
        </div>
      )}
    </div>
  );
}
