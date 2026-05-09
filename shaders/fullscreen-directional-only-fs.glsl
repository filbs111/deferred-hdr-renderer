#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;
uniform sampler2D uSamplerDepthmap;

uniform mat4 uInvMat;
uniform vec3 uCameraWorldPos;

out vec4 fragColor;

void main(void) {

    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5
    
    vec4 normalAndRoughness = texture(uSampler, texCoordCorrected);
    vec3 normal = normalize(normalAndRoughness.xyz*2. - 1.);
    float roughness = normalAndRoughness.w;

    vec3 normalizedToLight = vec3(0.,1.,0.);


    float light = 0.5+0.5*dot(normalize(normal), normalizedToLight);
    vec3 vLight = vec3(light);

    float lightMultiplier = 1.;

    vec3 regularLight = lightMultiplier*vLight;

    regularLight = regularLight*.5;

    vec3 totalLight = regularLight;


    //NOTE above is currently like a diffuse hemisphere light - 
    // TODO separate a directional light from hemisphere light shader, add option to use gemi light for approx skybox
    //add specular component. optionally multirender to separate specular lighting acumulation buffer, 
    // initially can just have fixed specular power and strength, apply to all objects.
    //get from depth and screen position to world position.
    float depthVal = texture(uSamplerDepthmap, texCoordCorrected).r;
    vec4 worldPos = uInvMat * vec4(vTexCoords, -1. + 2.*depthVal, 1.);
    vec3 worldPosXYZ = worldPos.xyz/worldPos.w;
    
    
//add specular component. optionally multirender to separate specular lighting acumulation buffer, 
    // initially can just have fixed specular power and strength, apply to all objects.
    // NOTE since currently applying this in regular lighting, albedo will aply, so things will look metallic but with diffuse too (maybe strange)
    vec3 toCamera = normalize(uCameraWorldPos - worldPosXYZ);
    vec3 reflected = 2.*normal*dot(normalizedToLight,normal) - normalizedToLight;
    float dotted = dot(toCamera, reflected);

    float highlightSize = .05 + .8*roughness;   //guess something...
    float specPower = 30./highlightSize;    //TODO what should this be

    //vec3 specColor = vec3(1.);    //TODO pick appropriate strength given specular power (PBR does this automatically)
    float specularAmount = pow(dotted*.5+.501, specPower);
    specularAmount*=.01*specPower*specPower; //multiply by something to boost highlights. TODO make semi-physical? should boost more for higher specular power

    vec3 uPointLightColor = vec3(1.);   //TODO pass in?

    vec3 specularLight = specularAmount*uPointLightColor;


//schlick's approximation. NOTE currently this is dependent on view direction relative to macro surface normal, so will be same for all lights!
// if so might write to gbuffer overall glossiness including schlick
// (though possibly should depend on view direction vs microfacet/direction to light)

    float fresnelEffect = pow( 1. - dot(toCamera, normal) , 5.);
    float specularFraction = mix( 0.1, 1., fresnelEffect);  //from some default specular reflection amount for viewing head on to 100% for glancing angle

    totalLight = mix(totalLight, specularLight, specularFraction);



#ifdef HDR
    vec3 hdrified = 1. - exp(-totalLight);
    fragColor = vec4(hdrified,1.0);
#else
    fragColor = vec4(totalLight,1.0);
#endif

}