#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(vertices = 1) out;

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
    vec3 camPos;
} camera;

#define LOD 0

#define MIN_IN_LEVEL 1
#define MAX_IN_LEVEL 20
#define MIN_OUT_LEVEL 2
#define MAX_OUT_LEVEL 20
#define DIS_OFF_SET 2.f
#define MAX_DIS 25.f

// TODO: Declare tessellation control shader inputs and outputs
// array cuz All TCS inputs are per-patch arrays, indexed by control point.
layout(location = 0) in vec3 inV0[];    
layout(location = 1) in vec3 inV1[];
layout(location = 2) in vec3 inV2[];
layout(location = 3) in vec4 inParams[];    // dir, height, width

layout(location = 0) out vec3 outV0[];
layout(location = 1) out vec3 outV1[];
layout(location = 2) out vec3 outV2[];
layout(location = 3) out vec4 outParams[];


void main() {
	// Don't move the origin location of the patch
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    
	// TODO: Write any shader outputs
    // Pass custom per-blade data through
    outV0[gl_InvocationID]     = inV0[gl_InvocationID];
    outV1[gl_InvocationID]     = inV1[gl_InvocationID];
    outV2[gl_InvocationID]     = inV2[gl_InvocationID];
    outParams[gl_InvocationID] = inParams[gl_InvocationID];

	// TODO: Set level of tesselation
    if (gl_InvocationID == 0)
    {

#if LOD
        float dis = distance(camera.camPos, inV0[0]);
        float lerpCoef = clamp(( (dis - DIS_OFF_SET) / MAX_DIS), 0.f, 1.f);
        int inTesLevel = int(mix(MAX_IN_LEVEL, MIN_IN_LEVEL, lerpCoef) + 0.5f);
        int outTesLevel = int(mix(MAX_OUT_LEVEL, MIN_OUT_LEVEL, lerpCoef) + 0.5f);
        gl_TessLevelOuter[0] = outTesLevel;
        gl_TessLevelOuter[1] = outTesLevel;
        gl_TessLevelOuter[2] = outTesLevel;
        gl_TessLevelOuter[3] = outTesLevel;

        gl_TessLevelInner[0] = inTesLevel;
        gl_TessLevelInner[1] = inTesLevel;
#else
        gl_TessLevelOuter[0] = MAX_OUT_LEVEL;
        gl_TessLevelOuter[1] = MAX_OUT_LEVEL;
        gl_TessLevelOuter[2] = MAX_OUT_LEVEL;
        gl_TessLevelOuter[3] = MAX_OUT_LEVEL;

        gl_TessLevelInner[0] = MAX_IN_LEVEL;
        gl_TessLevelInner[1] = MAX_IN_LEVEL;
#endif
    }
}
