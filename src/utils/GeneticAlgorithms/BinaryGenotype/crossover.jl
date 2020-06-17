function uniformCross(parent1::BinaryGenotype, parent2::BinaryGenotype,
                        rng::Random.AbstractRNG)::Array{BinaryGenotype}

    genLen = length(parent1._representation)
    child1 = BinaryGenotype(similar(Array{Bool}, genLen))
    child2 = BinaryGenotype(similar(Array{Bool}, genLen))



    for i in eachindex(parent1._representation)
        prob = rand(rng)
        if prob > 0.5
            child1._representation[i] = parent1._representation[i]
            child2._representation[i] = parent2._representation[i]
        else
            child1._representation[i] = parent2._representation[i]
            child2._representation[i] = parent1._representation[i]
        end
    end
    return [child1, child2]
end



function kPointCross(parent1::BinaryGenotype, parent2::BinaryGenotype,
                    rng::Random.AbstractRNG, k::Integer=1)::Array{BinaryGenotype}

    if k < 1
        error("k_points ($k) should be greater than 0")
    end

    genLen::UInt16 = length(parent1._representation)
    if k > genLen
        error("k_points ($k) should be minor than the size of the genoytpe ($genLen)")
    end

    child1 = similar(Array{Bool}, genLen)
    child2 = similar(Array{Bool}, genLen)

    points = Array{UInt16}(undef, k+2)
    points[1] = 0x1
    points[end] = genLen

    for i=1:k
        points[i+1] = (rand(rng, UInt16) % genLen)+1
    end

    points = sort(points)

    for i=1:k
        indexes = points[i]:points[i+1]-1
        if isodd(i)
            child1[indexes] = parent1._representation[indexes]
            child2[indexes] = parent2._representation[indexes]
        else
            child1[indexes] = parent2._representation[indexes]
            child2[indexes] = parent1._representation[indexes]
        end
    end

    indexes = points[k+1]:points[k+2]
    if isodd(k)
        child1[indexes] = parent2._representation[indexes]
        child2[indexes] = parent1._representation[indexes]
    else
        child1[indexes] = parent1._representation[indexes]
        child2[indexes] = parent2._representation[indexes]
    end

    return [BinaryGenotype(child1), BinaryGenotype(child2)]
end

function singlePointCross(parent1::BinaryGenotype, parent2::BinaryGenotype,
                            rng::Random.AbstractRNG)::Array{BinaryGenotype}
    kPointCross(parent1, parent2, rng, 1)
end



"""
    getDefaultCrossover(individualType::DataType)::Tuple{Function, Array}

Returns a default crossover method for each registered individual type. For
all `GAGenotype`, it is [`uniformCross`](@ref),
for both `CGPGenotype` and `STGPGenotype` it is [`subtreeCross`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`kPointRecombinationCross`](@ref)
with one crosspoint.
"""
function getDefaultCrossoverOp(individualType::Type{BinaryGenotype})::Tuple{Function, Array}
    return uniformCross, []
end # function
