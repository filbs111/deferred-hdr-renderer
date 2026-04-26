#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;
uniform sampler2D uSampler1;
uniform sampler2D uSamplerDepthmap;

uniform mat4 uInvMat;
uniform float uExposure;

uniform vec3 uPointLight1Pos;
uniform vec3 uPointLight1Color;
uniform vec3 uPointLight2Pos;
uniform vec3 uPointLight2Color;

out vec4 fragColor;

float calculatePointLighting(vec3 fromPointLight, vec3 normal){
    float dotProd = max( -dot(fromPointLight, normal) , 0.);
    float distSq = dot(fromPointLight, fromPointLight);
    return dotProd/distSq;
}

void main(void) {

    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5

    vec3 albedo = texture(uSampler, texCoordCorrected).xyz;

    vec3 normalTex = texture(uSampler1, texCoordCorrected).xyz;
    vec3 normal = normalize(normalTex*2. - 1.);

    float depthVal = texture(uSamplerDepthmap, texCoordCorrected).r;

    //get from depth and screen position to world position.

    vec4 worldPos = uInvMat * vec4(vTexCoords, -1. + 2.*depthVal, 1.);
    vec3 worldPosXYZ = worldPos.xyz/worldPos.w;

    float light = 0.5+0.5*dot(normalize(normal), vec3(0.,1.,0.));
    vec3 vLight = vec3(light);

    float lightMultiplier = 1.;

    vec3 regularLight = lightMultiplier*vLight;

    regularLight = regularLight*.5;
    
    vec3 pointLightContrib1 = uPointLight1Color* calculatePointLighting(worldPosXYZ - uPointLight1Pos, normal);
    vec3 pointLightContrib2 = uPointLight2Color* calculatePointLighting(worldPosXYZ - uPointLight2Pos, normal);

    vec3 totalLight = uExposure * albedo * (regularLight + pointLightContrib1 + pointLightContrib2);

#ifdef HDR
    vec3 hdrified = 1. - exp(-totalLight);
    fragColor = vec4(pow(hdrified, vec3(0.455)),1.0);
#else
    fragColor = vec4(pow(totalLight, vec3(0.455)),1.0);
#endif

    //fragColor = vec4(albedoTex,1.0);    //matches fwd render mode as expected
    //fragColor = vec4(normalTex,1.0);    //matches fwd render mode as expected
}