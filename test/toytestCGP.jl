using EvoLab
using EvoLab.GP.CGP
println("hola")
clearGenJ()
# ExperimentInfo
setIndividualType(CGPGenotype)
setCGPInfo([-2, -1, 0, 1, 2], nodesFile="test/toyNodes.json", maxTreeDepth=3)
setAlgorithm(basicExperiment)
setRandomSeed(412)
# StopCondition
setStopCondition(maxIterations=10)
# Evaluator
setEvaluator([FitnessFunction(compareFunctions, [4, 1, 0, 1, 4], weight=-1)])
# Generator
setGenerator(rampedHalfHalfGenerator, 0.7, popSize=30, generateOneByOne=false)
# Selector
setSelector(tournamentSelector, 3, nSelected=30, needsComparison=true,
            samplingWithRep=false)
# Crossover
setCrossoverOperator(subtreeCross, probability=0.9, nParents=2, nChildren=2)
# Mutation
setMutationOperator(pointMutation, 0.4, probability=0.1)
# Replacement
setReplacementOperator(replaceWorstIndividuals, needsComparison=true,
                       eliteSize=2)
# Summary
setExperimentSummary(batchSize=0, printFitness=false)


runExperiment()
