#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;
uniform sampler2D uSampler1;
uniform sampler2D uSamplerDepthmap;

uniform mat4 uInvMat;

uniform vec3 uPointLightPos;
uniform vec3 uPointLightColor;

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
    vec3 normal = normalTex*2. - 1.;

    float depthVal = texture(uSamplerDepthmap, texCoordCorrected).r;

    //get from depth and screen position to world position.
    vec4 worldPos = uInvMat * vec4(vTexCoords, -1. + 2.*depthVal, 1.);
    vec3 worldPosXYZ = worldPos.xyz/worldPos.w;
    
    vec3 pointLightContrib = uPointLightColor*calculatePointLighting(worldPosXYZ - uPointLightPos, normal);
    vec3 totalLight = albedo * pointLightContrib;

#ifdef HDR
    vec3 hdrified = 1. - exp(-totalLight);
    fragColor = vec4(hdrified,1.0);
#else
    fragColor = vec4(totalLight,1.0);
#endif

}