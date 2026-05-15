#version 300 es
in vec3 aVertexPosition;
in vec3 aVertexNormal;

uniform mat4 uVMatrix;
uniform mat4 uMMatrix;
uniform mat4 uPMatrix;
uniform vec3 uNormalScale;

//TODO put into normal frame with tangent vec etc?
#ifdef WORLDPOS
out vec3 worldPosXYZ;
#endif

out vec3 normalCopy;

#ifdef ALBEDOTEXTURE
#define HASTEXMAP
#endif

#ifdef NORMALMAPTEXTURE

#ifndef HASTEXMAP
#define HASTEXMAP
#endif

    in vec3 aVertexTangent;
    in vec3 aVertexBitangent;
    out vec3 vTangent;
    out vec3 vBitangent;
#endif

#ifdef HASTEXMAP
    in vec2 aTextureCoord;
    out vec2 vTextureCoord;
#endif

void main(void) {

#ifdef HASTEXMAP
    vTextureCoord = aTextureCoord;
#endif

    vec4 transformedPosition = uMMatrix * vec4(aVertexPosition, 1.0);

    gl_Position = uPMatrix * uVMatrix*transformedPosition;

    //NOTE this is wierd because model matrix includes scale!
    // NOTE normalizing vector maybe is wrong for non-uniformly scaled objects. TODO fix, or just use unscaled objects.
    vec3 transformedNormal = (uMMatrix * vec4(aVertexNormal, 0.0)).xyz;
    
#ifdef NORMALMAPTEXTURE
    vec3 transformedTangent = (uMMatrix * vec4(aVertexTangent, 0.0)).xyz;   //TODO extract 3x3 mat from mat4 instead of redundant multiply? 
    vec3 transformedBitangent = (uMMatrix * vec4(aVertexBitangent, 0.0)).xyz;

    normalCopy = cross(transformedTangent, transformedBitangent);   //TODO check signs
    vTangent = cross(transformedBitangent, transformedNormal);
    vBitangent = cross(transformedNormal, transformedTangent);
#else
    normalCopy = uNormalScale*transformedNormal;
#endif

#ifdef WORLDPOS
    worldPosXYZ = transformedPosition.xyz;
#endif
}