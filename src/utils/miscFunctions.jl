function euclideanDistance(point1::Array, point2::Array)

    nVar = length(point1)
    acc = 0
    for i=1:nVar
        acc += (point1[i]-point2[i])^2
    end
    return sqrt(acc)
end

function pairwiseDistance(array1::Array, array2::Array, metric::Function)

    len = size(array1)[2]

    matrix = zeros(len, len)

    for i=1:len
        for j=i+1:len
            matrix[i,j] = euclideanDistance(array1[:, i], array2[:, j])
            matrix[j,i] = matrix[i,j]
        end
    end

    return matrix
end

function getKnearest(row::Array, k::Integer)

    Knearest = collect(1:k)
    len = length(row)

    for i=1:k
        for j=i+1:k
            if row[Knearest[i]] < row[Knearest[j]]
                Knearest[j], Knearest[i] = Knearest[i],  Knearest[j]
            end
        end
    end

    for i=k+1:len
        if row[i] < row[Knearest[1]]
            Knearest[1] = i
            for j=1:k-1
                if row[Knearest[j]] < row[Knearest[j+1]] || break
                    Knearest[j], Knearest[j+1] = Knearest[j+1],  Knearest[j]
                end
            end
        end
    end

    return Knearest
end

function randomIndexSelection(len::Integer, n::Integer, rng::Random.AbstractRNG)

    if n>len
        n = len;
    end

    indexes = Array{UInt32}(undef, n)

    i=1
    while i<=n
        inside = false
        indexes[i] = (rand(rng, UInt32)%len) + 1;
        for j=1:i
            if i!=j
                inside = indexes[i] == indexes[j]
                inside && break
            end
        end
        if !inside
            i+=1
        end
    end
    return indexes
end


function randomIndexSelection2(len::Integer, n::Integer, rng::Random.AbstractRNG)

    if n>len
        n = len;
    end

    indexes = collect(UInt32,1:len)
    selected = Array{UInt32}(undef, n)

    i=1
    for i=1:n
        inside = false
        index = (rand(rng, UInt32)%len) + 1;
        len = len - 1
        selected[i] = indexes[index]
        indexes[index] = indexes[end]
        pop!(indexes)

    end
    return selected
end


function findprevIndexes(predicate::Function, A::Array, i::Integer)
    previous = Array{Integer}(undef, 0)

    while (aux = findprev(predicate, A, i)) != nothing
        push!(previous, aux)
        i -= 1
    end

    return previous
end


function findnextIndexes(predicate::Function, A::Array, i::Integer)
    next = Array{Integer}(undef, 0)

    while (aux = findnext(predicate, A, i)) != nothing
        push!(next, aux)
        i += 1
    end

    return next
end
