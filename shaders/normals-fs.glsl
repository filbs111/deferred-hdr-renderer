#version 300 es
precision mediump float;

out vec4 fragColor;

in vec3 normalCopy;

#ifdef NORMALMAPTEXTURE
    uniform sampler2D uSamplerNormal;
    in vec2 vTextureCoord;
    in vec3 vTangent;
    in vec3 vBitangent;
#endif


void main(void) {
    
#ifdef NORMALMAPTEXTURE
    vec3 nmapSample = texture(uSamplerNormal, vTextureCoord).xyz;
    vec3 normalFromNMap = nmapSample - vec3(.5);

    //multiply normal map normal by TBN to get
    vec3 worldspaceNormal = normalFromNMap.x*vTangent + normalFromNMap.y*vBitangent + normalFromNMap.z*normalCopy;  //TODO use mat3 to multiply?
        //equivalent: ? 
    //vec3 worldspaceNormal = nmapSample.x*vTangent;
    //worldspaceNormal+=nmapSample.y*vBitangent;
    //worldspaceNormal+=nmapSample.z*normalCopy;

#else
    vec3 worldspaceNormal = normalCopy;

#endif

    vec3 shiftedNormals = vec3(.5) + .5*normalize(worldspaceNormal);
    fragColor = vec4(shiftedNormals,1.0);
}