

"""
    getDefaultCrossover(individualType::DataType)::Tuple{Function, Array}

Returns a default crossover method for each registered individual type. For
all `GAGenotype`, it is [`uniformCross`](@ref),
for both `CGPGenotype` and `STGPGenotype` it is [`subtreeCross`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`kPointRecombinationCross`](@ref)
with one crosspoint.
"""
function getDefaultCrossoverOp(individualType::Type{IntegerGenotype{T}})::Tuple{Function, Array} where T<:Integer
    return uniformCross, []
end # function
