"
ReplacementOperator represents the method that replaces the previous generation
by a new one originated after crossover and mutation.

# Fields
- `needsComparison::Bool = true`: tells wether the user wants the system to compare
    between the individuals in order to select the ones that will replace the old
    population.
- `_eliteSize::UInt16`: number of fittest individuals to be maintained if there
    is elitism.
- `_method::Function`: method used for replacement.
- `_varArgs::Array{Any}`: arguments necessary for the replacement method.
"
struct ReplacementOperator
    _needsComparison::Bool
    _eliteSize::UInt16
    _method::Function
    _varArgs::Array{Any}
end # struct



"""
    needsComparison(replaceOp::ReplacementOperator)::Bool

Indicates wether the replacement method needs to compare between individuals
or not.
"""
needsComparison(replaceOp::ReplacementOperator)::Bool = replaceOp._needsComparison
# function



"""
    isElitist(replaceOp::ReplacementOperator)::Bool

Indicates wether the replacement method is elitist or not.
"""
isElitist(replaceOp::ReplacementOperator)::Bool = replaceOp._eliteSize > 0
# function



"""
    getEliteSize(replaceOp::ReplacementOperator)::UInt16

Obtains the size of the elite set to be maintained throughtout the generations.
"""
getEliteSize(replaceOp::ReplacementOperator)::UInt16 = replaceOp._eliteSize
# function



"""
    getDefaultReplacementOp()::Tuple{Function, Array}

Returns the default replacement operator, which is [`replaceAllPopulation`](@ref).
"""
function getDefaultReplacementOp()::Tuple{Function, Array}
    return replaceAllPopulation, []
end # function



"""
    selectFromSet(Ra::Array{Integer}, nLeft::Integer, population::Array{Individual},
                  compare::Function, rng::Random.AbstractRNG)

Selects `nLeft` individuals from the set `Ra` using a comparison method.
"""
function selectFromSet(Ra::Array, nLeft::Integer, population::Array{Individual},
                        compare::Function, rng::Random.AbstractRNG)

    subPop = population[Ra]

    for i=1:nLeft
        index = tournamentSelector(subPop[1:end-i+1], compare, rng, 4)
        subPop[index], subPop[end-i+1] = subPop[end-i+1], subPop[index]
        Ra[index], Ra[end-i+1] = Ra[end-i+1], Ra[index]
    end

    return Ra[end-nLeft+1:end]
end # function



"""
    fillNewPopulation(populationSelectedIndexes::Array{Integer},
                      offspringSelectedIndexes::Array{Integer},
                      population::Array{Individual},
                      offspring::Array{Individual},
                      compare::Function,
                      nLeft::Integer, rng::Random.AbstractRNG)

Fills a set of individuals with `nLeft` individuals using a comparison function.
"""
function fillNewPopulation(populationSelectedIndexes::Array,
                           offspringSelectedIndexes::Array,
                           population::Array{Individual},
                           offspring::Array{Individual},
                           compare::Function,
                           nLeft::Integer, rng::Random.AbstractRNG)

    lenPop = length(population)
    lenOff = length(offspring)

    left = Array{Integer}(undef, nLeft)

    belongs1(element) = findnext(x->x==element, offspringSelectedIndexes, 1) != nothing
    notSelectedOff = filter(!belongs1, collect(1:lenOff))

    newSelectedOff = []
    newSelectedPop = []
    if length(notSelectedOff) > nLeft
        newSelectedOff = selectFromSet(notSelectedOff, nLeft, offspring, compare, rng)
    else
        newSelectedOff = notSelectedOff
        if (nLeft - length(notSelectedOff)) != 0
            belongs2(element) = findnext(x->x==element, populationSelectedIndexes, 1) != nothing
            notSelectedPopulation = filter(!belongs2, collect(1:lenPop))
            newSelectedPop = selectFromSet(notSelectedPopulation, nLeft - length(notSelectedOff), population, compare, rng)
        end
    end

    return vcat(newSelectedPop, populationSelectedIndexes), vcat(newSelectedOff, offspringSelectedIndexes)
end # function



"""
    replacePopulation_(replaceOp::ReplacementOperator,
                       population::Array{Individual},
                       offspring::Array{Individual},
                       evaluator::Evaluator, experimentInfo::ExperimentInfo)

Performs the replacement of the population by the given replacement method using
the comparison function of the `Evaluator` to compare between individuals if necessary.
"""
function replacePopulation_(replaceOp::ReplacementOperator,
                            population::Array{Individual},
                            offspring::Array{Individual},
                            evaluator::Evaluator, experimentInfo::ExperimentInfo)

    rng = experimentInfo._rng
    if needsComparison(replaceOp)
        compare = getCompareFunction(evaluator)
        populationIndexes, offspringIndexes = replaceOp._method(population, offspring,
                                                                compare, replaceOp._varArgs...)
    else
        populationIndexes, offspringIndexes = replaceOp._method(population, offspring,
                                                                replaceOp._varArgs...)
    end

    nSelectedPop = length(populationIndexes)
    nSelectedOff = length(offspringIndexes)
    popSize = length(population)

    nLeft = popSize - (nSelectedPop + nSelectedOff)

    # Selected offspring is bigger or equal in size than popSize, which means we
    # only choose individuals among the user's selected offspring
    if nLeft < 0 && nSelectedOff >= popSize
        if !isElitist(replaceOp)
            offspringIndexes = selectFromSet(offspringIndexes, popSize, offspring,
                                             getCompareFunction(evaluator), rng)
            populationIndexes = []
        else
            offspringIndexes = selectFromSet(offspringIndexes, popSize-getEliteSize(replaceOp),
                                             offspring, getCompareFunction(evaluator), rng)
            populationIndexes = getBestIndividual(population,
                                                  getCompareFunction(evaluator),
                                                  getEliteSize(replaceOp))
        end

    # Selected offspring is less in size than popSize, but the sum of selected
    # individuals is bigger than popSize, which means we must choose the remaining
    # ones among the user's selected population plus all the user's selected offspring.
    elseif nLeft < 0
        if !isElitist(replaceOp)
            populationIndexes = selectFromSet(populationIndexes, popSize - nSelectedOff,
                                              population, getCompareFunction(evaluator), rng)
        else
            eliteSize = getEliteSize(replaceOp)

            if nSelectedOff + eliteSize > popSize
                function belongs1(element)
                    findnext(x->x==element, getWorstIndividual(offspring[offspringIndexes],
                                                               getCompareFunction(evaluator),
                                                               nSelectedOff + eliteSize - popSize), 1) != nothing
                end
                offspringIndexes = filter(!belongs1, offspringIndexes)

                populationIndexes = vcat(populationIndexes,
                                         getBestIndividual(population,
                                                           getCompareFunction(evaluator),
                                                           eliteSize))
            elseif nSelectedOff + eliteSize < popSize
                populationIndexes = getBestIndividual(population,
                                                      getCompareFunction(evaluator),
                                                      eliteSize)

                populationIndexes = vcat(populationIndexes,
                                         selectFromSet(populationIndexes,
                                                       popSize - (nSelectedOff + eliteSize),
                                                       population, getCompareFunction(evaluator),
                                                       rng))
            else
                populationIndexes = vcat(populationIndexes,
                                         getBestIndividual(population,
                                                           getCompareFunction(evaluator),
                                                           eliteSize))
            end
        end

    # The sum of selected individuals is less in size than popSize, we choose all
    # the user's selected individuals and we select new ones
    # through the remaining not selected offspring. If there is no more selected
    # offspring, we select individuals from the ones not selected of the population.
    elseif nLeft > 0
        if !isElitist(replaceOp)
            populationIndexes, offspringIndexes = fillNewPopulation(populationIndexes,
                                                                    offspringIndexes,
                                                                    population,
                                                                    offspring,
                                                                    getCompareFunction(evaluator), nLeft, rng)
        else
            eliteSize = getEliteSize(replaceOp)

            if nSelectedPop + nSelectedOff + eliteSize > popSize
                if !isempty(populationIndexes)
                    function belongs2(element)
                        findnext(x->x==element,
                                 getWorstIndividual(population[populationIndexes],
                                                    getCompareFunction(evaluator),
                                                    nSelectedPop+nSelectedOff+eliteSize-popSize),
                                 1) != nothing
                    end
                    populationIndexes = filter(!belongs2, populationIndexes)
                else
                    function belongs3(element)
                        findnext(x->x==element,
                                 getWorstIndividual(offspring[offspringIndexes],
                                                    getCompareFunction(evaluator),
                                                    nSelectedPop+nSelectedOff+eliteSize-popSize),
                                 1) != nothing
                    end
                    offspringIndexes = filter(!belongs3, offspringIndexes)
                end

                populationIndexes = vcat(populationIndexes,
                                         getBestIndividual(population,
                                                           getCompareFunction(evaluator),
                                                           eliteSize))
            elseif nSelectedPop + nSelectedOff + eliteSize < popSize
                populationIndexes = vcat(populationIndexes,
                                         getBestIndividual(population,
                                                           getCompareFunction(evaluator),
                                                           eliteSize))

                populationIndexes, offspringIndexes = fillNewPopulation(populationIndexes,
                                                                        offspringIndexes,
                                                                        population,
                                                                        offspring,
                                                                        getCompareFunction(evaluator),
                                                                        popSize-(nSelectedPop+nSelectedOff+eliteSize),
                                                                        rng)
            else
                populationIndexes = vcat(populationIndexes,
                                         getBestIndividual(population,
                                                           getCompareFunction(evaluator),
                                                           eliteSize))
            end
        end
    elseif nLeft == 0 && isElitist(replaceOp)
        eliteSize = getEliteSize(replaceOp)

        if !isempty(populationIndexes)
            function belongs4(element)
                findnext(x->x==element,
                         getWorstIndividual(population[populationIndexes],
                                            getCompareFunction(evaluator),
                                            eliteSize),
                         1) != nothing
            end
            populationIndexes = filter(!belongs4, populationIndexes)
        else
            function belongs5(element)
                findnext(x->x==element,
                         getWorstIndividual(offspring[offspringIndexes],
                                            getCompareFunction(evaluator),
                                            eliteSize),
                         1) != nothing
            end
            offspringIndexes = filter(!belongs5, offspringIndexes)
        end

        populationIndexes = vcat(populationIndexes,
                                 getBestIndividual(population,
                                                   getCompareFunction(evaluator),
                                                   eliteSize))
    end

    newPopulation = vcat(population[populationIndexes], offspring[offspringIndexes])

    return newPopulation
end # function
precompile(replacePopulation_, (ReplacementOperator, Vector{Individual},
           Vector{Individual}, Evaluator, ExperimentInfo))



"""
    replaceAllPopulation(population::Array{Individual}, offspring::Array{Individual})

Performs a replacement of all the current population by the offspring.
"""
function replaceAllPopulation(population::Array{Individual}, offspring::Array{Individual})
    return [], collect(1:length(offspring))
end # function
export replaceAllPopulation



"""
    replaceWorstIndividuals(population::Array{Individual}, offspring::Array{Individual}
                                 compareFunction::Function)

documentation
"""
function replaceWorstIndividuals(population::Array{Individual}, offspring::Array{Individual},
                                 compareFunction::Function)

    popSize = length(population)
    offSize = length(offspring)
    local populationIndexes
    local offspringIndexes

    if offSize >= popSize
        populationIndexes, offspringIndexes = [], collect(1:length(offspring))
    else

        function belongs(element)
            findnext(x->x==element,
                     getWorstIndividual(population,
                                        compareFunction,
                                        offSize),
                     1) != nothing
        end
        populationIndexes = filter(!belongs, collect(1:popSize))
        offspringIndexes = collect(1:offSize)
    end

    return populationIndexes, offspringIndexes
end # function
export replaceWorstIndividuals
