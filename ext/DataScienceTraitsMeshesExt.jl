# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module DataScienceTraitsMeshesExt

using DataScienceTraits
using Meshes: Geometry

DataScienceTraits.scitype(::Type{<:Geometry}) = DataScienceTraits.Geometrical

end