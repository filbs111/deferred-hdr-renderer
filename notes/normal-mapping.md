# Normal Mapping

want to have normal mapping in deferred renderer

## g-buffer normal storage

for simplicity, currently writing world 3d space normals to g-buffer (instead of screen space normals). However, coulld store these as 2d, assume length 1.

## calculation of normals per object

not yet implemented using normal map for objects. Justd interpolating vertex normals.

could use world space normal maps but this is atypical, would like to be able to detail texture things.

most brainless way to do tangent space normals: create TBN matrix using per-vertex normal, tangent, bitangent attributes, and use to transform tangent space into object space, world space.

### stretched normal maps

Expect not a problem usually so can ignore - if uv map isn't stretched (so du, dv / tangent, bitangent in object space along surface are approx orthogonal, and object is scaled isotropically, 

Would be good to solve so handles exceptions better, shouldn't impact standard case (described above)

For stretched objects, it is said normals should be transformed by the transposed inverse of the transformation matrix used for vectors. https://www.scratchapixel.com/lessons/mathematics-physics-for-computer-graphics/geometry/transforming-normals.html

Can this/similar be used where TBN not SO(3) ? 

### avoiding passing tangent, bitnagent

suspect it's possible to not do this using screen space derivatives of uv coords. End result should be same. Implement straightforward solution first, maybe try to match it using different solution after. Even if works, might be more complex shader. Maybe some synergy with writing camera space normals to g-buffer.


## working

initial implementation/idea.

Pass TBN attributes to vert shader.

Transform TBN to world space using standard transformation matrix.

Make TBN matrix such that each T' is orthogonal to B, N, etc. Can do this by cross product. Is this equivalent to advice to invert and transpose matrix? 




