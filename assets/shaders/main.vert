#version 410 core

// default "plane" is a singularity which will cause this manual clipping test to always succeed for all vertices
//NOTE: this symbolic value should always be passed when you want this manual clipping disabled (cause some drivers might ignore glEnable/glDisable of GL_CLIP_DISTANCEi)
//NOTE: if you ever output a clip distance that isn't enabled, the clipping stage will just ignore the manual test
// reference: https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/gl_ClipDistance.xhtml
// reference: https://prideout.net/clip-planes
uniform vec4 clipPlane0 = vec4(0.0f, 0.0f, 0.0f, 1.0f); // <A, B, C, D> where Ax + By + Cz = D
uniform mat4 modelMat;
uniform mat4 modelView;
uniform mat4 projection;
uniform vec3 lightPos;
uniform float zFar;

layout (location = 0) in vec3 vertex;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 uv;
layout (location = 3) in vec3 colour;

out vec3 N;
out vec3 L;
out vec3 V;
out vec2 UV;
out vec3 COLOUR;

out vec3 sunPosition;
out float viewVecDepth;

out float gl_ClipDistance[1];

//TODO: refactor this shader
void main(void) {

    sunPosition = lightPos;

    UV = uv;

    // Put light in camera space
    vec4 lightCameraSpace = modelView * vec4(lightPos, 1.0f);

    // Put normal in camera space (no non-uniform scaling so we can use just modelView)
    vec4 nCameraSpace = modelView * vec4(normal, 0.0f);
    N = normalize(nCameraSpace.xyz);

    // Transform model and put in camera space
    vec4 pCameraSpace = modelView * vec4(vertex, 1.0f);
    vec3 P = pCameraSpace.xyz;

    float viewVecLength = length(P);
    //TODO: clipping will probably interpolate wrong if I clamp the upper bound, so just remove this clamping when I implement the spherical clipping
    viewVecDepth = clamp(viewVecLength / zFar, 0.0f, 1.0f);

    // Calculate L and V vectors
    L = normalize(lightCameraSpace.xyz - P);
    V = normalize(-P);

    gl_Position = projection * pCameraSpace;

    gl_ClipDistance[0] = dot(modelMat * vec4(vertex, 1.0f), clipPlane0);

    COLOUR = colour;
}
