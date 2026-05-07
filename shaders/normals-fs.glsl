#version 300 es
precision mediump float;

out vec4 fragColor;

in vec3 worldPosXYZ; //unused
in vec3 normalCopy;

void main(void) {
    vec3 shiftedNormals = vec3(.5) + .5*normalize(normalCopy);
    
    fragColor = vec4(shiftedNormals,1.0);
}