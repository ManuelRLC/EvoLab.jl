include("../base.jl")
using .EvoLab
using .EvoLab.GA.BinaryGA
using .EvoLab.GA.IntegerGA
using .EvoLab.GP.CGP
using Random
#include("algorithms.jl")
#include("fitnessFunctions.jl")

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

function llegar50(genotype::IntegerGenotype)
    genotype = genotype._representation
    genLen = length(genotype)
    acc = 0;
    for i=1:genLen
        acc+=genotype[i]
    end
    return abs(acc-50)
end # function

function nNodes(canonicalgp::GPGenotype, gpInfo)
    length(canonicalgp._representation)
end

function f(x, y)
    (y/5.5)+x^2
end

function g(x, y)
    2*x + y
end

x = collect(-5:0.5:5)
y = collect(0:0.5:10)
nvalues = length(x)
objs1 = Array{Number}(undef, nvalues)
for i=1:nvalues
    objs1[i] = f(x[i], y[i])
end

nvalues = length(x)
objs2 = Array{Number}(undef, nvalues)
for i=1:nvalues
    objs2[i] = g(x[i], y[i])
end

mirng = Random.MersenneTwister(5)

@time experimentos=runGenJ("ECJ/tests/example.json", verbose=false)
