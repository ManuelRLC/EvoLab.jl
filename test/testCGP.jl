using EvoLab
using EvoLab.GP.CGP

import Random
println("hola")
println("hola")
println("hola")
"""
rng = Random.MersenneTwister(6)

setIndividualType(CGPGenotype)
setRNG(rng)
setGPExperimentInfo()
setGenerator(rampedHalfHalfGenerator, popSize = 10, generateOneByOne=false)
genPopulation!(GenJ)
gen1, gen2 = getGenotype(GenJ._population[1]), getGenotype(GenJ._population[6])
phen1 = getPhenotype(gen1)
phen2 = getPhenotype(gen2)
_,_, pointDepth = selectCrossPoint(gen1, rng)
selectCrossPoint(gen2, rng, minDepth=pointDepth, maxDepth=3)
#children = subtreeCross(gen1, gen2, GenJ._experimentInfo._GPExperimentInfo, rng)
#mutatedParent = subtreeMutation(parent1, GenJ._experimentInfo._GPExperimentInfo._functionSet, GenJ._experimentInfo._GPExperimentInfo._terminalSet, 3, GenJ._experimentInfo._rng, canonicalFullGenerator)
#fenotipo = getPhenotype(parent1, GenJ._experimentInfo._GPExperimentInfo)

"""


"""

function nNodes(canonicalgp::GPGenotype, gpInfo)
    length(canonicalgp._representation)
end

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
setIndividualType(CGPGenotype)
setRandomSeed(2)
setCGPInfo(x, y, nodesFile="src/utils/GeneticProgramming/Canonical/exampleNodesCGP.json")
setAlgorithm(SPEA, 10)
setStopCondition(maxIterations=50)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1), FitnessFunction(nNodes, weight=-0.2)],
           globalFitnessFunction=FitnessFunction(pareto), compareFunctionArgs="global")
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 2)
setCrossoverOperator(subtreeCross, probability=0.9)
setMutationOperator(subtreeMutation, probability=0.2)
setReplacementOperator(replaceAllPopulation, eliteSize=5)
setExperimentSummary(batchSize=-1, printBestFitness=false)

@time runGenJ(verbose=false)
"""


f(x, y) = (y/5.5)+x^2

println("hola")
println("hola")
xValues = collect(-5:0.5:5)
yValues = collect(0:0.5:10)
nvalues = length(xValues)
objs = Array{Number}(undef, nvalues)
for i=1:nvalues
    objs[i] = f(xValues[i], yValues[i])
end


clearGenJ()
setIndividualType(CGPGenotype)
#setRandomSeed(5198)
#setRandomSeed(2314)
setRandomSeed(8675)
setCGPInfo(xValues, yValues, nodesFile="src/utils/GeneticProgramming/Canonical/exampleNodesCGP.json")
setStopCondition(maxIterations=500)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(fullGenerator, popSize = 100, generateOneByOne = true)
setExperimentSummary(batchSize=1)

"""



clearGenJ()
setIndividualType(CGPGenotype)
#setRandomSeed(5198)
#setRandomSeed(2314)
setRandomSeed(8675)
setCGPInfo(xValues, yValues, nodesFile="src/utils/GeneticProgramming/Canonical/exampleNodesCGP.json")
setStopCondition(maxIterations=100)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(fullGenerator, popSize = 100, generateOneByOne = true)
setSelector(tournamentSelector, 3)
#setCrossoverOperator(subtreeCross, probability=0.9)
setMutationOperator(pointMutation, 0.2, probability=0.1)
setReplacementOperator(replaceAllPopulation, eliteSize=5)
setExperimentSummary(batchSize=1)
"""

"""
clearGenJ()
setIndividualType(CGPGenotype)
#setRandomSeed(5198)
#setRandomSeed(2314)
setRandomSeed(8675)
setCGPInfo(xValues, yValues, nodesFile="src/utils/GeneticProgramming/Canonical/exampleNodesCGP.json")
setStopCondition(maxIterations=50)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(rampedHalfHalfGenerator, popSize = 150, generateOneByOne = false)
setSelector(tournamentSelector, 6, nSelected=10)
setMutationOperator(pointMutation, 0.2, probability=0.2)
setReplacementOperator(replaceWorstIndividuals, eliteSize=10, needsComparison=true)
setExperimentSummary(batchSize=1)
"""


val, t, bytes, gctime, memallocs = @timed runExperiment(verbose = false)
println("tiempo: ", t)
println("memoria (MB): ", bytes/1000000)

using Plots

myfont = font(13, "cursive")
bestInds = GenJ._experimentInfo._experimentSummary._bestFitnessValues[1, :]

display(plot(collect(1:100), bestInds, titlefont=myfont, tickfont=myfont,
             legendfont=myfont, yguide="Valores de fitness", xguide="Generaciones",
             guidefont=myfont, label="", lw=2))

bestF(x, y) = (x * x) / (81.303 / x) + (x * x + 240.039 / 240.039)
ests = Array{Number}(undef, nvalues)
for i=1:nvalues
    ests[i] = bestF(xValues[i], yValues[i])
end

display(plot(xValues, yValues, ests, titlefont=myfont, tickfont=myfont,
             legendfont=myfont, yguide="Eje Y", xguide="Eje X",
             guidefont=myfont, label="", lw=2))
