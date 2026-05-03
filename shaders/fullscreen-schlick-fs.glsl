#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler1;
uniform sampler2D uSamplerDepthmap;

uniform mat4 uInvMat;

uniform vec3 uCameraWorldPos;

out vec4 fragColor;

void main(void) {
    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5

    vec3 normalTex = texture(uSampler1, texCoordCorrected).xyz;
    vec3 normal = normalize(normalTex*2. - 1.);

    float depthVal = texture(uSamplerDepthmap, texCoordCorrected).r;

    //get from depth and screen position to world position.
    vec4 worldPos = uInvMat * vec4(vTexCoords, -1. + 2.*depthVal, 1.);
    vec3 worldPosXYZ = worldPos.xyz/worldPos.w;
    
    //add specular component. optionally multirender to separate specular lighting acumulation buffer, 
    // initially can just have fixed specular power and strength, apply to all objects.
    // NOTE since currently applying this in regular lighting, albedo will aply, so things will look metallic but with diffuse too (maybe strange)
    vec3 toCamera = normalize(uCameraWorldPos - worldPosXYZ);
    
//schlick's approximation. NOTE currently this is dependent on view direction relative to macro surface normal, so will be same for all lights!
// if so might write to gbuffer overall glossiness including schlick
// (though possibly should depend on view direction vs microfacet/direction to light)

    float fresnelEffect = pow( 1. - dot(toCamera, normal) , 5.);

    float specularFraction = mix( 0.3, 1., fresnelEffect);  //from some default specular reflection amount for viewing head on to 100% for glancing angle

    fragColor = vec4(vec3(specularFraction),1.0);
}