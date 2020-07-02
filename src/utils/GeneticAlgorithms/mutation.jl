"""
    exchangeMutation(genotype::GAGenotype, rng::Random.AbstractRNG)

documentation
"""
function exchangeMutation(genotype::GAGenotype, rng::Random.AbstractRNG)

    indRep = genotype._representation
    genLen = length(indRep)
    genRepType = typeof(indRep[1])
    genType = typeof(genotype)
    mutatedIndRep = Array{genRepType}(undef, genLen)

    indexes = randomIndexSelection(genLen, 2, rng)

    mutatedIndRep = copy(indRep)

    mutatedIndRep[indexes[1]], mutatedIndRep[indexes[2]] = indRep[indexes[2]], indRep[indexes[1]]

    return genType(mutatedIndRep)
end


"""
    scrambleMutation(genotype::GAGenotype, rng::Random.AbstractRNG, nGens::Integer)

documentation
"""
function scrambleMutation(genotype::GAGenotype, rng::Random.AbstractRNG, nGens::Integer)

    indRep = genotype._representation
    genLen = length(indRep)
    genRepType = typeof(indRep[1])
    genType = typeof(genotype)
    mutatedIndRep = Array{genRepType}(undef, genLen)

    if nGens<2
        nGens=1
    end

    indexes = Array{UInt32}(undef,2)
    indexes[1] = rand(rng, UInt32)%(genLen-nGens+1)+1;
    indexes[2] = indexes[1]+nGens-1;

    mutatedIndRep = copy(indRep)

    range = indexes[2] - indexes[1]+1
    newIndexes = (-1).+(indexes[1].+randomIndexSelection2(range, range, rng))

    for i=1:range
        mutatedIndRep[newIndexes[i]] = indRep[indexes[1]+i-1]
    end


    return genType(mutatedIndRep)
end


"""
    scrambleMutation(genotype::GAGenotype, rng::Random.AbstractRNG)

documentation
"""
function scrambleMutation(genotype::GAGenotype, rng::Random.AbstractRNG)

    genLen = length(genotype._representation)
    nGens=rand(rng, UInt32)%(genLen-2)+2
    return scrambleMutation(genotype, rng, convert(Integer, nGens))
end


"""
    inversionMutation(genotype::GAGenotype, rng::Random.AbstractRNG, nGens::Integer)

documentation
"""
function inversionMutation(genotype::GAGenotype, rng::Random.AbstractRNG, nGens::Integer)

    indRep = genotype._representation
    genLen = length(indRep)
    genRepType = typeof(indRep[1])
    genType = typeof(genotype)
    mutatedIndRep = Array{genRepType}(undef, genLen)

    if nGens<2
        nGens=1
    end

    indexes = Array{UInt32}(undef,2)
    indexes[1] = rand(rng, UInt32)%(genLen-nGens+1)+1;
    indexes[2] = indexes[1]+nGens-1;

    mutatedIndRep = copy(indRep)

    k = 0;
    for i=indexes[1]:indexes[2]
        mutatedIndRep[indexes[2]-k] = indRep[i]
        k+=1
    end

    return genType(mutatedIndRep)

end


"""
    inversionMutation(genotype::GAGenotype, rng::Random.AbstractRNG)

documentation
"""
function inversionMutation(genotype::GAGenotype, rng::Random.AbstractRNG)
    genLen = length(genotype._representation)
    nGens=rand(rng, UInt32)%(genLen-2)+2
    return inversionMutation(genotype, rng, convert(Integer, nGens))
end


"""
    insertMutation(genotype::GAGenotype, rng::Random.AbstractRNG, nGens::Integer)

documentation
"""
function insertMutation(genotype::GAGenotype, rng::Random.AbstractRNG, nGens::Integer)

    indRep = genotype._representation
    genLen = length(indRep)
    genRepType = typeof(indRep[1])
    genType = typeof(genotype)
    mutatedIndRep = Array{genRepType}(undef, genLen)

    indexes = Array{UInt32}(undef,2)
    indexes[1] = rand(rng, UInt32)%(genLen-nGens+1)+1;
    indexes[2] = indexes[1]+nGens-1;

    range = indexes[2]-indexes[1]+1
    mutatedIndRep = copy(indRep)

    insertPoint = rand(rng, collect(1:(genLen-range)))
    if (insertPoint >= indexes[1])
        insertPoint = insertPoint+range+1
    end

    if insertPoint > indexes[2]
        k = indexes[1]
        for i=indexes[2]+1:insertPoint-1
            mutatedIndRep[k] = indRep[i]
            k=k+1
        end
        k = indexes[1]
        for i=insertPoint-range:insertPoint-1
            mutatedIndRep[i] = indRep[k]
            k=k+1
        end
    else
        k = insertPoint + range
        for i=insertPoint:indexes[1]-1
            mutatedIndRep[k] = indRep[i]
            k=k+1
        end
        k = indexes[1]
        for i=insertPoint:insertPoint+range-1
            mutatedIndRep[i] = indRep[k]
            k=k+1
        end
    end

    return genType(mutatedIndRep)
end


"""
    insertMutation(genotype::GAGenotype, rng::Random.AbstractRNG)

documentation
"""
function insertMutation(genotype::GAGenotype, rng::Random.AbstractRNG)
    genLen = length(genotype._representation)
    nGens=rand(rng, UInt32)%(genLen-1)+1
    return insertMutation(genotype, rng, convert(Integer, nGens))
end
