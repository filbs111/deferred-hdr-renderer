#version 300 es
precision mediump float;

out vec4 fragColor;

in vec3 worldPosXYZ;
in vec3 normalCopy;

uniform vec3 uFlatColor;


void main(void) {
    fragColor = vec4(uFlatColor,1.0);
}