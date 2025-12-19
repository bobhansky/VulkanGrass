 #version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// TODO: Declare fragment shader inputs
layout(location = 0) in vec2 inUV;


layout(location = 0) out vec4 outColor;

void main() {
    // TODO: Compute fragment color
    vec3 yellowLight = vec3(0.8, 0.8, 0.0);
    vec3 yellowDark = vec3(0.5, 0.5, 0.0);

    float coef = smoothstep(0.2, 0.5, inUV.y);
    vec3 color = mix(yellowLight, yellowDark, coef);

    outColor = vec4(color, 1.0); 
}
