#### SIMPLE KNAPSACK PROBLEM

using EvoLab
using EvoLab.GA.BinaryGA
using Random
using Plots

struct Knapsack
    maxWeight::Float32
    objectValues::Array{Float32}
    objectWeights::Array{Float32}
end



#objectValues = rand(rng, 20)*5
#objectValues = round.(objectValues, digits = 2)
objectValues = Float32[0.56, 1.84, 1.72, 0.28, 0.6, 0.9, 1.91, 4.08, 1.21, 4.1, 3.35, 2.27, 4.22, 3.4, 3.63, 4.62, 0.33, 5.0, 0.86, 2.1]


#objectWeights = rand(rng, 20).*objectValues*3
#objectWeights = round.(objectWeights, digits = 2)
objectWeights = Float32[0.81, 4.03, 1.76, 0.54, 0.81, 2.63, 2.69, 8.61, 2.76, 0.6, 5.2, 1.26, 7.07, 5.6, 8.46, 0.35, 0.4, 9.33, 1.22, 5.4]

maxWeight = 35.0

knapsack = Knapsack(maxWeight, objectValues, objectWeights)


function knapsackEvaluation(genotype, knapsack)

    weight::Float32 = 0
    value::Float32 = 0
    rep = genotype._representation

    for i=eachindex(rep)
        if rep[i] == 1
            value += knapsack.objectValues[i]
            weight += knapsack.objectWeights[i]
        end
    end
    if weight > knapsack.maxWeight
        value = value-50.0
    end

    return value
end


clearGenJ()
setRandomSeed(5)
setAlgorithm(basicExperiment)
setIndividualType(BinaryGenotype)
setStopCondition(maxIterations=500)
setEvaluator(FitnessFunction(knapsackEvaluation, knapsack, weight=1))
setGenerator(randomBinaryGenerator, 20, popSize = 100)
setSelector(tournamentSelector, 3, samplingWithRep=true)
setCrossoverOperator(singlePointCross, nChildren=2)
#setCrossoverOperator(kPointCross, nChildren=2)
setMutationOperator(standardMutation, 0.05; probability=0.5)
setReplacementOperator(replaceAllPopulation, eliteSize=5)
#setExperimentSummary(displayFitness=false, displayBestFitness=false,
                     #batchSize=1, printDuringExperiment=true)
setExperimentSummary(printBestFitness=true, batchSize=1)
#setExperimentSummary(batchSize=-1)
@time runExperiment(verbose=false)

x = GenJ._experimentInfo._experimentSummary._meanFitness
y = collect(1:500)

plot(y[1:100],x[1,1:100])


x2 = GenJ._experimentInfo._experimentSummary._bestFitnessValues
plot(y[1:200],x2[1,1:200])

println("Best individual is: $(GenJ._experimentInfo._experimentSummary._bestIndividuals[end])")

ind = GenJ._population[EvoLab.getBestIndividual(GenJ._population, GenJ._evaluator._compareFunction)]
