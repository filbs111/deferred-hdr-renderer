#version 300 es
precision mediump float;

out vec4 fragColor;
in vec3 vLight;

in vec3 fromPointLight;
in vec3 normalCopy;

uniform vec3 uFlatColor;


void main(void) {

    float lightMultiplier = 1.;

    vec3 regularLight = lightMultiplier*vLight;

    regularLight = regularLight*0.;

    float dotProd = max( -dot(fromPointLight, normalCopy) , 0.);
    float distSq = dot(fromPointLight, fromPointLight);

    vec3 pointLightColor = vec3(.5);
    
    vec3 pointLightContrib = pointLightColor*dotProd/distSq;

    vec3 totalLight = uFlatColor * (regularLight + pointLightContrib);

#ifdef HDR
    vec3 hdrified = 1. - exp(-totalLight);
    fragColor = vec4(pow(hdrified, vec3(0.455)),1.0);
#else
    fragColor = vec4(pow(totalLight, vec3(0.455)),1.0);
#endif

}