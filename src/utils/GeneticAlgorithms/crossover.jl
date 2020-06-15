
function uniformCross(parent1::GAGenotype, parent2::GAGenotype, rng::Random.AbstractRNG)

    parent1Rep = parent1._representation
    parent2Rep = parent2._representation
    genLen = length(parent1Rep)
    genRepType = typeof(parent1Rep[1])
    genType = typeof(parent1)

    child1 = Array{genRepType}(undef, genLen)
    child2 = Array{genRepType}(undef, genLen)

    for i=1:genLen
        prob = rand(rng)
        if prob > 0.5
            child1[i] = parent1Rep[i]
            child2[i] = parent2Rep[i]
        else
            child1[i] = parent2Rep[i]
            child2[i] = parent1Rep[i]
        end
    end
    return [genType(child1), genType(child2)]
end



function kPointCross(parent1::GAGenotype, parent2::GAGenotype, rng::Random.AbstractRNG, k::Integer=1)

    if k < 1
        error("k_points ($k) should be greater than 0")
    end

    parent1Rep = parent1._representation
    parent2Rep = parent2._representation
    genLen = length(parent1Rep)
    if k > genLen
        error("k_points ($k) should be minor than the size of the genoytpe ($genLen)")
    end

    genRepType = typeof(parent1Rep[1])
    genType = typeof(parent1)

    child1 = Array{genRepType}(undef, genLen)
    child2 = Array{genRepType}(undef, genLen)

    points = Array{Integer}(undef, k+2)
    points[1] = 1
    points[end] = genLen

    for i=1:k
        points[i+1] = (rand(rng, UInt16) % genLen)+1
    end

    points = sort(points)

    for i=1:k
        indexes = points[i]:points[i+1]-1
        if isodd(i)
            child1[indexes] = parent1Rep[indexes]
            child2[indexes] = parent2Rep[indexes]
        else
            child1[indexes] = parent2Rep[indexes]
            child2[indexes] = parent1Rep[indexes]
        end
    end

    indexes = points[k+1]:points[k+2]
    if isodd(k)
        child1[indexes] = parent2Rep[indexes]
        child2[indexes] = parent1Rep[indexes]
    else
        child1[indexes] = parent1Rep[indexes]
        child2[indexes] = parent2Rep[indexes]
    end

    return [genType(child1), genType(child2)]
end


function singlePointCross(parent1::GAGenotype, parent2::GAGenotype, rng::Random.AbstractRNG)
    kPointCross(parent1, parent2, rng, 1)
end
