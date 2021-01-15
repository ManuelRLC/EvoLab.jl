"""
    uniformMutation(genotype::IntegerGenotype, rng::Random.AbstractRNG,
                         min::Integer, max::Integer, nGens::Integer=1)

documentation
"""
function uniformMutation(genotype::RealGenotype, rng::Random.AbstractRNG,
                         min::Real, max::Real, nGens::Integer=1)

    if min > max
        min, max = max, min
    end

    indRep = genotype._representation
    genLen = length(indRep)
    mutatedIndRep = similar(Array{eltype(indRep)}, size(indRep)...)

    if nGens > genLen
        nGens = genLen
    end

    indexes = randomIndexSelection(genLen, nGens, rng)

    mutatedIndRep = copy(indRep)
    range = max-min

    for i=1:nGens
        mutatedIndRep[indexes[i]] = rand(rng)*range+min
    end

    return RealGenotype(mutatedIndRep)
end


"""
    getDefaultMutationOp(individualType::DataType)::Tuple{Function, Array}

Returns a default mutation method for each registered individual type. For
`BinaryGenotype`, it is [`standardMutation`](@ref) with a probability of 0.1;
for `IntegerGenotype`, it is [`uniformMutation`](@ref) of one gene within a range of 0:10;
for both `CGPGenotype` and `STGPGenotype` it is [`pointMutation`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`geneMutation`](@ref).
"""
function getDefaultMutationOp(individualType::Type{RealGenotype{T}})::Tuple{Function, Array} where T<:Real
    return uniformMutation, [-1, 1]
end # function
