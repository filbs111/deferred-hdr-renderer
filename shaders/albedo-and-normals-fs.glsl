#version 300 es
precision mediump float;

layout (location = 0) out vec4 out_albedo;
layout (location = 1) out vec4 out_normals;

in vec3 normalCopy;

uniform vec3 uFlatColor;

#ifdef ALBEDOTEXTURE
    in vec2 vTextureCoord;
    uniform sampler2D uSampler;
#endif

#ifdef ROUGHNESSTEXTURE
    uniform sampler2D uSamplerRoughness;
#endif

#ifdef NORMALMAPTEXTURE
    uniform sampler2D uSamplerNormal;
    in vec3 vTangent;
    in vec3 vBitangent;
#endif


void main(void) {

#ifdef ALBEDOTEXTURE
    vec4 albedo = texture(uSampler, vTextureCoord);
    out_albedo = vec4(uFlatColor,1.0)*albedo;
#else
    out_albedo = vec4(uFlatColor,1.0);
#endif

#ifdef NORMALMAPTEXTURE
    vec3 nmapSample = texture(uSamplerNormal, vTextureCoord).xyz;
    vec3 normalFromNMap = nmapSample - vec3(.5);

    //multiply normal map normal by TBN to get
    vec3 worldspaceNormal = normalFromNMap.x*vTangent + normalFromNMap.y*vBitangent + normalFromNMap.z*normalCopy;  //TODO use mat3 to multiply?
#else
    vec3 worldspaceNormal = normalCopy;
#endif

    vec3 shiftedNormals = vec3(.5) + .5*normalize(worldspaceNormal);


#ifdef ROUGHNESSTEXTURE
    float alpha = texture(uSamplerRoughness, vTextureCoord).r;
#else
    float alpha = 1.;
#endif

    out_normals = vec4(shiftedNormals, alpha);
}