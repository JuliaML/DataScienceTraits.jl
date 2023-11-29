# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module DataScienceTraitsDistributionsExt

using DataScienceTraits
using Distributions: Distribution

DataScienceTraits.scitype(::Type{<:Distribution}) = DataScienceTraits.Distributional

end
