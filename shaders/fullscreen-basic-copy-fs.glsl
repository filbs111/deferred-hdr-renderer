#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;

uniform mat4 uInvMat;
uniform float uExposure;

out vec4 fragColor;

void main(void) {

    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5

    vec3 sampled = uExposure*texture(uSampler, texCoordCorrected).xyz;

#ifdef HDR
    vec3 preGamma = 1. - exp(-sampled);
#else
    vec3 preGamma = sampled;
#endif

#ifdef APPLY_GAMMA_CORRECTION
    fragColor = vec4(pow(preGamma, vec3(0.455)),1.0);
#else
    fragColor = vec4(preGamma,1.0);
#endif

}