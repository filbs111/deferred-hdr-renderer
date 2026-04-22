#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;
uniform sampler2D uSampler1;
uniform sampler2D uSamplerDepthmap;

uniform mat4 uInvMat;

out vec4 fragColor;

void main(void) {

    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5

    vec3 albedoTex = texture(uSampler, texCoordCorrected).xyz;
    vec3 albedo = pow(albedoTex, vec3(1.));


//albedo = vec3(1.);  //override

    vec3 normalTex = texture(uSampler1, texCoordCorrected).xyz;

    vec3 normal = normalTex*2. - 1.;

    float depthVal = texture(uSamplerDepthmap, texCoordCorrected).r;

    //get from depth and screen position to world position.

    vec4 worldPos = uInvMat * vec4(vTexCoords, -1. + 2.*depthVal, 1.);
    vec3 worldPosXYZ = worldPos.xyz/worldPos.w;

    vec3 light1Pos = vec3(0.,-2.,-4.7);

    vec3 fromPointLight = worldPosXYZ - light1Pos;



    float light = 0.5+0.5*dot(normalize(normal), vec3(0.,1.,0.));
    vec3 vLight = vec3(light);

    float lightMultiplier = 1.;

    vec3 regularLight = lightMultiplier*vLight;

    regularLight = regularLight*.5;

    float dotProd = max( -dot(fromPointLight, normal) , 0.);
    float distSq = dot(fromPointLight, fromPointLight);

    vec3 pointLightColor = vec3(.5);
    
    vec3 pointLightContrib = pointLightColor*dotProd/distSq;

    vec3 totalLight = albedo * (regularLight + pointLightContrib);



#ifdef HDR
    vec3 hdrified = 1. - exp(-totalLight);
    fragColor = vec4(pow(hdrified, vec3(0.455)),1.0);
#else
    fragColor = vec4(pow(totalLight, vec3(0.455)),1.0);
#endif


    //fragColor = vec4(albedoTex,1.0);    //matches fwd render mode as expected
    //fragColor = vec4(normalTex,1.0);    //matches fwd render mode as expected

}