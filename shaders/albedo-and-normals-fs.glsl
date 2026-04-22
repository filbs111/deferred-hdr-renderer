#version 300 es
precision mediump float;

layout (location = 0) out vec4 out_albedo;
layout (location = 1) out vec4 out_normals;

in vec3 fromPointLight; //unused
in vec3 normalCopy;

uniform vec3 uFlatColor;

void main(void) {
    out_albedo = vec4(uFlatColor,1.0);

    vec3 shiftedNormals = vec3(.5) + .5*normalCopy;
    
    out_normals = vec4(shiftedNormals,1.0);
}