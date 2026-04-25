#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;

uniform mat4 uInvMat;

out vec4 fragColor;

void main(void) {

    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5

    vec3 albedo = texture(uSampler, texCoordCorrected).xyz;
    
    fragColor = vec4(pow(albedo, vec3(0.455)),1.0);
}