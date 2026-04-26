#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;

uniform mat4 uInvMat;
uniform vec2 uInvSize;
uniform float uExposure;

out vec4 fragColor;

void main(void) {

    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5

    float blurSize = .6;

    //average many samples.
    vec4 acccumulated4vec = vec4(0.);   //vec4 because storing accumalated weights. Sum of weights will be constant. TODO hard code/pass in
    //simple box blur. TODO gaussian, TODO make efficient (separate horiz, vert, or mip levels...)
    int rad = 5;
    for (int ii=0;ii<rad*2;ii++){
        for (int jj=0;jj<rad*2;jj++){
            float sumsq = pow(float(ii-rad), 2.) + pow(float(jj-rad), 2.);
            float weighting = exp(-sumsq/blurSize);
            vec3 sampled = texture(uSampler, texCoordCorrected + vec2(ii-rad, jj-rad)*uInvSize).xyz;
            acccumulated4vec+=vec4(sampled, 1.)*weighting;
        }
    }
    vec3 acccumulated = uExposure*acccumulated4vec.xyz/acccumulated4vec.w;

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