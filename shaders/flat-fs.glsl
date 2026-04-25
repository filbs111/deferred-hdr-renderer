#version 300 es
precision mediump float;

out vec4 fragColor;

in vec3 worldPosXYZ;
in vec3 normalCopy;

uniform vec3 uFlatColor;

uniform vec3 uPointLight1Pos;
uniform vec3 uPointLight1Color;
uniform vec3 uPointLight2Pos;
uniform vec3 uPointLight2Color;

float calculatePointLighting(vec3 fromPointLight, vec3 normal){
    float dotProd = max( -dot(fromPointLight, normal) , 0.);
    float distSq = dot(fromPointLight, fromPointLight);
    return dotProd/distSq;
}

void main(void) {
    float light = 0.5+0.5*dot(normalize(normalCopy), vec3(0.,1.,0.));
    vec3 vLight = vec3(light);

    float lightMultiplier = 1.;

    vec3 regularLight = lightMultiplier*vLight;

    regularLight = regularLight*.5;

    vec3 pointLightContrib1 = uPointLight1Color* calculatePointLighting(worldPosXYZ - uPointLight1Pos, normalCopy);
    vec3 pointLightContrib2 = uPointLight2Color* calculatePointLighting(worldPosXYZ - uPointLight2Pos, normalCopy);

    vec3 totalLight = uFlatColor * (regularLight + pointLightContrib1 + pointLightContrib2);

#ifdef HDR
    vec3 hdrified = 1. - exp(-totalLight);
    fragColor = vec4(pow(hdrified, vec3(0.455)),1.0);
#else
    fragColor = vec4(pow(totalLight, vec3(0.455)),1.0);
#endif

}