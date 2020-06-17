
using EvoLab
using EvoLab.GA.IntegerGA



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
#include("fitnessFunctions.jl")


setIndividualType(IntegerGenotype{Int64})
setRandomSeed(9)
setStopCondition(maxIterations = 100)
setEvaluator(llegar50, -1)
setGenerator(randomIntegerGenerator, 10, 0, 10, popSize = 100)
setSelector(tournamentSelector, 3, samplingWithRep = true, nSelected = 1.0)
setCrossoverOperator(uniformCross, nChildren = 2)
setMutationOperator(uniformMutation, 0, 10, 1)
setReplacementOperator(replaceAllPopulation)
setExperimentSummary(displayBestFitness=false)
#setExperimentSummary(displayFitness=false, printDuringExperiment=true, outputFile="hola.txt")


@time runGenJ(verbose=false)
