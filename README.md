Vulkan Grass Rendering
==================================
Last update: 12/30/2025
### This is a course project of University of Pennsylvania, CIS 565: GPU Programming and Architecture
### I used the provided base code to start. 
This project is implemented based on the paper:

Jahrmann, and Wimmer. *Responsive real-time grass rendering for general 3D scenes*, 2017

## Test Environment
Windows 11, Intel Core i7 12700h, Nvidia RTX 3060. 16GB RAM.

Visual Studio 2022. Release Mode, app resolution 1920 x 1080

### Demo with all optimizations below.
![Demo](https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/Demo_fullOptm.gif)

## Performance Optimizations
### 1. Orientation Culling
Cull blades that are facing orthogonal to the camera view direction to avoid rendering blade looking like a thin layer
<img src="https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/Demo_Orient.gif" width=600 height=338/>

### 2. Distance Culling
Cull blades that are far from camera (distance projected onto the ground)

<img src="https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/DisCull_1.gif" width=600 height=338/> <img src="https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/DisCull_2.gif" width=600 height=338/>
      <pre>
          Up: Full culling.
          Down: Preserve a portion of grass
      </pre>


### 3. Frustum Culling
Perform frustum culling in Compute shader stage so blades outside the camera view frustum are rejected early. 
<img src="https://github.com/bobhansky/FrustumCullingPerformanceAnalysis/blob/main/resources/fc_show.gif" width=800 height=450/>

Image comes from https://github.com/bobhansky/FrustumCullingPerformanceAnalysis

### 4. Tessellation Control Shader (TCS) Level of Details (LOD)
Use distance-based tessellation LOD in the TCS to reduce subdivision precisions.
<img src="https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/Demo_LOD.gif" width=600 height=338/>
      <pre>
         The farther the camera is, the edgier the grass is, and the less triangles generate.
      </pre>

# Compute and Grass Pipeline:
1. Generate random grass attributes on CPU.
2. Run Compute pipeline (compute shader) for physics simulation and culling. Update them on Shader Storage Buffer Objects (SSBOs).
3. Start Grass Pipeline. Bind culledBladesBuffer SSBO as vertexBuffer as Vertex shader vertex buffer input.
4. Tessellation control shader sets the subdivision levels (Level of Details, LOD) based on distance from grass root to camera.
5. Tessellation evaluation shader populates the actual geometry.
6. Fragment shader for shading.

# Performance Analysis
## Test scene:

<img src="https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/compare_Full.gif" width=600 height=338/> 
<img src="https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/compare_None.gif" width=600 height=338/>
<pre>
    Up: With all optimization (1,2,3,4).
    Down: without any optimazation
</pre>

## Test:
### Case1: without any optimization
      Grass rendered count: 16384      (all blades in the test)
      FPS: 709
### Case2: with Orientation Cull, Distance Cull, Frustum Cull
      Grass rendered count: 7640 
      FPS: 1110
### Case3: with Orientation Cull, Distance Cull, Frustum Cull, and TCS LOD
      Grass rendered count: 7640 
      FPS: 1035
**Settings**   
In Case1 and Case2, In tessellation control shader, **gl_TessLevelOuter** is set to 7, **gl_TessLevelInner** is set to 5.

In Case3, **gl_TessLevelOuter** is interpolated from 2 to 7, **gl_TessLevelInner** is interpolated from 1 to 5, based on distance to camera.

**Result**

![Demo](https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/case123.png)

### Analysis For Case1, 2, 3: 
**Phenomenon:** 
FPS of **Case1** is the least without doubt. 
**Case3** (with LOD) should've intuitively outperformed **Case2** where LOD is disabled, but in this test it didn't.

**Possible reason:** even though the geometry in Case3 is less complex due to LOD, the computations for LOD levels in tessellation control shader 
(distance evaluation, interpolation, and non-uniform tessellation levels) introduce overhead that compensates the geometry reduction benifits, and thus 
result in a slightly worse performance.

The grass geometry is too simple and thus might not suit for LOD. In order to see the benifit of LOD, 3 extra test cases is added below. 

### Case1.1: without any optimization
      Grass rendered count: 16384 
      FPS: 247
### Case2.1: with Orientation Cull, Distance Cull, Frustum Cull
      Grass rendered count: 7640 
      FPS: 473
### Case3.1: with Orientation Cull, Distance Cull, Frustum Cull, and TCS LOD
      Grass rendered count: 7640 
      FPS: 842
**Settings**     
In **Case1.1** and **Case2.1**, **gl_TessLevelOuter** is set to 20, **gl_TessLevelInner** is set to 20.

In **Case3.1**, **gl_TessLevelOuter** is interpolated from 2 to 20, **gl_TessLevelInner** is interpolated from 1 to 20, based on distance to camera.

The purpose is to create a geometrically complex test scene. In real world application, grass doesn't need to be such delicate.

**Result**

![Demo](https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/case123dot1.png)

### Analysis: Geometry and LOD view using RenderDoc:
**Case1.1 and Case 2.1**

![Demo](https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/renderDoc_20in20out_1.png)
<img src="https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/renderDoc_20in20out_2.png" width=800 height=450/> 

Each Blade is formed by excessively many triangle to represent a geometrically complex model.

**Case 3.1**

<img src="https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/renderDoc_1_20in_2_20out_1.png" width=800 height=450/> 

The blade geometry is still complex when it is close to camera.

<img src="https://github.com/bobhansky/VulkanGrass/blob/master/rdmeIMG/renderDoc_1_20in_2_20out_2.png" width=800 height=450/> 

But it degrades into a simple geometry when far away, reducing the number of triangles for geometry generation and shading.
