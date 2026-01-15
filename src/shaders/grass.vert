#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 1, binding = 0) uniform ModelBufferObject {
    mat4 model;
};

// TODO: Declare vertex shader inputs and outputs
layout(location = 0) in vec4 v0;    // v0, dir
layout(location = 1) in vec4 v1;    // v1, height
layout(location = 2) in vec4 v2;    // v2, width
layout(location = 3) in vec4 up;    // up, stiffness   up is always 0,1,0  in this proj

layout(location = 0) out vec4 outV0;
layout(location = 1) out vec4 outV1;
layout(location = 2) out vec4 outV2;
layout(location = 3) out vec4 outUp;


void main() {
	// TODO: Write gl_Position and any other shader outputs

    vec4 worldV0 = model * vec4(v0.xyz, 1.0f);
    vec4 worldV1 = model * vec4(v1.xyz, 1.0f);
    vec4 worldV2 = model * vec4(v2.xyz, 1.0f);
    
   // gl_Position = worldV0;  // Patch control point (arbitrary space)  world space here
    outV0 = vec4(worldV0.xyz, v0.w);
    outV1 = vec4(worldV1.xyz, v1.w);
    outV2 = vec4(worldV2.xyz, v2.w);
    outUp = up;
}
