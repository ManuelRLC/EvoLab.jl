"
`FitnessFunction` represents a fitness function that is going to be evaluated
over the individuals of a population.

# Fields
- `_fitnessFunction::Function`: the actual function that is going to be run.
- `_varArgs::Array`: arguments of the fitness function (if any).
- `_weight::Float32`: the weight of the fitness value. If this value is positive,
    the fitness function will be maximized, if it is negative, the fitness
    function will be minimized.

Several considerations must be taken in order to create a fitness function.

Every fitness function must **always** recieve the individual's genotype as its
first argument. If the function needs other arguments besides the genotype, they
are specified in the `_varArgs` field of the fitness function (see Fields). The
user does **not** need to specify the genotype as one of the fitness function
arguments, as the system already knows it is one of them. Here is an example of
how to create a `FitnessFunction` instance:

```jldoctest
julia> function countBinaryOnes(genotype::BinaryGenotype)
    representation = getRepresentation(genotype)
    tam = length(representation)
    fitness = 0
    for i=1:tam
        if representation[i] == 1
            fitness += 1
        end
    end
    return fitness
end
countBinaryOnes (generic function with 1 method)

julia> FitnessFunction(countBinaryOnes)
FitnessFunction(countBinaryOnes, Any[], 1.0)
```

A `FitnessFunction` instance has been created with `countBinaryOnes` as the
actual function, which receives two arguments (2 and 0.5), and a weight of -1.0,
so it is to be minimized. Notice that, in order to get the actual representation
of the genotype (which is BinaryGenotype), [`getRepresentation`](@ref) function
is called, which returns in this case an array of Bool.

If it is a Genetic Programming problem, the fitness functions must receive
another mandatory argument as their second argument, even if they do not use it,
which is the information about the GP experiment (see [`GPExperimentInfo`](@ref)).
Again, the user does **not** need to specify de GP experiment information as one
of the fitness function arguments. Here is an example of how to create a fitness
function for a GP problem:

```jldoctest
julia> function myFitnessFunction(genotype::STGPGenotype, gpExperimentInfo::STGPInfo, arg1, arg2, arg3)
    #···Code···
    return fitness
end
myFitnessFunction (generic function with 1 method)

julia> FitnessFunction(myFitnessFunction, [1,0,0,1], [5,2,6,1], [6,7,2,1], weight=2)
FitnessFunction(myFitnessFunction, Any[[1,0,0,1], [5,2,6,1], [6,7,2,1]], 2.0)
```

Here, a `FitnessFunction` instance has been created with `myFitnessFunction` as the
actual function, which receives three arrays as arguments, and a weight of 2.0,
so it is to be maximized and it weights twice as much.

For the GP case, the obtention of the genotype's representation can be most of
the time meaningless, so the user might want to obtain the phenotype instead.
The user can obtain the phenotype right from the genotype by calling the
[`getPhenotype`](@ref) function (click to see documentation), and once they
get the phenotype, it can be evaluated by calling the [`evaluate`](@ref) function
(click to see documentation), which returns the result of the phenotype for a
specific set of values. In this example, a fitness function for a STGP problem
that creates decision trees for binary classification is shown:

```jldoctest
julia> function CCR(genotype::STGPGenotype, gpExperimentInfo::STGPInfo, classes::Array{Bool}, xValues::Array{Int64}, yValues::Array{Int64})

    rightGuesses = 0
    phenotype = getPhenotype(genotype); #Obtains the phenotype
    nValues = length(xValues)

    for i=1:nValues
        # Evaluates the phenotype for a set of the values of the variables x and y
        estimated_class = evaluate(phenotype, getVariables(gpExperimentInfo), xValues[i], yValues[i])
        if typeof(estimated_class) <: Bool
            if classes[i] == estimated_class
                rightGuesses += 1
            end
        end
    end

    # Calculates CCR, which is the fitness value of the individual
    fitness = (rightGuesses/nValues)*100
    return fitness
end
CCR (generic function with 1 method)

julia> classes = [true, true, false, true]
4-element Array{Bool,1}:
[...]

julia> xValues = [2, 1, 8, 5]
4-element Array{Bool,1}:
[...]

julia> yValues = [4, 6, 2, 5]
4-element Array{Bool,1}:
[...]

julia> FitnessFunction(CCR, classes, xValues, yValues, weight=1)
FitnessFunction(CCR, Any[Bool[1, 1, 0, 1], [2, 1, 8, 5], [4, 6, 2, 5]], 1.0)
```

As the reader can already guess, the fitness of the individuals of the population
will be their CCR, which is the number of patterns correctly classified. In order
to do so, we have created a fitness function that receives the mandatory arguments,
which are the individual's genotype and the GP experiment information, and, in
addition, it also receives the true classes and the values for the two variable
nodes of the problem, which are \"x\" and \"y\".

To evaluate the code generated from a GP individual, first, the user shall obtain
its phenotype, which is the Julia code translated from a GP tree. Then, the user
can evaluate the phenotype using the actual values as it is shown in the fitness
function by calling `evaluate`.

Once the fitness function and the arguments it is going to receive are created,
the user can create its instance of `FitnessFunction` as it is shown.

See also: [`Evaluator`](@ref)
"
struct FitnessFunction
    _fitnessFunction::Function
    _varArgs::Array
    _weight::Float32

    function FitnessFunction(fitnessFunction::Function, varArgs...;
                             weight::Real = 1.0)
        varArgs = [i for i in varArgs]
        new(fitnessFunction, varArgs, weight)
    end
end # struct
export FitnessFunction



"""
    getFunction(fitnessfunction::FitnessFunction)::Function

Obtains the function of a fitness function.
"""
getFunction(fitnessfunction::FitnessFunction)::Function = fitnessfunction._fitnessFunction
# function



"""
    getFunctionArgs(fitnessfunction::FitnessFunction)::Array

Obtains the arguments of a fitness function.
"""
getFunctionArgs(fitnessfunction::FitnessFunction)::Array = fitnessfunction._varArgs
# function



"""
    getWeight(fitnessFunction::FitnessFunction)::Float32

Obtains the weight of a fitness function.
"""
getWeight(fitnessFunction::FitnessFunction)::Float32 = fitnessFunction._weight
# function



"""
    getWeight(fitnessFunctions::Array{FitnessFunction}, index::Integer=1)::Float32

Obtains the weight of a fitness function within an array of fitness functions.
"""
getWeight(fitnessFunctions::Array{FitnessFunction}, index::Integer=1)::Float32 = getWeight(fitnessFunctions[index])
# function



"""
    getWeights(fitnessFunctions::Array{FitnessFunction})::Array{Float32}

Obtains the weights of all the fitness function of an array.
"""
function getWeights(fitnessFunctions::Array{FitnessFunction})::Array{Float32}
    len = length(fitnessFunctions)
    weights = Array{Float32}(undef, len)
    for i=eachindex(weights)
        @inbounds weights[i] = getWeight(fitnessFunctions, i)
    end
    return weights
end # function



"""
    fitnessEval(fitnessFunc::FitnessFunction, genotype::Genotype)::Float64

Returns the result of a fitness function for a determined genotype.
"""
function fitnessEval(fitnessFunc::FitnessFunction, genotype::Genotype)::Float64
    ff = getFunction(fitnessFunc)
    args = getFunctionArgs(fitnessFunc)
    ff(genotype, args...)
end # function



"""
    fitnessEval(fitnessFunc::FitnessFunction,
                gpExperimentInfo::GPExperimentInfo, genotype::Genotype)::Float64

Returns the result of a fitness function for a determined genotype.
"""
function fitnessEval(fitnessFunc::FitnessFunction,
                     gpExperimentInfo::GPExperimentInfo, genotype::Genotype)::Float64
    ff = getFunction(fitnessFunc)
    args = getFunctionArgs(fitnessFunc)
    ff(genotype, gpExperimentInfo, args...)
end # function



"
This struct evaluates each individual according to a fitness function and an
assigned weight to each value of fitness.

# Fields
- `_fitnessFunctions::Array{FitnessFunction}`: set of fitness functions that are
    going to be evaluated for every individual of the population.
- `_globalFitnessFunction::FitnessFunction`: second-phase fitness function. If set,
    this function will be evaluated once all the individuals of the population
    have been evaluated with their raw fitness values.
- `_compareFunction::Function`: method used for comparison between individuals.
- `_compareFunctionArgs::String`: tells the evaluator what is going to be
    compared. \"raw\" is for fitness comparison, \"rawW\" is for weighted fitness comparison,
    \"global\" is for second-phase fitness comparison, \"globalW\" is for weighted
    second-phase fitness comparison, \"both\" is for both fitness and second-phase
    fitness comparison and \"bothW\" is for both weighted fitness and weighted
    second-phase fitness comparison.

If the user wants to set a second-phase fitness function, there are some
considerations to be taken.

The global fitness function must **always** receive the population of individuals
as its first argument and the fitness weights as its second argument, as they are
used to determine which fitness values weight more and which ones weight less.
The user can specify other arguments needed when creating the `FitnessFunction`
instance, but they do **not** need to specify the population or the weights as
one of them, as the system already know they are. Also, the function must return
an array with the second-phase fitness values of all the individuals in the
population. Here is an example of how a second-phase fitness function should be
created:

```jldoctest
julia> function myGlobalFitnessFunction(population::Array{Individual}, weights::Array{Real})
    #···Code···
    return globalFitnessValues
end
myGlobalFitnessFunction (generic function with 1 method)

julia> FitnessFunction(myGlobalFitnessFunction)
FitnessFunction(myGlobalFitnessFunction, Any[], 1.0)
```

Here, a second-phase fitness function has been created using `myGlobalFitnessFunction`
as the actual function, which takes no arguments, and assigning 1.0 as its weight.
The way the system know this is the second-phase fitness function is
by specifying so when calling `setEvaluator` with the keyword argument
`globalFitnessFunction`.


See also: [`setEvaluator`](@ref), [`FitnessFunction`](@ref)
"
struct Evaluator
    _fitnessFunctions::Array{FitnessFunction}
    _globalFitnessFunction::FitnessFunction
    _compareFunction::Function
    _compareFunctionArgs::String
end # struct



"""
    getNumberFitness(evaluator::Evaluator)

Obtains the number of fitness functions of the problem
"""
getNumberFitness(evaluator::Evaluator) = length(evaluator._fitnessFunctions)
# function



"""
    getFitnessFunction(evaluator::Evaluator, index::Integer)::FitnessFunction

Obtains a fitness function of the evaluator.
"""
getFitnessFunction(evaluator::Evaluator, index::Integer)::FitnessFunction = evaluator._fitnessFunctions[index]
# function



"""
    hasGlobalFitnessFunction(evaluator::Evaluator)::Bool

Checks if a global fitness function has been assigned.
"""
function hasGlobalFitnessFunction(evaluator::Evaluator)::Bool
    return getFunction(evaluator._globalFitnessFunction) != _noFunc_
end
# function



"""
    getGlobalFitnessFunction(evaluator::Evaluator)::FitnessFunction

Obtains the global fitness function of the evaluator.
"""
getGlobalFitnessFunction(evaluator::Evaluator)::FitnessFunction = evaluator._globalFitnessFunction
# function



"""
    getWeight(evaluator::Evaluator, index::Integer=1)::Float32

Obtains the weight of a fitness function of the evaluator.
"""
getWeight(evaluator::Evaluator, index::Integer=1)::Float32 = getWeight(evaluator._fitnessFunctions, index)
# function



"""
    getWeights(evaluator::Evaluator)::Array{Float32}

Obtains the weights of all the fitness function of the evaluator.
"""
getWeights(evaluator::Evaluator)::Array{Float32} = getWeights(evaluator._fitnessFunctions)
# function



"""
    getCompareFunction(evaluator::Evaluator)::Function

Obtains the method used for comparison of the evaluator.
"""
getCompareFunction(evaluator::Evaluator)::Function = evaluator._compareFunction
# function



"""
    getParametrizedCompareFunction(compareFunction::Function, args::String,
                                   weights::Array{Real})::Function

Obtains the comparison function based on the weights and the number of fitness
functions of the evaluator.
"""
function getParametrizedCompareFunction(compareFunction::Function, args::String,
                                        weights::Array{Float32})::Function

    local compare
    if compareFunction == _noFunc_
        if length(weights) == 1
            if sign(weights[1]) == 1
                compare = (ind1::Individual, ind2::Individual) -> compareFitnessMaximize(getFitness(ind1, 1), getFitness(ind2, 1))
            else
                compare = (ind1::Individual, ind2::Individual) -> compareFitnessMinimize(getFitness(ind1, 1), getFitness(ind2, 1))
            end
        else
            compare = (ind1::Individual, ind2::Individual) -> compareFitnessLinearCombination(getFitness(ind1), getFitness(ind2), weights)
        end
    else
        if args == "raw"
            compare = (ind1::Individual, ind2::Individual) -> compareFunction(getFitness(ind1), getFitness(ind2))
        elseif args == "rawW"
            compare = (ind1::Individual, ind2::Individual) -> compareFunction(getFitness(ind1), getFitness(ind2), weights)
        elseif args == "global"
            compare = (ind1::Individual, ind2::Individual) -> compareFunction(getGlobalFitness(ind1), getGlobalFitness(ind2))
        elseif args == "globalW"
            compare = (ind1::Individual, ind2::Individual) -> compareFunction(getGlobalFitness(ind1), getGlobalFitness(ind2), weights)
        elseif args == "both"
            compare = (ind1::Individual, ind2::Individual) -> compareFunction(getFitness(ind1), getGlobalFitness(ind1), getFitness(ind2), getGlobalFitness(ind2))
        else
            compare = (ind1::Individual, ind2::Individual) -> compareFunction(getFitness(ind1), getGlobalFitness(ind1), getFitness(ind2), getGlobalFitness(ind2), weights)
        end
    end
    return compare
end # function



"""
    computeFitness(evaluator::Evaluator, experimentInfo::ExperimentInfo,
                   genotype::Genotype, stopCondition::StopCondition)::Array{Float64}

Computes the fitness of a single individual.
"""
function computeFitness(evaluator::Evaluator, experimentInfo::ExperimentInfo,
                        genotype::Genotype, stopCondition::StopCondition)::Array{Float64}

    len = length(evaluator._fitnessFunctions)
    fitnesses = Array{Float64}(undef, len)
    if experimentInfo._individualType <: GAGenotype
        for i=eachindex(fitnesses)
            @inbounds fitnesses[i] = fitnessEval(getFitnessFunction(evaluator, i),
                                                 genotype)
        end
    else
        for i=eachindex(fitnesses)
            @inbounds fitnesses[i] = fitnessEval(getFitnessFunction(evaluator, i),
                                                 experimentInfo._GPExperimentInfo,
                                                 genotype)
        end
    end

    if stopCondition._maxEvaluations < typemax(Int64)
        notifyEvaluation(stopCondition)
    end

    return fitnesses
end # function



"""
    globalFitnessEval(fitnessFunc::FitnessFunction,
                      population::Array{Individual},
                      weights::Array{Real})::Float64

Returns the result of a global fitness function for a population.
"""
function globalFitnessEval(fitnessFunc::FitnessFunction, population::Array{Individual},
                            weights::Array{Float32})::Array{Float64}

    ff = getFunction(fitnessFunc)
    args = getFunctionArgs(fitnessFunc)
    ff(population, weights, args...)
end # function



"""
    evaluate!_(evaluator::Evaluator, experimentInfo::ExperimentInfo,
               population::Array{Individual}, stopCondition::StopCondition)

Evaluates the fitness of the individuals of a population and sets their values.
"""
function evaluate!_(evaluator::Evaluator, experimentInfo::ExperimentInfo,
                    population::Array{Individual}, stopCondition::StopCondition)
    for ind in population
        if hasNullFitness(ind)
            ind._fitness = computeFitness(evaluator, experimentInfo, ind._genotype, stopCondition)
        end
    end

    globalFitnessFunc = getGlobalFitnessFunction(evaluator)
    if getFunction(globalFitnessFunc) != _noFunc_
        weights = getWeights(evaluator)
        globalFitnesses = globalFitnessEval(globalFitnessFunc, population, weights)
        setGlobalFitness!(population, globalFitnesses)
    end
    nothing
end # function



"""
    compareFitnessMaximize(fitness1::Float64, fitness2::Float64)

Compares two values of fitness and returns true if the first one is greater than
the second one, returns false otherwise.
"""
function compareFitnessMaximize(fitness1::Float64, fitness2::Float64)
    return fitness1 > fitness2 ? true : false
end # function



"""
    compareFitnessMinimize(fitness1::Float64, fitness2::Float64)

Compares two values of fitness and returns true if the first one is less than
the second one, returns false otherwise.
"""
function compareFitnessMinimize(fitness1::Float64, fitness2::Float64)
    return fitness1 < fitness2 ? true : false
end # function



"""
    compareFitnessLinearCombination(fitness1::Array{Float64},
                                    fitness2::Array{Float64},
                                    weights::Array{Float32})

Compares two sets of fitness values calculating the dot product between each one
of them and the weights assigned. Returns true if the first set of fitness values
is greater than the second one, returns false otherwise.
"""
function compareFitnessLinearCombination(fitness1::Array{Float64},
                                         fitness2::Array{Float64},
                                         weights::Array{Float32})

    function dot(array1::Array, array2::Array)
        sum(array1 .* array2)
    end

    conjunction1 = dot(fitness1, weights)
    conjunction2 = dot(fitness2, weights)

    return conjunction1 > conjunction2 ? true : false
end # function



"""
    getBestIndividual(population::Array{Individual}, compare::Function,
                      n::Integer = 1)::Array{Int}

Obtains the `n` best individuals of a population according to a comparing function.
"""
function getBestIndividual(population::Array{Individual}, compare::Function,
                           n::Integer = 1)::Array{Int}

    bestIndividual = collect(1:n)
    len = length(population)

    @inbounds for i=1:n
        for j=i+1:n
            if compare(population[bestIndividual[i]], population[bestIndividual[j]])
                bestIndividual[j], bestIndividual[i] = bestIndividual[i],  bestIndividual[j]
            end
        end
    end

    @inbounds for i=n+1:len
        if compare(population[i], population[bestIndividual[1]])
            bestIndividual[1] = i
            for j=1:n-1
                if compare(population[bestIndividual[j]], population[bestIndividual[j+1]]) || break
                    bestIndividual[j], bestIndividual[j+1] = bestIndividual[j+1],  bestIndividual[j]
                end
            end
        end
    end

    return bestIndividual
end # function



"""
    getWorstIndividual(population::Array{Individual}, compare::Function,
                       n::Integer=1)::Array{Int}

Obtains the `n` worst individuals of a population according to a comparing function.
"""
function getWorstIndividual(population::Array{Individual}, compare::Function,
                            n::Integer=1)::Array{Int}

    worstIndividual = collect(1:n)
    len = length(population)

    @inbounds for i=1:n
        for j=i+1:n
            if !compare(population[worstIndividual[i]], population[worstIndividual[j]])
                worstIndividual[j], worstIndividual[i] = worstIndividual[i],  worstIndividual[j]
            end
        end
    end

    @inbounds for i=n+1:len
        if !compare(population[i], population[worstIndividual[1]])
            worstIndividual[1] = i
            for j=1:n-1
                if !compare(population[worstIndividual[j]], population[worstIndividual[j+1]]) || break
                    worstIndividual[j], worstIndividual[j+1] = worstIndividual[j+1],  worstIndividual[j]
                end
            end
        end
    end

    return worstIndividual
end # function



"""
    pareto(population::Array{Individual}, weights::Array{Float32})::Array{Float64}

Assigns every individual of a population its second-phase fitness which is the
level they are in the pareto front.

# Arguments
- `population::Array{Individual}`: population of individuals that are going to be
    second-phase evaluated.
- `weights::Array{Real}`: array of weights for every single "raw fitness"
    function.

# Returns
An array with the levels of the individuals in the pareto front.
"""
function pareto(population::Array{Individual}, weights::Array{Float32})::Array{Float64}

    weightsSign = sign.(weights)

    function dominates(fitness1, fitness2)
        nFitness = length(fitness1)
        nDominations1 = 0
        nDominations2 = 0

        fitness1 = fitness1 .* weightsSign
        fitness2 = fitness2 .* weightsSign


        for i=1:nFitness
            if fitness1[i] > fitness2[i]
                nDominations1 += 1
            elseif fitness1[i] < fitness2[i]
                nDominations2 += 1
            end
        end
        if nDominations1 == nFitness
            return 1
        elseif nDominations2 == nFitness
            return -1
        end

        return 0
    end # function

    popsize = length(population)
    fitnesses = getFitness(population)
    dominateMatrix = zeros(Integer, popsize, popsize+1)
    dominateMatrix[:,end] = collect(1:popsize)

    @inbounds for i=1:popsize, j=i+1:popsize
        dominateMatrix[i,j] = dominates(fitnesses[:,i], fitnesses[:,j])
        dominateMatrix[j,i] = dominateMatrix[i,j] * (-1)
    end

    paretoLevel = zeros(Integer, popsize)

    level = 0

    while (true)
        level+=1
        len = size(dominateMatrix)[1]
        if len == 0
            break
        end
        rows = ones(Bool, len)
        cols = ones(Bool, len+1)
        @inbounds for i=1:len
            n = count(i->(i==-1), view(dominateMatrix, i, :))
            if n == 0
                paretoLevel[dominateMatrix[i,end]] = level
                rows[i] = false
                cols[i] = false
            end
        end
        dominateMatrix = dominateMatrix[rows, cols]
    end

    return paretoLevel
end # function
export pareto
