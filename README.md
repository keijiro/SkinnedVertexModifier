Skinned Mesh Modifier Example
=============================

![gif](http://i.imgur.com/AoAt2bm.gif)

This example shows how to modify vertex positions and recalculate normals of an
animating skinned mesh with a surface shader.

Why modifying vertices is difficult
-----------------------------------

Actually just modifying vertex positions with a surface shader is quite easy
with using a [custom vertex modification function][VertexModifier]. However,
recalculating normals after modifications is difficult because usually a vertex
modifier doesn't know positions of their neighboring vertices.

[VertexModifier]: https://docs.unity3d.com/Manual/SL-SurfaceShaderExamples.html

In this example, we use a mesh converter that encodes positions of neighboring
vertices into texture coordinate attributes, so that we can reconstruct the
neighboring vertices in a vertex modifier.

How to reconstruct neighbor vertices
------------------------------------

If a mesh is completely rigid (not skinned), we can simply store the positions
of the neighboring vertices as 3D texture coodinates. This approach is not
enough for skinned meshes because the neighboring vertices will be moved from
the original positions by a skin deformation.

Instead of directly storing the vertex positions, we transform them from the
model space into each tangent space and store them into the texture coordinate
attributes. In a vertex modifier, we can transform them back from each tangent
space (which is deformed by skinning) to the model space. Although this doesn't
reflect the accurate deformations because of skewness of skinning, we can get
fairly good approximations of them.

In this example, we use a further simplification; Assuming that a given skinned
mesh is flat shaded and all vertices are separated (not shared between
triangles). Under this assumption, it's clear that neighboring vertices are
laying on its tangent plane, and thus we can ignore the normal axis component
(it will be always zero).

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

Things to be improved
---------------------

- This example doesn't have a specialized motion vector pass. It introduces
  artifacts when using motion vectors (motion blur, TXAA, etc.).

- This approach is only useful for flat shaded models. If the model is smooth
  shaded, it might be better to recalculate normals with an analytical approach.
