#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;
uniform sampler2D uSamplerDepthmap;

uniform mat4 uInvMat;

uniform vec3 uPointLightPos;
uniform vec3 uPointLightColor;
uniform vec3 uCameraWorldPos;

out vec4 fragColor;

float calculatePointLighting(vec3 fromPointLight, vec3 normal){
    float dotProd = max( dot(fromPointLight, normal) , 0.);
    float distSq = dot(fromPointLight, fromPointLight);
    return dotProd/distSq;
}

void main(void) {
    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5

    vec3 normalTex = texture(uSampler, texCoordCorrected).xyz;
    vec3 normal = normalize(normalTex*2. - 1.);

    float depthVal = texture(uSamplerDepthmap, texCoordCorrected).r;

    //get from depth and screen position to world position.
    vec4 worldPos = uInvMat * vec4(vTexCoords, -1. + 2.*depthVal, 1.);
    vec3 worldPosXYZ = worldPos.xyz/worldPos.w;
    
    vec3 toLight = uPointLightPos - worldPosXYZ;

    vec3 pointLightContrib = uPointLightColor*calculatePointLighting(toLight, normal);
    vec3 totalLight = pointLightContrib;

    //totalLight = vec3(0.);

    //add specular component. optionally multirender to separate specular lighting acumulation buffer, 
    // initially can just have fixed specular power and strength, apply to all objects.
    // NOTE since currently applying this in regular lighting, albedo will aply, so things will look metallic but with diffuse too (maybe strange)
    vec3 toCamera = uCameraWorldPos - worldPosXYZ;
    vec3 normalizedToLight = normalize(toLight);
    vec3 reflected = 2.*normal*dot(normalizedToLight,normal) - normalizedToLight;
    float dotted = dot(normalize(toCamera), reflected);
    float specPower = 10.;
    //vec3 specColor = vec3(1.);    //TODO pick appropriate strength given specular power (PBR does this automatically)
    float specularAmount = pow(dotted*.5+.501, specPower);
    specularAmount*=4.; //multiply by something to boost highlights. TODO make semi-physical? should boost more for higher specular power

    totalLight += specularAmount*uPointLightColor;

#ifdef HDR
    vec3 hdrified = 1. - exp(-totalLight);
    fragColor = vec4(hdrified,1.0);
#else
    fragColor = vec4(totalLight,1.0);
#endif

}