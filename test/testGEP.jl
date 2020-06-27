
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



"""


clearGenJ()
setIndividualType(CGPGenotype)
setRandomSeed(5198)
setCGPInfo(x, y, nodesFile="src/utils/GeneticProgramming/Canonical/exampleNodesCGP.json")
setStopCondition(maxIterations=50)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(rampedHalfHalfGenerator, popSize = 150, generateOneByOne = false)
setSelector(tournamentSelector, 6, nSelected=10)
setMutationOperator(pointMutation, 0.2, probability=0.2)
setReplacementOperator(replaceWorstIndividuals, eliteSize=10, needsComparison=true)
setExperimentSummary(batchSize=5, printFitness=false)
"""



"""
clearGenJ()
setRandomSeed(5198)
setIndividualType(GEPGenotype)
setGEPInfo(x, y, nodesFile="src/utils/GeneticProgramming/GeneExpressionProgramming/exampleNodesGEP.json")
setStopCondition(maxIterations=500)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
#setSelector(tournamentSelector, 4)
#setCrossoverOperator(kPointRecombinationCross, 2, probability=0.9)
#setMutationOperator(geneMutation, probability=0.2)
#setReplacementOperator(replaceAllPopulation, eliteSize=5)
setExperimentSummary(batchSize=50, printFitness=false)
"""

"""
clearGenJ()
setRandomSeed(5198)
setIndividualType(GEPGenotype)
setGEPInfo(x, y, nodesFile="src/utils/GeneticProgramming/GeneExpressionProgramming/exampleNodesGEP.json")
setStopCondition(maxIterations=100)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(fullGenerator, popSize = 100, generateOneByOne = true)
setSelector(tournamentSelector, 3)
setCrossoverOperator(kPointRecombinationCross, 3, probability=0.9)
setMutationOperator(geneMutation, probability=0.3)
setReplacementOperator(replaceAllPopulation, eliteSize=5)
setExperimentSummary(batchSize=10, printFitness=false)

"""

clearGenJ()
setIndividualType(GEPGenotype)
setRandomSeed(5198)
setGEPInfo(x, y, nodesFile="src/utils/GeneticProgramming/GeneExpressionProgramming/exampleNodesGEP.json")
setStopCondition(maxIterations=50)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(rampedHalfHalfGenerator, popSize = 150, generateOneByOne = false)
setSelector(tournamentSelector, 6, nSelected=10)
setMutationOperator(geneMutation, probability=0.2)
setReplacementOperator(replaceWorstIndividuals, eliteSize=10, needsComparison=true)
setExperimentSummary(batchSize=5, printFitness=false)

val, t, bytes, gctime, memallocs = @timed runExperiment(verbose = false)
println("tiempo: ", t)
println("memoria (bytes): ", bytes)
