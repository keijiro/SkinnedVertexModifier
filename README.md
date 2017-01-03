Skinned Mesh Modifier Example
=============================

![gif](http://i.imgur.com/AoAt2bm.gif)

This example shows how to modify vertex positions and recalculate normals of an
animating skinned mesh with a surface shader.

Why modifying vertices is difficult
-----------------------------------

Actually just modifying vertex positions with a surface shader is quite easy
with using a [custom vertex modification function][VertexModifier]. However,
recalculating normals after modification is difficult because usually a vertex
modifier doesn't know positions of their neighbor vertices.

[VertexModifier]: https://docs.unity3d.com/Manual/SL-SurfaceShaderExamples.html

In this example, we use a mesh converter that encodes positions of neighbor
vertices into texture coordinate attributes, so that we can reconstruct the
neighbor vertices in a vertex modifier.

How to reconstruct neighbor vertices
------------------------------------

If a mesh is completely rigid (not skinned), we can simply store positions of
neighbor vertices as 3D texture coodinates. This approach is not enough for
skinned meshes because neighbor vertices will be moved from original positions
by a skin deformation.

Instead of directly storing vertex positions, we transform them from model space
into tangent space and store them into texture coordinate attributes. In a
vertex modifier, we transform them back from tangent space (which is deformed by
skinning) to model space. Although this doesn't reflect accurate defromation
because of skewness of skinning, we can get a fairly good approximation of them.

In this example, we use a further simplification; Assuming that a given skinned
mesh is flat shaded and all vertices are separated (not shared between
triangles). Under this simplification, we can assume that the neighbor vertices
are laying on its tangent plane, and thus we can ignore the normal axis
component.

We use [an editor script][EditorScript] that converts a mesh in build time. It
encodes centroids into UV2 and neighbor vertices into UV3.

[EditorScript]: https://github.com/keijiro/SkinnedVertexModifier/blob/master/Assets/SkinnedVertexModifier/Editor/MeshEditor.cs#L120

Vertex modifier examples
------------------------

### Noise

[Shader source](https://github.com/keijiro/SkinnedVertexModifier/blob/master/Assets/SkinnedVertexModifier/Noise.shader).

This shader modifies vertex positions with gradients of a noise field. It
reconstructs neighbor vertices and applies the same modification to them, then
recalculate the normal of the belonging triangle from the modified vertex
positions. Although this approach is not optimal because the modifier will be
applied to a same vertex for multiple times, it's faster and more
memory-efficient than doing the same operation on the CPU side.

### Shrink

[Shader source](https://github.com/keijiro/SkinnedVertexModifier/blob/master/Assets/SkinnedVertexModifier/Shrink.shader).

This shader modifies vertex positions toward centroid of belonging triangle.
