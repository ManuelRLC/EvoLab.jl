using EvoLab

using EvoLab.GP.CGP

import Random
println("hola")
println("hola")
println("hola")



f(x, y) = (y/5.5)+x^2

println("hola")
println("hola")
x = collect(-5:0.5:5)
y = collect(0:0.5:10)
nvalues = length(x)
objs = Array{Number}(undef, nvalues)
for i=1:nvalues
    objs[i] = f(x[i], y[i])
end

clearGenJ()
setRandomSeed(54)
setIndividualType(CGPGenotype)
setCGPInfo(x, y, nodesFile="src/utils/GeneticProgramming/Canonical/exampleNodesCGP.json")
setStopCondition(maxIterations=1000)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(rampedHalfHalfGenerator, popSize = 100, generateOneByOne = false)
setSelector(tournamentSelector, 4, nSelected=2)
setCrossoverOperator(subtreeCross, probability=0.9)
setMutationOperator(pointMutation, 0.2, probability=0.1)
setReplacementOperator(replaceWorstIndividuals, needsComparison=true)
setExperimentSummary(printBestFitness=false)

@time runGenJ(verbose=false)
