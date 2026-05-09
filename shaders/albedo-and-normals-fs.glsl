#version 300 es
precision mediump float;

layout (location = 0) out vec4 out_albedo;
layout (location = 1) out vec4 out_normals;

in vec3 worldPosXYZ; //unused
in vec3 normalCopy;

uniform vec3 uFlatColor;

#ifdef ALBEDOTEXTURE
    in vec2 vTextureCoord;
    uniform sampler2D uSampler;
#endif

#ifdef ROUGHNESSTEXTURE
    uniform sampler2D uSamplerRoughness;
#endif

void main(void) {

#ifdef ALBEDOTEXTURE
    vec4 albedo = texture(uSampler, vTextureCoord);
    out_albedo = vec4(uFlatColor,1.0)*albedo;
#else
    out_albedo = vec4(uFlatColor,1.0);
#endif

    vec3 shiftedNormals = vec3(.5) + .5*normalCopy;

#ifdef ROUGHNESSTEXTURE
    float alpha = texture(uSamplerRoughness, vTextureCoord).r;
#else
    float alpha = 1.;
#endif

    out_normals = vec4(shiftedNormals, alpha);
}