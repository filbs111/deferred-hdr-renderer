#version 300 es
precision mediump float;

out vec4 fragColor;

in vec3 worldPosXYZ;
in vec3 normalCopy;

uniform vec3 uFlatColor;

#ifdef ALBEDOTEXTURE
in vec2 vTextureCoord;
uniform sampler2D uSampler;
#endif

void main(void) {

#ifdef ALBEDOTEXTURE
    vec4 albedo = texture(uSampler, vTextureCoord);
    fragColor = vec4(uFlatColor,1.0)*albedo;
#else
    fragColor = vec4(uFlatColor,1.0);
#endif
}