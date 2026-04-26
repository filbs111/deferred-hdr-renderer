#version 300 es
precision mediump float;

in vec2 vTexCoords;

uniform sampler2D uSampler;
uniform sampler2D uSamplerDepthmap;

uniform mat4 uInvMat;

out vec4 fragColor;

void main(void) {

    vec2 texCoordCorrected = vec2(0.5)+vec2(0.5)*vTexCoords;    //regular 2d texture has centre at 0.5
    
    vec3 normalTex = texture(uSampler, texCoordCorrected).xyz;
    vec3 normal = normalize(normalTex*2. - 1.);


    float light = 0.5+0.5*dot(normalize(normal), vec3(0.,1.,0.));
    vec3 vLight = vec3(light);

    float lightMultiplier = 1.;

    vec3 regularLight = lightMultiplier*vLight;

    regularLight = regularLight*.5;

    vec3 totalLight = regularLight;

#ifdef HDR
    vec3 hdrified = 1. - exp(-totalLight);
    fragColor = vec4(hdrified,1.0);
#else
    fragColor = vec4(totalLight,1.0);
#endif

}