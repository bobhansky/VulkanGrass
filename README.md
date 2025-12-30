Vulkan Grass Rendering
==================================
Last update: 12/29/2025
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

### 4. Tessellation Control Shader (TCS) LOD
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

# Perforamance Analysis
TODO
