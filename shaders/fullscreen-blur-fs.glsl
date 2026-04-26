#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;

uniform mat4 uInvMat;

out vec4 fragColor;

void main(void) {

    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5

    float exposure = 1.;
    float blurSize = 10.;

    //average many samples.
    vec2 pixStep = 1.0/vec2(2560.,1440.);    //TODO pass in inverse scale
    vec4 acccumulated4vec = vec4(0.);   //vec4 because storing accumalated weights. Sum of weights will be constant. TODO hard code/pass in
    //simple box blur. TODO gaussian, TODO make efficient (separate horiz, vert, or mip levels...)
    for (int ii=0;ii<10;ii++){
        for (int jj=0;jj<10;jj++){
            float sumsq = pow(float(ii-5), 2.) + pow(float(jj-5), 2.);
            float weighting = exp(-sumsq/blurSize);
            vec3 sampled = texture(uSampler, texCoordCorrected + vec2(ii-5, jj-5)*pixStep).xyz;
            acccumulated4vec+=vec4(sampled, 1.)*weighting;
        }
    }
    vec3 acccumulated = exposure*acccumulated4vec.xyz/acccumulated4vec.w;

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