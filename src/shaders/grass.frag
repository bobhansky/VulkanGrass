 #version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
    vec3 camPos;
} camera;

// TODO: Declare fragment shader inputs
layout(location = 0) in vec2 inUV;


layout(location = 0) out vec4 outColor;

void main() {
    // TODO: Compute fragment color
    vec3 yellowLight = vec3(255 / 255.f, 191 / 255.f, 0.0 / 255.f);
    vec3 yellowDark = vec3(139 / 255.f, 128 / 255.f, 0 / 255.f);


    float coef = smoothstep(0.0, 0.9, inUV.y);
    vec3 color = mix(yellowDark, yellowLight, coef);

    outColor = vec4(color, 1.0); 
}
