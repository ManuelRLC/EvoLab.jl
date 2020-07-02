"""
    uniformMutation(genotype::IntegerGenotype, rng::Random.AbstractRNG,
                         min::Integer, max::Integer, nGens::Integer=1)

documentation
"""
function uniformMutation(genotype::IntegerGenotype, rng::Random.AbstractRNG,
                         min::Integer, max::Integer, nGens::Integer=1)

    if min > max
        min, max = max, min
    end

    indRep = genotype._representation
    genLen = length(indRep)
    mutatedIndRep = Array{Integer}(undef, genLen)

    if nGens > genLen
        nGens = genLen
    end

    indexes = randomIndexSelection(genLen, nGens, rng)

    mutatedIndRep = copy(indRep)
    range = max-min

    for i=1:nGens
        mutatedIndRep[indexes[i]] = (abs(rand(rng, Int64))%range)+1+min
    end

    return IntegerGenotype(mutatedIndRep)
end


"""
function exchangeMutation(genotype::IntegerGenotype, rng::Random.AbstractRNG)::IntegerGenotype

    genLen = length(genotype._representation)
    mutatedIndRep = similar(Bool, genLen)

    indexes = randomIndexSelection(genLen, 2, rng)

    mutatedIndRep = copy(genotype._representation)

    mutatedIndRep[indexes[1]], mutatedIndRep[indexes[2]] =
                    genotype._representation[indexes[2]], genotype._representation[indexes[1]]

    return IntegerGenotype(mutatedIndRep)
end



function scrambleMutation(genotype::IntegerGenotype, rng::Random.AbstractRNG,
                                nGens::Integer)::IntegerGenotype

    genLen = length(genotype._representation)
    mutatedIndRep = similar(Array{eltype(parent1._representation)}, genLen)

    if nGens<2
        nGens=1
    end

    indexes = Array{UInt32}(undef,2)
    indexes[1] = rand(rng, UInt32)%(genLen-nGens+1)+1;
    indexes[2] = indexes[1]+nGens-1;

    mutatedIndRep = copy(genotype._representation)

    range = indexes[2] - indexes[1]+1
    newIndexes = (-1).+(indexes[1].+randomIndexSelection2(range, range, rng))

    for i=1:range
        mutatedIndRep[newIndexes[i]] = genotype._representation[indexes[1]+i-1]
    end


    return IntegerGenotype(mutatedIndRep)
end



function scrambleMutation(genotype::IntegerGenotype, rng::Random.AbstractRNG)::IntegerGenotype

    genLen = length(genotype._representation)
    nGens=rand(rng, UInt32)%(genLen-2)+2
    return scrambleMutation(genotype, convert(Integer, nGens), rng)
end



function inversionMutation(genotype::IntegerGenotype, rng::Random.AbstractRNG,
                            nGens::Integer)::IntegerGenotype

    genLen = length(genotype._representation)
    mutatedIndRep = similar(Array{eltype(parent1._representation)}, genLen)

    if nGens<2
        nGens=1
    end

    indexes = Array{UInt32}(undef,2)
    indexes[1] = rand(rng, UInt32)%(genLen-nGens+1)+1;
    indexes[2] = indexes[1]+nGens-1;

    mutatedIndRep = copy(indRep)

    k = 0;
    for i=indexes[1]:indexes[2]
        mutatedIndRep[indexes[2]-k] = genotype._representation[i]
        k+=1
    end

    return IntegerGenotype(mutatedIndRep)

end



function inversionMutation(genotype::IntegerGenotype,
                                rng::Random.AbstractRNG)::IntegerGenotype

    genLen = length(genotype._representation)
    nGens=rand(rng, UInt32)%(genLen-2)+2
    return inversionMutation(genotype, convert(Integer, nGens), rng)
end



function insertMutation(genotype::IntegerGenotype, rng::Random.AbstractRNG,
                            nGens::Integer)::IntegerGenotype

    genLen = length(indRep)
    mutatedIndRep = similar(Array{eltype(parent1._representation)}, genLen)

    indexes = Array{UInt32}(undef,2)
    indexes[1] = rand(rng, UInt32)%(genLen-nGens+1)+1;
    indexes[2] = indexes[1]+nGens-1;

    range = indexes[2]-indexes[1]+1
    mutatedIndRep = copy(genotype._representation)

    insertPoint = rand(rng, collect(1:(genLen-range)))
    if (insertPoint >= indexes[1])
        insertPoint = insertPoint+range+1
    end

    if insertPoint > indexes[2]
        k = indexes[1]
        for i=indexes[2]+1:insertPoint-1
            mutatedIndRep[k] = genotype._representation[i]
            k=k+1
        end
        k = indexes[1]
        for i=insertPoint-range:insertPoint-1
            mutatedIndRep[i] = genotype._representation[k]
            k=k+1
        end
    else
        k = insertPoint + range
        for i=insertPoint:indexes[1]-1
            mutatedIndRep[k] = genotype._representation[i]
            k=k+1
        end
        k = indexes[1]
        for i=insertPoint:insertPoint+range-1
            mutatedIndRep[i] = genotype._representation[k]
            k=k+1
        end
    end

    return IntegerGenotype(mutatedIndRep)
end



function insertMutation(genotype::IntegerGenotype,
                            rng::Random.AbstractRNG)::IntegerGenotype
    genLen = length(genotype._representation)
    nGens=rand(rng, UInt32)%(genLen-1)+1
    return insertMutation(genotype, convert(Integer, nGens), rng)
end

"""

"""
    getDefaultMutationOp(individualType::DataType)::Tuple{Function, Array}

Returns a default mutation method for each registered individual type. For
`BinaryGenotype`, it is [`standardMutation`](@ref) with a probability of 0.1;
for `IntegerGenotype`, it is [`uniformMutation`](@ref) of one gene within a range of 0:10;
for both `CGPGenotype` and `STGPGenotype` it is [`pointMutation`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`geneMutation`](@ref).
"""
function getDefaultMutationOp(individualType::Type{IntegerGenotype{T}})::Tuple{Function, Array} where T<:Integer
    return uniformMutation, [0, 10]
end # function
