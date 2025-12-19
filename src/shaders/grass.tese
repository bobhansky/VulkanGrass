#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(quads, equal_spacing, ccw) in;

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// TODO: Declare tessellation evaluation shader inputs and outputs

// Custom per-blade data from TCS
// input data is per control point, not per generated vertex.
layout(location = 0) in vec3 inV0[];    // root of the grass
layout(location = 1) in vec3 inV1[];    
layout(location = 2) in vec3 inV2[];
layout(location = 3) in vec3 inParams[];    // dir, height, width


layout(location = 0) out vec2 outUV;

void main() {
    // Represents the barycentric coordinates of the vertex being generated inside the tessellated patch.
    float u = gl_TessCoord.x;
    float v = gl_TessCoord.y;

	// TODO: Use u and v to parameterize along the grass blade and output positions for each vertex of the grass blade

    float angle = inParams[0].x;          // blade direction in radians
    float height = inParams[0].y;     // blade height
    float width  = inParams[0].z;         // blade width
    
    // bitangent t1
    vec3 dir = normalize( vec3(cos(angle), 0, sin(angle)) );
    vec3 up = vec3(0.0, 1.0, 0.0);

    // quad 
    float halfWidth = width * 0.5;
    vec3 widthOffset = (u - 0.5) * 2.0 * halfWidth * dir;
    // Quad construction
    vec3 heightOffset = v * height * up;
    vec3 worldPos = inV0[0] + widthOffset + heightOffset;
    outUV = vec2(u, v);

    // Final clip-space position
    gl_Position = camera.proj * camera.view * vec4(worldPos, 1.0);
}


/*

TES inputs = per-control-point data
TES execution = per-generated-vertex

*/