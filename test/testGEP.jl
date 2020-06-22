
import Random
using EvoLab
using EvoLab.GP.GEP


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
setAlgorithm(EvoLab.basicExperimentDeep)
setRandomSeed(63)
setIndividualType(GEPGenotype)
setGEPInfo(x, y, nodesFile="src/utils/GeneticProgramming/GeneExpressionProgramming/exampleNodesGEP.json")
setStopCondition(maxIterations=50)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 4)
setCrossoverOperator(kPointRecombinationCross, 2, probability=0.9)
setMutationOperator(geneMutation, probability=0.2)
#setReplacementOperator(replaceWorstIndividuals, eliteSize=5, needsComparison=true)
setReplacementOperator(replaceAllPopulation, eliteSize=2)
setExperimentSummary(batchSize=-1, printBestFitness=false)


@time runExperiment(verbose=false)
