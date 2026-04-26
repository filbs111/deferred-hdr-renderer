#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;

uniform mat4 uInvMat;

out vec4 fragColor;

void main(void) {

    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5

    //average many samples.
    vec2 pixStep = vec2(0.001,0.001);    //TODO pass in inverse scale
    vec3 acccumulated = vec3(0.);
    //simple box blur. TODO gaussian, TODO make efficient (separate horiz, vert, or mip levels...)
    for (int ii=0;ii<10;ii++){
        for (int jj=0;jj<10;jj++){
            vec3 sampled = texture(uSampler, texCoordCorrected + vec2(ii-5, jj-5)*pixStep).xyz;
            acccumulated+=sampled;
        }
    }
    float numSamples = 10.*10.;
    acccumulated/=vec3(numSamples);

#ifdef HDR
    vec3 preGamma = 1. - exp(-acccumulated);
#else
    vec3 preGamma = acccumulated;
#endif

#ifdef APPLY_GAMMA_CORRECTION
    fragColor = vec4(pow(preGamma, vec3(0.455)),1.0);
#else
    fragColor = vec4(preGamma,1.0);
#endif

}