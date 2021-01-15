"""
    clearExperiment()

Reset all the information for code users.

See also: [`GenJulia`](@ref)
"""
function clearGenJ()
    global GenJ = GenJulia()
    global GenJ._experimentInfo = ExperimentInfo()
    global GenJ._experimentInfo._randomSeed = 1234
    global GenJ._experimentInfo._rng = Random.GLOBAL_RNG

    return nothing
end # function
export clearGenJ



"""
    resetConditions(genj::GenJulia)

Reset all the stop conditions of the experiment.

# Arguments
- `genj::GenJulia`: the main structure, which specifies all the stop conditions.

See also: [`setStopCondition`](@ref)
"""
function resetConditions(genj::GenJulia)
    resetConditions_(genj._stopCondition)
end # function



"""
    genPopulation!(genj::GenJulia)

Generates the initial population if it has not been previously generated. If it
has already been generated from a previous experiment, it does nothing. This is
to continue evolving a previously evolved population.

# Arguments
- `genj::GenJulia`: the main structure, which specifies the generation method
    and its arguments, if any.

See also: [`setGenerator`](@ref)
"""
function genPopulation!(genj::GenJulia)

    if !isdefined(genj, :_population)
        genj._population = genPopulation_(genj._generator, genj._experimentInfo)
    end

end # function
export genPopulation!



"""
    evaluate!(genj::GenJulia, population::Array{Individual})

Evaluates the fitness of the individuals of a population and sets their values.

# Arguments
- `genj::GenJulia`: the main structure, which contains the Evaluator that
    specifies the fitness functions to evaluate for each individual.
- `population::Array{Individual}`: the population that is going to be evaluated.

See also: [`setEvaluator`](@ref)
"""
function evaluate!(genj::GenJulia, population::Array{Individual})
    evaluate!_(genj._evaluator, genj._experimentInfo, population, genj._stopCondition)
end # function
export evaluate!



"""
    selectParents(genj::GenJulia)

Selects a set of individuals of the population.

# Arguments
- `genj::GenJulia`: the main structure, which specifies the selection method,
    its arguments, if any, and the number of individuals to select.

# Returns
The set of selected individuals.

See also: [`setSelector`](@ref)
"""
function selectParents(genj::GenJulia)
    selectParents_(genj._selector, genj._population, genj._evaluator, genj._experimentInfo._rng)
end # function



"""
    selectParents(genj::GenJulia, population::Array{Individual})

Selects a set of individuals of a population.

# Arguments
- `genj::GenJulia`: the main structure, which specifies the selection method,
    its arguments, if any, and the number of individuals to select.
- `population::Array{Individual}`: the population from which individuals are
    going to be selected.

# Returns
The set of selected individuals.

See also: [`setSelector`](@ref)
"""
function selectParents(genj::GenJulia, population::Array{Individual})
    selectParents_(genj._selector, population, genj._evaluator, genj._experimentInfo._rng)
end # function
export selectParentss



"""
    cross(genj::GenJulia, selected::Array{Individual})

Performs a crossover method between a set of selected individuals. If crossover
probability is set to 0, it returns the selected individuals unchanged.

# Arguments
- `genj::GenJulia`: the main structure, which specifies the crossover method,
    its arguments, if any, the number of parents it takes and the number of children
    it returns.
- `selected::Array{Individual}`: the selected individuals that are going to
    be crossed one another.

# Returns
The offspring after crossing the selected individuals. The selected individuals
unchanged if crossover probability equals 0.

See also: [`setCrossoverOperator`](@ref)
"""
function cross(genj::GenJulia, selected::Array{Individual})
    if genj._crossoverOp._probability > 0.0
        return cross_(genj._crossoverOp, selected, genj._experimentInfo)
    else
        return selected
    end
end # function
export cross



"""
    cross(genj::GenJulia, selected::Array{Individual})

Performs a mutation method over a set of selected individuals. If mutation
probability is set to 0, it returns the selected individuals unchanged.

# Arguments
- `genj::GenJulia`: the main structure, which specifies the mutation method
    and its arguments, if any.
- `selected::Array{Individual}`: the selected individuals that are going to
    be mutated.

# Returns
The mutated offspring. The selected individuals unchanged if mutation
probability equals 0.

See also: [`setMutationOperator`](@ref)
"""
function mutate(genj::GenJulia, offspring::Array{Individual})
    if genj._mutationOp._probability > 0.0
        mutate_(genj._mutationOp, offspring, genj._experimentInfo)
    else
        return offspring
    end
end # function
export mutate



"""
    replacePopulation!(genj::GenJulia, offspring::Array{Individual})

Replaces the population selecting individuals from the current population and its
offspring according to a criterium.

# Arguments
- `genj::GenJulia`: the main structure, which specifies the replacement method
    and its arguments, if any.
- `offspring::Array{Individual}`: the individuals that resulted from crossover and
    mutation operations.

See also: [`setReplacementOperator`](@ref)
"""
function replacePopulation!(genj::GenJulia, offspring::Array{Individual})
    genj._population = replacePopulation_(genj._replacementOp, genj._population,
        offspring, genj._evaluator, genj._experimentInfo)
end # function
export replacePopulation!



"""
    reached(genj::GenJulia)

Checks if any of the stop conditions has been fulfilled.

# Arguments
- `genj::GenJulia`: the main structure, which contains the stop conditions.

# Returns
`true` if any of the stop conditions has been fulfilled, `false` otherwise.

See also: [`setStopCondition`](@ref)
"""
function reached(genj::GenJulia)

    if reached_(genj._stopCondition)
        return true
    else

        if genj._stopCondition._maxIterations < typemax(Int64)
            notifyIteration(genj._stopCondition)
        end

        if genj._stopCondition._maxIterNotImproving < typemax(Int64)

            currentBestIndividual = genj._population[getBestIndividual(genj._population, genj._evaluator._compareFunction)[1]]

            if !(genj._evaluator._compareFunction(currentBestIndividual, genj._stopCondition._bestIndividual))
                notifyIterNotImproving(genj._stopCondition)
            else
                genj._stopCondition._bestIndividual = currentBestIndividual
                resetIterNotImproving(genj._stopCondition)
            end
        end

        return false
    end
end # function
export reached



"""
    initTime(genj::GenJulia)

Initiates the timer.

# Arguments
- `genj::GenJulia`: the main structure, which contains the time as a stop condition.

See also: [`setStopCondition`](@ref), [`reached`](@ref)
"""
function initTime(genj::GenJulia)
    if genj._stopCondition._maxTime != Inf
        setTime(genj._stopCondition, time())
    end
end # function
export initTime



"""
    initBestIndividual(genj::GenJulia)

Sets the best individual of the current population.

# Arguments
- `genj::GenJulia`: the main structure.

See also: [`setStopCondition`](@ref), [`reached`](@ref)
"""
function initBestIndividual(genj::GenJulia)
    if genj._stopCondition._maxIterNotImproving != typemax(Int64)
        genj._stopCondition._bestIndividual = genj._population[getBestIndividual(genj._population, genj._evaluator._compareFunction)[1]]
    end
end # function
export initBestIndividual



"""
    getBestIndividual(genj::GenJulia, n::Integer = 1)

Returns the indexes of the best individuals of the population.

# Arguments
- `genj::GenJulia`: the main structure.
- `n::Integer = 1`: number of best individuals to be returned.
"""
function getBestIndividual(genj::GenJulia, n::Integer = 1)
    return getBestIndividual(genj._population, genj._evaluator._compareFunction, n)
end # function
export getBestIndividual



"""
    saveResults(genj::GenJulia)

documentation
"""
function saveResults(genj::GenJulia)
    if isdefined(genj._experimentInfo, :_experimentSummary)
        batchSize = getBatchSize(genj._experimentInfo._experimentSummary)
        currIter = getCurrentIteration(genj._stopCondition)

        if (batchSize == 0 && reached_(genj._stopCondition)) || currIter%batchSize == 0

            if displayFitness(genj._experimentInfo._experimentSummary)
                saveFitness(genj._experimentInfo._experimentSummary,
                            getFitness(genj._population),
                            currIter, getGlobalFitness(genj._population))

            end

            if displayBestFitness(genj._experimentInfo._experimentSummary)

                bestIndividual = genj._population[getBestIndividual(genj)[1]]
                bestFitness = getFitness(bestIndividual)
                bestGenotype = getGenotype(bestIndividual)

                if typeof(bestGenotype) <: GEGenotype
                    bestRep = getRepresentation(genj._experimentInfo._GPExperimentInfo, bestGenotype)
                elseif typeof(bestGenotype) <: Array
                    bestRep = getRepresentation(bestGenotype)
                else
                    bestRep = []
                end

                saveBestFitness(genj._experimentInfo._experimentSummary,
                                bestFitness, bestRep,
                                currIter, getGlobalFitness(bestIndividual))

            end

            if displayMeanFitness(genj._experimentInfo._experimentSummary)
                saveMeanFitness(genj._experimentInfo._experimentSummary,
                                getFitness(genj._population),
                                currIter, getGlobalFitness(genj._population))
            end

            if displayVARFitness(genj._experimentInfo._experimentSummary)
                saveVARFitness(genj._experimentInfo._experimentSummary,
                                getFitness(genj._population),
                                currIter, getGlobalFitness(genj._population))
            end

            if printDuringExperiment(genj._experimentInfo._experimentSummary)

                outputFile = getOutputFile(genj._experimentInfo._experimentSummary)

                io = outputFile != "" ? open(outputFile, "a") : Base.stdout
                flush(io)

                println(io, "GENERATION ", currIter, ":")
                println(io)

                io == Base.stdout || close(io)

                printLastResults(genj, currIter)

                println(io, "============================")
                println(io)
                println(io)

                io == Base.stdout || close(io)
            end
        end
    end

    return nothing
end # function
export saveResults
