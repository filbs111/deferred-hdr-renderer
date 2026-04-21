#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;

out vec4 fragColor;

void main(void) {
    fragColor = texture(uSampler, vec2(0.5)+vec2(0.5)*vTexCoords);    //regular 2d texture has centre at 0.5
}