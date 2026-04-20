#version 300 es
in vec3 aVertexPosition;
in vec3 aVertexNormal;

uniform mat4 uVMatrix;
uniform mat4 uMMatrix;
uniform mat4 uPMatrix;

out vec3 vLight;

//TODO put into normal frame with tangent vec etc? 
out vec3 fromPointLight;
out vec3 normalCopy;


void main(void) {

    vec4 transformedPosition = uMMatrix * vec4(aVertexPosition, 1.0);

    gl_Position = uPMatrix * uVMatrix*transformedPosition;

    //NOTE this is wierd because model matrix includes scale!
    // NOTE normalizing vector maybe is wrong for non-uniformly scaled objects. TODO fix, or just use unscaled objects.
    vec4 transformedNormal = (uMMatrix * vec4(aVertexNormal, 0.0));
    float light = 0.5+0.5*dot(normalize(transformedNormal), vec4(0.,1.,0.,0.));
    
    vLight = vec3(light);


    normalCopy = transformedNormal.xyz;
    vec3 light1Pos = vec3(0.,-2.,-4.7);
    fromPointLight = transformedPosition.xyz - light1Pos;
}