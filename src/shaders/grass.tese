#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(quads, equal_spacing, ccw) in;

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
    vec3 camPos;
} camera;

// TODO: Declare tessellation evaluation shader inputs and outputs

// Custom per-blade data from TCS
// input data is per control point, not per generated vertex.
layout(location = 0) in vec3 inV0[];    // root of the grass
layout(location = 1) in vec3 inV1[];    
layout(location = 2) in vec3 inV2[];
layout(location = 3) in vec4 inParams[];    // dir, height, width


layout(location = 0) out vec2 outUV;

// The border between these two shapes coef
#define TAU 0.6f

void main() {
    // Represents the barycentric coordinates of the vertex being generated inside the tessellated patch.
    float u = gl_TessCoord.x;
    float v = gl_TessCoord.y;

	// TODO: Use u and v to parameterize along the grass blade and output positions for each vertex of the grass blade

    float angle = inParams[0].x;            // blade direction in radians
    float height = inParams[0].y;           // blade height
    float width  = inParams[0].z * 0.4f;     // blade width
    
    // belows are according to the paper section 6.3
    // I implemented the quad-triangle shape described by the paper
    vec3 t1 = normalize( vec3(cos(angle), 0.f, sin(angle)) ); // bitangent t1
    vec3 up = vec3(0.0f, 1.0f, 0.0f);
    vec3 a = inV0[0] + v * (inV1[0] - inV0[0]);
    vec3 b = inV1[0] + v * (inV2[0] - inV1[0]);
    vec3 c = a + v * (b - a);
    vec3 c0 = c - width * t1;
    vec3 c1 = c + width * t1;

    float t = 0.5f + (u - 0.5f)*(1 - max(v-TAU, 0.f) / (1.f - TAU));
    vec3 p = (1.f - t) * c0 + t * c1;

    outUV = vec2(u, v);

    // Final clip-space position
    gl_Position = camera.proj * camera.view * vec4(p, 1.f);
}


/*

TES inputs = per-control-point data
TES execution = per-generated-vertex

*/