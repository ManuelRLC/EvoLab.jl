
"""
    BLXAlpha(parent1::GAGenotype, parent2::GAGenotype, rng::Random.AbstractRNG,
                      alpha::Float64=0.5)
TODO
"""
function BLXAlpha(parent1::RealGenotype, parent2::RealGenotype, rng::Random.AbstractRNG,
                  alpha::Float64=0.5)

    parent1Rep = parent1._representation
    parent2Rep = parent2._representation
    genLen = length(parent1Rep)
    genRepType = eltype(parent1Rep)
    genType = typeof(parent1)


    child1 = similar(Array{genRepType}, size(parent1Rep)...)
    child2 = similar(Array{genRepType}, size(parent2Rep)...)

    for i=1:genLen
        prob = rand(rng)
        I = abs(parent1Rep[i]-parent2Rep[i])
        minVal, maxVal = minmax(parent1Rep[i], parent2Rep[i])
        inferior = (minVal-I*alpha)
        interval = maxVal+I*alpha - inferior

        child1[i] = rand(rng)*interval+inferior
        child2[i] = rand(rng)*interval+inferior
    end

    return [genType(child1), genType(child2)]
end


"""
    getDefaultCrossover(individualType::DataType)::Tuple{Function, Array}

Returns a default crossover method for each registered individual type. For
all `GAGenotype`, it is [`uniformCross`](@ref),
for both `CGPGenotype` and `STGPGenotype` it is [`subtreeCross`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`kPointRecombinationCross`](@ref)
with one crosspoint.
"""
function getDefaultCrossoverOp(individualType::Type{RealGenotype{T}})::Tuple{Function, Array} where T<:RealGenotype
    return BLXAlpha, []
end # function
