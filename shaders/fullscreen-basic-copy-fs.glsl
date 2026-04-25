#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;
uniform sampler2D uSampler1;

uniform mat4 uInvMat;

out vec4 fragColor;

void main(void) {

    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5

    vec3 sampled = texture(uSampler, texCoordCorrected).xyz;

    vec3 albedo = texture(uSampler1, texCoordCorrected).xyz;

    vec3 multiplied = albedo*sampled;

#ifdef HDR
    vec3 hdrified = 1. - exp(-multiplied);
    fragColor = vec4(pow(hdrified, vec3(0.455)),1.0);
#else
    fragColor = vec4(pow(multiplied, vec3(0.455)),1.0);
#endif


}