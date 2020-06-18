import Random
using EvoLab

using EvoLab.GP.STGP


patrones = [
    [2, 4],
    [1, 6],
    [8, 2],
    [5, 5],
    [0, 9],
    [12, 4],
    [10, 4],
    [1, 9],
    [8, 3],
    [10, 20],
    [7, 5],
]

x = Array{Int}(undef, 11)
y = Array{Int}(undef, 11)

for i = 1:11
    x[i] = patrones[i][1]
    y[i] = patrones[i][2]
end

clases = [true, true, false, true, true, false, false, true, false, true, false]

function CCR(genotype::STGPGenotype, gpExperimentInfo::STGPInfo, clases::Array{Bool})

    aciertos = 0

    fenotipo = getPhenotype(genotype)

    for i=1:11
        clase_estimada = evalPhenotype(fenotipo, gpExperimentInfo._varValues[i])
        if typeof(clase_estimada) <: Bool
            if clases[i] == clase_estimada
                aciertos += 1
            end
        end
    end

    return (aciertos/11)*100
end


println("hola")
println("hola")
println("hola")
"""
rng = Random.MersenneTwister(142)

setIndividualType(STGPGenotype)
setRNG(rng)
setGPExperimentInfo()

setStopCondition(maxIterations = 50)
setEvaluator([FitnessFunction(CCR, clases, x, y, weight=1)])
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 5)
setCrossoverOperator(subtreeCross, probability = 0.9)
setMutationOperator(onePointMutation, probability = 0.2)
setReplacementOperator(replaceAllPopulation)

genPopulation!(GenJ)
evaluate!(GenJ, GenJ._population)
#phenotype, fenotipo = getPhenotype(GenJ._population[1]._genotype, GenJ._experimentInfo._GPExperimentInfo)
#evaluate!(GenJ, GenJ._population)
#children = onePointCross(GenJ._population[1]._genotype, GenJ._population[2]._genotype, GenJ._experimentInfo._GPExperimentInfo, rng)
#mutated = pointMutation(GenJ._population[1]._genotype, GenJ._experimentInfo._GPExperimentInfo, rng, 0.2)
"""


clearGenJ()
#setAlgorithm(EvoLab.basicExperimentDeep)
setIndividualType(STGPGenotype)
setRandomSeed(2)
setSTGPInfo(x, y, nodesFile="src/utils/GeneticProgramming/StronglyTyped/exampleNodesSTGP.json")
setStopCondition(maxIterations = 50)
setEvaluator([FitnessFunction(CCR, clases, weight=1)])
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 5)
setCrossoverOperator(subtreeCross, probability = 0.9)
setMutationOperator(subtreeMutation, probability = 0.2)
setReplacementOperator(replaceAllPopulation, eliteSize=5)
setExperimentSummary(batchSize=-1, printBestFitness=false)

@time runGenJ(verbose = false)
