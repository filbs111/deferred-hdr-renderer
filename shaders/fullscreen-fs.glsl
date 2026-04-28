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
uniform vec3 uCameraWorldPos;

out vec4 fragColor;

float calculatePointLighting(vec3 fromPointLight, vec3 normal){
    float dotProd = max( -dot(fromPointLight, normal) , 0.);
    float distSq = dot(fromPointLight, fromPointLight);
    return dotProd/distSq;
}

float calculateSpecularContribution(vec3 toLight, vec3 normal, vec3 toCamera){
    vec3 normalizedToLight = normalize(toLight);
    vec3 reflected = 2.*normal*dot(normalizedToLight,normal) - normalizedToLight;
    float dotted = dot(normalize(toCamera), reflected);
    float specPower = 10.;
    float specularAmount = pow(dotted*.5+.501, specPower);
    specularAmount*=4.; //multiply by something to boost highlights. TODO make semi-physical? should boost more for higher specular power
    return specularAmount;
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

    float light = 0.5+0.5*dot(normal, vec3(0.,1.,0.));
    vec3 vLight = vec3(light);

    float lightMultiplier = 1.;

    vec3 regularLight = lightMultiplier*vLight;

    regularLight = regularLight*.5;
    
    vec3 toLight1 = uPointLight1Pos - worldPosXYZ;
    vec3 toLight2 = uPointLight2Pos - worldPosXYZ;

    vec3 pointLightContrib1 = uPointLight1Color* calculatePointLighting(-toLight1, normal);
    vec3 pointLightContrib2 = uPointLight2Color* calculatePointLighting(-toLight2, normal);

    vec3 totalLight = regularLight + pointLightContrib1 + pointLightContrib2;


    //add specular component. optionally multirender to separate specular lighting acumulation buffer, 
    // initially can just have fixed specular power and strength, apply to all objects.
    // NOTE since currently applying this in regular lighting, albedo will aply, so things will look metallic but with diffuse too (maybe strange)
    vec3 toCamera = uCameraWorldPos - worldPosXYZ;
    
    totalLight+= calculateSpecularContribution(vec3(0.,1.,0.), normal, toCamera);   //directional light specular
    totalLight+= uPointLight1Color* calculateSpecularContribution(toLight1, normal, toCamera);
    totalLight+= uPointLight2Color* calculateSpecularContribution(toLight2, normal, toCamera);


    totalLight*= uExposure * albedo;

#ifdef HDR
    vec3 hdrified = 1. - exp(-totalLight);
    fragColor = vec4(pow(hdrified, vec3(0.455)),1.0);
#else
    fragColor = vec4(pow(totalLight, vec3(0.455)),1.0);
#endif

    //fragColor = vec4(albedoTex,1.0);    //matches fwd render mode as expected
    //fragColor = vec4(normalTex,1.0);    //matches fwd render mode as expected
}