"""
    countBinaryOnes(ind::Individual)

documentation
"""
function countBinaryOnes(genotype::BinaryGenotype)
    genotype = genotype._representation
    tam = length(genotype)
    count=0
    for i=1:tam
        if genotype[i]==1
            count+=1
        end
    end
    return count
end # function

"""
    countBinaryOnes(ind::Individual)

documentation
"""
function countBinaryZeros(genotype::BinaryGenotype)
    genotype = genotype._representation
    genLen = length(genotype)
    count=0
    for i=1:genLen
        if genotype[i]==0
            count+=1
        end
    end
    return count
end # function

"""
    llegar50(genotype::IntegerGenotype)

documentation
"""
function llegar50(genotype::IntegerGenotype)
    genotype = genotype._representation
    genLen = length(genotype)
    acc = 0;
    for i=1:genLen
        acc+=genotype[i]
    end
    return abs(acc-50)
end # function


function checkVelocidad(genotype::IntegerGenotype)
    genotype = genotype._representation

    function probar1(iteraciones)

        for i=1:iteraciones
            randomIndexSelection2(genotype[1],genotype[2],rng)
        end

    end

    function probar2(iteraciones)

        for i=1:iteraciones
            randomIndexSelection(genotype[1],genotype[2],rng)
            #randomIndexSelection2(100,75)
        end

    end
    val, a, bytes, gctime, memallocs = @timed probar1(10000)
    val, b, bytes, gctime, memallocs = @timed probar2(10000)

    abs(a-b)
end


function nNodes(canonicalgp::GPGenotype, gpInfo)
    length(canonicalgp._representation)
end
