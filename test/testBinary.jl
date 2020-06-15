@time using EvoLab
using EvoLab.GA.BinaryGA

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

specifiedError(data::Genotype) = nothing

println("")
clearGenJ()
setRandomSeed(5)
setAlgorithm(basicExperiment)
#setAlgorithm(basicExperiment)
setIndividualType(BinaryGenotype)
setStopCondition(maxIterations=1)
setEvaluator(FitnessFunction(countBinaryOnes))
setGenerator(randomBinaryGenerator, 50, popSize = 100)
setSelector(tournamentSelector, 4, samplingWithRep=true)
setCrossoverOperator(uniformCross, nChildren=2)
setMutationOperator(standardMutation, 0.1)
setReplacementOperator(replaceAllPopulation)
#setExperimentSummary(displayFitness=false, displayBestFitness=false,
                     #batchSize=1, printDuringExperiment=true)
@time runGenJ(verbose=false)

"""


mutable struct Poder1
    a::Function
    Poder1() = new()
end

struct Poder2
    a::Function
end


poder1 = Poder1()
poder1.a = GeneticJulia.basicExperiment
poder2 = Poder2(GeneticJulia.basicExperiment)



#@time GeneticJulia.basicExperiment(genj=GeneticJulia.GenJ)


function probar1(iteraciones)

    for i=1:iteraciones
        poder1.a(genj=GeneticJulia.GenJ)
        #@code_llvm poder1.a(genj=GeneticJulia.GenJ)
        #randomIndexSelection2(829,243,rng)
    end

end


function probar2(iteraciones)

    for i=1:iteraciones
        poder2.a(genj=GeneticJulia.GenJ)

    end

end

println("hola")
GeneticJulia.setStopCondition(maxIterations=1)
#@timev probar1(1)
GeneticJulia.setStopCondition(maxIterations=1)
#@timev probar1(1)

#runGenJ(verbose=false)
#genPopulation!(GenJ)





#@time GeneticJulia.GenJ._experimentInfo._algorithm()

#GeneticJulia.setStopCondition(maxIterations=1)
#@time GeneticJulia.basicExperiment()


function probar1(iteraciones)

    for i=1:iteraciones

        #randomIndexSelection2(829,243,rng)
    end

end
"""

"""

function probar2(iteraciones)

    for i=1:iteraciones
        uniformCross2(ind1._genotype, ind2._genotype, getRNG())
    end

end"""


#@time probar1(10000)



"""
genPopulation!(GenJ)

evaluate!(GenJ, GenJ._population) # TODO Tarda mas, revisar

setSelector(tournamentSelector, 20, samplingWithRep=true, nSelected=200)

selected = selectParents(GenJ)

@time offspring = cross(GenJ, selected) # TODO Tarda maxSymbols

offspring = mutate(GenJ, offspring)


evaluate!(GenJ, offspring)

replacePopulation!(GenJ, offspring) # TODO Tarda maxSymbols
"""

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

setIndividualType(BinaryGenotype)
setAlgorithm(SPEA, 20)
setStopCondition(maxIterations=100)
setEvaluator(countBinaryOnes, 1, countBinaryZeros, 1,
             globalFitnessFunction=GeneticJulia.FitnessFunction(GeneticJulia.pareto))
setGenerator(randomBinaryGenerator, 50, popSize = 100)
setSelector(tournamentSelector, 4)
setCrossoverOperator(uniformCross)
setMutationOperator(standardMutation, 0.1)
setReplacementOperator(replaceAllPopulation)

@time GeneticJulia.runGenJ(verbose=false)
"""

"""
#a = GenJ._evaluator._compareFitness([10, 5], [7, 10], 1, 2)

population = genPopulation(GenJ._generator, GenJ._experimentInfo)
evaluate!(GenJ._evaluator, GenJ._experimentInfo, population, GenJ._stopCondition)
weights = getWeights(GenJ._evaluator)



conjunto1 = Array{Individual}(undef, 10)
conjunto2 = [population[2], population[3], population[1]]

launion=(union(conjunto1,conjunto2))


paretoLevel = pareto(population, weights)
"""
