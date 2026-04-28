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
    
    vec3 normalTex = texture(uSampler, texCoordCorrected).xyz;
    vec3 normal = normalize(normalTex*2. - 1.);

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
    
    vec3 toCamera = uCameraWorldPos - worldPosXYZ;
    vec3 reflected = 2.*normal*dot(normalizedToLight,normal) - normalizedToLight;
    float dotted = dot(normalize(toCamera), reflected);
    float specPower = 10.;
    //vec3 specColor = vec3(1.);    //TODO pick appropriate strength given specular power (PBR does this automatically)
    float specularAmount = pow(dotted*.5+.501, specPower);
    specularAmount*=4.; //multiply by something to boost highlights. TODO make semi-physical? should boost more for higher specular power

    totalLight += specularAmount;   //TODO multiply by directional light colour


#ifdef HDR
    vec3 hdrified = 1. - exp(-totalLight);
    fragColor = vec4(hdrified,1.0);
#else
    fragColor = vec4(totalLight,1.0);
#endif

}