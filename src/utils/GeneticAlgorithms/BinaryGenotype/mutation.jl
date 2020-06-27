"""
    standardMutation(genotype::BinaryGenotype, rng::Random.AbstractRNG,
                     probability::AbstractFloat = 0.1)::BinaryGenotype

Mutates a **binary individual**, modifying each gene with a `probability`.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::BinaryGenotype`: genotype that will be mutated.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `probability::AbstractFloat`: lower limit for random generation.
"""
function standardMutation(genotype::BinaryGenotype, rng::Random.AbstractRNG,
                          probability::AbstractFloat)::BinaryGenotype

    indRep = genotype._representation
    genLen = length(indRep)
    mutatedIndRep = Array{Bool}(undef, genLen)

    for i=eachindex(mutatedIndRep)
        random = rand(rng)
        if random < probability
            mutatedIndRep[i] = !indRep[i]
        else
            mutatedIndRep[i] = indRep[i]
        end
    end
    return BinaryGenotype(mutatedIndRep)
end # function



"""
    standardMutation(genotype::BinaryGenotype, rng::Random.AbstractRNG,
                     nGens::Integer=1)::BinaryGenotype

Mutates a **binary individual**, modifying a fixed set of genes.

!!! note
    `Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::BinaryGenotype`: genotype that will be mutated.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `nGens::Integer=1`: number of genes of the genotype that will be mutated.
"""
function standardMutation(genotype::BinaryGenotype, rng::Random.AbstractRNG,
                          nGens::Integer=1)::BinaryGenotype

    indRep = genotype._representation
    genLen = length(indRep)
    mutatedIndRep = Array{Bool}(undef, genLen)

    if nGens>50
        indexes = randomIndexSelection2(genLen, nGens, rng)
    else
        indexes = randomIndexSelection(genLen, nGens, rng)
    end

    mutatedIndRep = copy(indRep)

    for i=1:nGens
        mutatedIndRep[i] = !indRep[indexes[i]]
    end

    return BinaryGenotype(mutatedIndRep)
end # function


"""
function exchangeMutation(genotype::BinaryGenotype, rng::Random.AbstractRNG)::BinaryGenotype

    genLen = length(genotype._representation)
    mutatedIndRep = similar(Bool, genLen)

    indexes = randomIndexSelection(genLen, 2, rng)

    mutatedIndRep = copy(genotype._representation)

    mutatedIndRep[indexes[1]], mutatedIndRep[indexes[2]] =
                    genotype._representation[indexes[2]], genotype._representation[indexes[1]]

    return BinaryGenotype(mutatedIndRep)
end



function scrambleMutation(genotype::BinaryGenotype, nGens::Integer,
                                rng::Random.AbstractRNG)::BinaryGenotype

    genLen = length(genotype._representation)
    mutatedIndRep = similar(Bool, genLen)

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


    return BinaryGenotype(mutatedIndRep)
end



function scrambleMutation(genotype::BinaryGenotype, rng::Random.AbstractRNG)::BinaryGenotype

    genLen = length(genotype._representation)
    nGens=rand(rng, UInt32)%(genLen-2)+2
    return scrambleMutation(genotype, convert(Integer, nGens), rng)
end



function inversionMutation(genotype::BinaryGenotype, nGens::Integer,
                            rng::Random.AbstractRNG)::BinaryGenotype

    genLen = length(genotype._representation)
    mutatedIndRep = similar(Bool, genLen)

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

    return BinaryGenotype(mutatedIndRep)

end



function inversionMutation(genotype::BinaryGenotype,
                                rng::Random.AbstractRNG)::BinaryGenotype

    genLen = length(genotype._representation)
    nGens=rand(rng, UInt32)%(genLen-2)+2
    return inversionMutation(genotype, convert(Integer, nGens), rng)
end



function insertMutation(genotype::BinaryGenotype, nGens::Integer,
                            rng::Random.AbstractRNG)::BinaryGenotype

    genLen = length(indRep)
    mutatedIndRep = similar(Bool, genLen)

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

    return BinaryGenotype(mutatedIndRep)
end



function insertMutation(genotype::BinaryGenotype,
                            rng::Random.AbstractRNG)::BinaryGenotype
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
function getDefaultMutationOp(individualType::Type{BinaryGenotype})::Tuple{Function, Array}
    return standardMutation, []
end # function
