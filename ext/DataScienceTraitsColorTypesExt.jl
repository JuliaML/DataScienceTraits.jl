# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module DataScienceTraitsColorTypesExt

using DataScienceTraits
using ColorTypes

DataScienceTraits.scitype(::Type{<:Colorant}) = DataScienceTraits.Colorful

end
