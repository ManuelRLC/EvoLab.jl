"
SelectionOperator represents the method that selects a portion of the population
for crossover and mutation.

# Fields
- `_method::Function`: selection method between individuals.
- `_nSelectedParents::Real`: number of selected individuals. Its values can either
    be an integer number, which directly represents the number of individuals that
    are going to be picked for selection, or a floating point number, which then
    represents the percentage of the population that is going to be selected.
- `needsComparison::Bool = true`: tells wether the user wants the system to compare
    between the individuals in order to select between them.
- `_samplingWithRep::Bool`: tells wether the user wants the system to perform the
    selection with replacement (`true`) or not (`false`).
- `_varArgs::Array{Any}`: arguments of the selection method, if necessary.
"
struct SelectionOperator
    _method::Function
    _nSelectedParents::Real
    _needsComparison::Bool
    _samplingWithRep::Bool
    _varArgs::Array{Any}
end # struct



"""
    getMethod(selector::SelectionOperator)::Function

Returns the method for select the parents.
"""
getMethod(selector::SelectionOperator)::Function = selector._method
# function



"""
    needsComparison(selector::SelectionOperator)::Bool

Indicates wether the selection method needs to compare between individuals
or not.
"""
needsComparison(selector::SelectionOperator)::Bool = selector._needsComparison
# function



"""
    getDefaultSelector()::Tuple{Function, Array}

Returns the default selection method, which is [`tournamentSelector`](@ref) between
4 individuals.
"""
function getDefaultSelector()::Tuple{Function, Array}
    return tournamentSelector, [4]
end # function



"""

    getNParents(selector::SelectionOperator)::Real

Returns the attribute that represents the number of parents that are going to be selected.
"""
getNSelectedParents(selector::SelectionOperator)::Real = selector._nSelectedParents
# function



"""

    samplingWithReplacement(selector::SelectionOperator)::Bool

"""
samplingWithReplacement(selector::SelectionOperator)::Bool = selector._samplingWithRep
# function



"""

    getFunctionArgs(selector::SelectionOperator)::Array

Obtains the aditional arguments associated to selector method.
"""
getFunctionArgs(selector::SelectionOperator)::Array = selector._varArgs
# function



"""
    selectParentsWithReplacement(selector::SelectionOperator, population::Array{Individual},
                                evaluator::Evaluator, rng::Random.AbstractRNG)::Array{Individual}

Performs a selection between individuals with replacement using the comparison
function of the `Evaluator`.
"""
function selectParentsWithReplacement(selector::SelectionOperator, population::Array{Individual},
                                      evaluator::Evaluator, rng::Random.AbstractRNG)::Array{Individual}

    nSelectedParents = getNSelectedParents(selector)
    compare = getCompareFunction(evaluator)
    popSize = length(population)

    parents = Array{Individual}(undef, nSelectedParents)

    method = getMethod(selector)

    functionArgs = getFunctionArgs(selector)


    for i=eachindex(parents)
        if needsComparison(selector)
            index = method(population, compare, rng, functionArgs...)
        else
            index = method(population, rng, functionArgs...)
        end
        parents[i] = population[index]
    end

    return parents
end # function

precompile(selectParentsWithReplacement, tuple(SelectionOperator, Vector{Individual}, Evaluator, Random.MersenneTwister))
precompile(selectParentsWithReplacement, tuple(SelectionOperator, Vector{Individual}, Evaluator, Random._GLOBAL_RNG))

"""
    selectParentsWithoutReplacement(selector::SelectionOperator,
                                    population::Array{Individual},
                                    evaluator::Evaluator,
                                    rng::Random.AbstractRNG)::Array{Individual}

Performs a selection between individuals without replacement using the comparison
function of the `Evaluator`.
"""
function selectParentsWithoutReplacement(selector::SelectionOperator,
                                         population::Array{Individual},
                                         evaluator::Evaluator,
                                         rng::Random.AbstractRNG)::Array{Individual}

    nSelectedParents = getNSelectedParents(selector)
    compare = getCompareFunction(evaluator)
    popSize = length(population)

    copyPopulation = copyPop(population)
    indexes = collect(1:popSize)

    method = getMethod(selector)
    functionArgs = getFunctionArgs(selector)

    for i=1:nSelectedParents
        if needsComparison(selector)
            index = method(copyPopulation, compare, rng, functionArgs...)
        else
            index = method(copyPopulation, rng, functionArgs...)
        end
        copyPopulation[index] = copyPopulation[end]
        pop!(copyPopulation)
        indexes[index], indexes[end-i+1] = indexes[end-i+1], indexes[index]
    end

    parents = population[indexes[end-nSelectedParents+1:end]]

    return parents
end # function

precompile(selectParentsWithoutReplacement, tuple(SelectionOperator, Vector{Individual}, Evaluator, Random.MersenneTwister))
precompile(selectParentsWithoutReplacement, tuple(SelectionOperator, Vector{Individual}, Evaluator, Random._GLOBAL_RNG))

"""
    selectParents_(selector::SelectionOperator, population::Array{Individual},
                   evaluator::Evaluator, rng::Random.AbstractRNG)

Performs the selection of individuals given by the selection method and using
the comparison function between individuals of the `Evaluator`.
"""
function selectParents_(selector::SelectionOperator, population::Array{Individual},
                        evaluator::Evaluator, rng::Random.AbstractRNG)

    if samplingWithReplacement(selector)
        selectParentsWithReplacement(selector, population, evaluator, rng)
    else
        selectParentsWithoutReplacement(selector, population, evaluator, rng)
    end
end # function

precompile(selectParents_, tuple(SelectionOperator, Vector{Individual}, Evaluator, Random.MersenneTwister))
precompile(selectParents_, tuple(SelectionOperator, Vector{Individual}, Evaluator, Random._GLOBAL_RNG))

"""
    randomSelector(population::Array{Individual}, rng::Random.AbstractRNG)

Performs a random selection between the individuals of a population.

# Mandatory Arguments
- `population::Array{Individual}`: population of individuals that are going to
    be selected.
- `rng::Random.AbstractRNG`: random number generator of the experiment.

# Returns
The index of the selected individual.

See also: [`setSelector`](@ref)
"""
function randomSelector(population::Array{Individual}, rng::Random.AbstractRNG)
    rand(rng, UInt16)%(length(population)) + 1
end # function
export randomSelector



"""
    tournamentSelector(population::Array{Individual}, compare::Function,
                       rng::Random.AbstractRNG, k::Integer)

Performs a tournament selection between the individuals of a population.

# Mandatory Arguments
- `population::Array{Individual}`: population of individuals that are going to
    be selected.
- `compare::Function`: `Evaluator`'s comparison method between individuals to
    decide which ones win the tournament.
- `rng::Random.AbstractRNG`: random number generator of the experiment.

# Arguments
- `k::Integer`: number of individuals that compete in the tournament. If `k`
    equals 1, it will be a random selection between the individuals (see
    [`randomSelector`](@ref)).

# Returns
The index of the selected individual.

See also: [`setSelector`](@ref)
"""
function tournamentSelector(population::Array{Individual}, compare::Function,
                            rng::Random.AbstractRNG, k::Integer)
    nInd = length(population) # Number of individuals of the population
    bestIndex = rand(rng, UInt16) % nInd + 1
    best = population[bestIndex]

    for i=2:k
        currentIndex = rand(rng, UInt16) % nInd + 1
        current = population[currentIndex]
        bestIndex = compare(best, current) ? bestIndex : currentIndex
        best = population[bestIndex]
    end

    return bestIndex
end # function
export tournamentSelector



"""
function tournamentSelector(fitnesses::Array, compare::Function, rng::Random.AbstractRNG, k::Integer)
    nInd = length(fitnesses) # Number of individuals of the population
    bestIndex = rand(rng, UInt) % nInd + 1
    best = fitnesses[bestIndex]

    for i=2:k
        currentIndex = rand(rng, UInt) % nInd + 1
        current = fitnesses[currentIndex]
        bestIndex = compare(best, current) ? bestIndex : currentIndex
        best = fitnesses[bestIndex]
    end

    return bestIndex
end
"""

function rouletteSelector(fitnesses::Array, compare::Function, rng::Random.AbstractRNG, k::Integer=-1)

    minimize = compare(1, 2) # esto no fufa
    popSize = length(fitnesses)
    if minimize
        max = maximum(fitnesses)
        fitnesses = map(x->abs(x-max), fitnesses)
    end

    if k < 0
        k = popSize
        indexes = collect(1:popSize)
    else
        if k < 50
            indexes = randomIndexSelection(popSize, k, rng)
        else
            indexes = randomIndexSelection2(popSize, k, rng)
        end
        fitnesses = fitnesses[indexes]
    end

    sumFitness = sum(fitnesses)

    selected = 1
    random = rand(rng, 0:sumFitness)
    random -= fitnesses[1]

    while random >= 0
        selected += 1
        random -= fitnesses[selected]
    end

    return indexes[selected]
end # function
export rouletteSelector


function rankingSelector(fitnesses::Array, compare::Function, rng::Random.AbstractRNG, k::Integer=-1)

    minimize = compare(1,2)
    popSize = length(fitnesses)
    if minimize
        newFitnesses = copy(fitnesses)
        max = maximum(newFitnesses)
        newFitnesses = map(x->abs(x-max), newFitnesses)
    end

    if k < 0
        k = popSize
        indexes = collect(1:popSize)
        newFitnesses = fitnesses
    else
        if k < 50
            indexes = randomIndexSelection(popSize, k, rng)
        else
            indexes = randomIndexSelection2(popSize, k, rng)
        end
        newFitnesses = fitnesses[indexes]
    end

    sumFitness = sum(fitnesses)

    selected = 1
    random = rand(rng, 0:sumFitness)
    random -= fitnesses[1]


    while random >= 0
        selected += 1
        random -= fitnesses[selected]
    end

    return indexes[selected]
end




"""
function selectParentsWithoutReplacement(selector::SelectionOperator,
                                         population::Array{Individual},
                                         nParents::Integer, evaluator::Evaluator, rng::Random.AbstractRNG)

    nSelectedParents = getNSelectedParents(selector)
    compare = getCompareFitness(evaluator)
    popSize = length(population)

    if !(typeof(nSelectedParents) <: Integer)
        nSelectedParents = convert(Integer, round(nSelectedParents * popSize))
        remainder = nSelectedParents % nParents

        if remainder != 0
            nSelectedParents = nSelectedParents + nParents - remainder
        end

        if nSelectedParents > popSize
            nSelectedParents -= nParents
        end
    end

    indexes = collect(1:popSize)

    if selector._individualMode == "fitness"
        fitnesses = getFitness(population)

        for i=1:nSelectedParents
            if needsComparison(selector)
                index = selector._method(fitnesses, compare, rng, selector._varArgs...)
                fitnesses[index] = fitnesses[end]
                pop!(fitnesses)
                indexes[index], indexes[end-i+1] = indexes[end-i+1], indexes[index]
            else
                index = selector._method(fitnesses, rng, selector._varArgs...)
                fitnesses[index] = fitnesses[end]
                pop!(fitnesses)
                indexes[index], indexes[end-i+1] = indexes[end-i+1], indexes[index]
            end
        end
    elseif selector._individualMode == "representation"
        indReps = getGenotype(population)
        for i=1:nSelectedParents
            if needsComparison(selector)
                index = selector._method(indReps, compare, rng, selector._varArgs...)
                indReps[index] = indReps[end]
                pop!(indReps)
                indexes[index], indexes[end-i+1] = indexes[end-i+1], indexes[index]
            else
                index = selector._method(indReps, rng, selector._varArgs...)
                indReps[index] = indReps[end]
                pop!(indReps)
                indexes[index], indexes[end-i+1] = indexes[end-i+1], indexes[index]
            end
        end
    else
        fitnesses = getFitness(population)
        indReps = getGenotype(population)
        for i=1:nSelectedParents
            if needsComparison(selector)
                index = selector._method(indReps, fitnesses, compare, rng, selector._varArgs...)
                indReps[index] = indReps[end]
                pop!(indReps)
                fitnesses[index] = fitnesses[end]
                pop!(fitnesses)
                indexes[index], indexes[end-i+1] = indexes[end-i+1], indexes[index]
            else
                index = selector._method(indReps, fitnesses, rng, selector._varArgs...)
                indReps[index] = indReps[end]
                pop!(indReps)
                fitnesses[index] = fitnesses[end]
                pop!(fitnesses)
                indexes[index], indexes[end-i+1] = indexes[end-i+1], indexes[index]
            end
        end
    end

    parents = deepcopy(population[indexes[end-nParents+1:end]])

    return parents
end # function
"""
