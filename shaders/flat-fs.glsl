#version 300 es
precision mediump float;

out vec4 fragColor;
in vec3 vLightTimesColor;

void main(void) {

    float lightMultiplier = 1.;

#ifdef HDR
    vec3 hdrified = 1. - exp(-lightMultiplier*vLightTimesColor);
    fragColor = vec4(pow(hdrified, vec3(0.455)),1.0);
#else
    fragColor = vec4(pow(lightMultiplier*vLightTimesColor, vec3(0.455)),1.0);
#endif

}