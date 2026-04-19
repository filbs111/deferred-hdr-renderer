HDR rendering 


make simple project to render multiple lights

draw spheres with position, radius, colour (with large range of brightness)

draw scene with global exposure control, options for linear* lighting, x/(1+x), 1-exp(-x)   (*NOTE should apply gamma "correction" upon output)

check whether colours look desaturated vs linear. if so, adjust contrast, retaining luma? NOTE shouldn't do this "perfectly" because want bright lights to "white out"...

when have a test scene, 

implement in deferred rendering.
 simple additive/linear lights - easy blending. 
 think 1-exp(-x) version using inverted multiplication 
deferred renderer steps : 
 draw any objects that will be lit (perhaps doesn't include lights themselves) to depth buffer, normals image (can just have 3d normals for now - later compress into 2d)
 draw lighting using depth and normal input. alternative options:
    1. calculate all lights at once (like doing with forward rendering)
    2. a call for each light
    3. bounding object for lights to reduce pixels drawn
    4. instancing on top of 2 or 3.
 draw pure emmisive objects (light bulbs)

could do light accumulation in final screen view. Is this a good fit due to sRGB? 

probably want to acculate light in an intermediate buffer. 

initially do this with linear light accumulation buffer (10 bit per colour?). expect results not great, might see significant banding.
try with sRGB intermediate buffer. 
