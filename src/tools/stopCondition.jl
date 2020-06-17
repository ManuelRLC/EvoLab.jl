"
`StopCondition` represents the set of stop conditions for the experiment to finish
if at least one of them has been fulfilled.

# Fields
- `_maxEvaluations::Int64`: maximum of evaluations permitted. An evaluation
    is made everytime the system computes an individual's fitness.
- `_maxIterations::Int64`: maximum of iterations permitted. An iteration is
    done in the main loop of the genetic algorithm, that is to say, everytime a
    new population replaces the old one.
- `_maxIterNotImproving::Int64`: maximum of iterations having the same best
    individual of the population.
- `_maxTime::Float64`: maximum run time permitted in seconds.
- `_numEvaluations::Int64`: current number of evaluations.
- `_numIterations::Int64`: current number of iterations.
- `_numIterNotImproving::Int64`: current number of iterations having the same
    best individual of the population.
- `_bestFitness::Float64`: fitness value of the best individual so far.
- `_initialTime::Float64`: starting time of the experiment in seconds.

See also: [`setStopCondition`](@ref)
"
mutable struct StopCondition
    _maxEvaluations::Int64
    _maxIterations::Int64
    _maxIterNotImproving::Int64
    _maxTime::Float64

    _numEvaluations::Int64
    _numIterations::Int64
    _numIterNotImproving::Int64
    _bestIndividual::Individual
    _initialTime::Float64

    StopCondition() = new()
    function StopCondition(maxEvaluations, maxIterations,
                            maxIterNotImproving, maxTime,
                            numEvaluations, numIterations,
                            numIterNotImproving, initialTime)

        new(maxEvaluations, maxIterations,
            maxIterNotImproving, maxTime,
            numEvaluations, numIterations,
            numIterNotImproving, Individual(), initialTime)
    end
end # struct



"""
    getMaxIterations(stopCondition::StopCondition)

Obtains the maximum of iterations permitted.
"""
getMaxIterations(stopCondition::StopCondition) = stopCondition._maxIterations
# function



"""
    getCurrentIteration(stopCondition::StopCondition)

Obtains the current iteration of the experiment.
"""
getCurrentIteration(stopCondition::StopCondition) = stopCondition._numIterations
# function



"""
    reached_(stopCondition::StopCondition)::Bool

Tells wether one of the stop conditions has been fulfilled or not.
"""
function reached_(stopCondition::StopCondition)::Bool

    reached = false

    if stopCondition._numEvaluations >= stopCondition._maxEvaluations
        reached = true
    elseif stopCondition._numIterations >= stopCondition._maxIterations
        reached = true
    elseif stopCondition._numIterNotImproving >= stopCondition._maxIterNotImproving
        reached = true
    elseif stopCondition._maxTime != Inf &&
           (time() - stopCondition._initialTime) > stopCondition._maxTime
        reached = true
    end

    return reached
end # function



"""
    setTime(stopCondition::StopCondition, time::Float64)

Sets the starting time of the experiment.
"""
function setTime(stopCondition::StopCondition, time::Float64)
    stopCondition._initialTime = time
    return nothing
end # function



"""
    notifyEvaluation(stopCondtition::StopCondition)

Adds one to the current number of evaluations.
"""
function notifyEvaluation(stopCondition::StopCondition)
    stopCondition._numEvaluations += 1
    return nothing
end # function



"""
    notifyIteration(stopCondition::StopCondition)

Adds one to the current number of iterations.
"""
function notifyIteration(stopCondition::StopCondition)
    stopCondition._numIterations += 1
    return nothing
end # function



"""
    notifyIterNotImproving(stopCondition::StopCondition)

Adds one to the current number of iterations having the same best individual
of the population.
"""
function notifyIterNotImproving(stopCondition::StopCondition)
    stopCondition._numIterNotImproving += 1
    return nothing
end # function



"""
    resetEvaluations(stopCondition::StopCondition)

Resets the number of evaluations back to 0.
"""
function resetEvaluations(stopCondition::StopCondition)
    stopCondition._numEvaluations = 0
    return nothing
end # function



"""
    resetIterations(stopCondition::StopCondition)

Resets the number of iterations back to 0.
"""
function resetIterations(stopCondition::StopCondition)
    stopCondition._numIterations = 0
    return nothing
end # function



"""
    resetIterNotImproving(stopCondition::StopCondition)

Resets the number of iterations having the same best individual of the population
back to 0.
"""
function resetIterNotImproving(stopCondition::StopCondition)
    stopCondition._numIterNotImproving = 0
    return nothing
end # function



"""
    resetConditions(stopCondition::StopCondition)

Reset all the stop conditions.
"""
function resetConditions_(stopCondition::StopCondition)
    if stopCondition._maxEvaluations != typemax(Int64)
        resetEvaluations(stopCondition)
    end

    if stopCondition._maxIterations != typemax(Int64)
        resetIterations(stopCondition)
    end

    if stopCondition._maxIterNotImproving != typemax(Int64)
        resetIterNotImproving(stopCondition)
    end

    if stopCondition._maxTime != Inf
        setTime(stopCondition, time())
    end

    return nothing
end # function
