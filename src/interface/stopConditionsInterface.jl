"""
    setStopCondition(; genj::GenJulia = GenJ, maxEvaluations::Integer = -1,
                     maxIterations::Integer = -1, maxIterNotImproving::Integer = -1,
                     maxTime::AbstractFloat = Inf)

Sets the stop conditions for `genj`, however if none are introduced, `maxIterations`
will be set to 100 by default. This function constructs a structure of type
`StopCondition` and adds it to the main structure.

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.
- `maxEvaluations::Integer = -1`: number of calls to compute fitness before the
    algorithm stops. If it is set to a `negative value`, the verification over
    this parameter will be `useless`, as default.
- `maxIterations::Integer = -1`: number of iterations before the algorithm stops.
    If it is set to a `negative value`, the verification over this parameter
    will be `useless`, as default.
- `maxIterNotImproving::Integer = -1`: number of iterations in which the best
    individual doesn't improve before the algorithm stops. If it is set to a
    `negative value`, the verification over this parameter will be `useless`, as default.
- `maxTime::AbstractFloat = Inf`: time, in seconds, passed since the beginning of the
    experiment before the algorithm stops. If it is set to `inf`, the verification
    over this parameter will be `useless`, as default.

See also: [`StopCondition`](@ref)
"""
function setStopCondition(; genj::GenJulia = GenJ, maxEvaluations::Integer = typemax(Int64),
                          maxIterations::Integer = typemax(Int64),
                          maxIterNotImproving::Integer = typemax(Int64),
                          maxTime::AbstractFloat = Inf)

    if maxTime < 0
        error("maxTime must be a positive number")
    end

    if (maxEvaluations < 1) && (maxIterations < 1) && (maxIterNotImproving < 1) && (maxTime == Inf)
        error("At least one of the stop conditions must be set to a value that allows checking")
    end

    stopCondition = StopCondition(maxEvaluations, maxIterations,
                                  maxIterNotImproving, maxTime, 0, 0, 0, 0)
    genj._stopCondition = stopCondition
end # function
export setStopCondition



"""
    showStopConditions(genj::GenJulia = GenJ)

documentation
"""
function showStopConditions(; genj::GenJulia = GenJ, outputFile::String = "")
    if isdefined(genj, :_stopCondition)
        io = outputFile != "" ? open(outputFile, "a") : Base.stdout

        flush(io)

        if genj._stopCondition._maxIterations != typemax(Int64)
            println(io, "Maximum number of iterations: ", genj._stopCondition._maxIterations)
            println(io, "Current number of iterations: ", genj._stopCondition._numIterations)
            println(io)
        end
        if genj._stopCondition._maxEvaluations != typemax(Int64)
            println(io, "Maximum number of evaluations: ", genj._stopCondition._maxEvaluations)
            println(io, "Current number of evaluations: ", genj._stopCondition._numEvaluations)
            println(io)
        end
        if genj._stopCondition._maxIterNotImproving != typemax(Int64)
            println(io, "Maximum number of iterations without a new best individual: ", genj._stopCondition._maxIterNotImproving)
            println(io, "Current number of iterations without a new best individual: ", genj._stopCondition._numIterNotImproving)
            println(io)
        end
        if genj._stopCondition._maxTime != Inf
            println(io, "Maximum run time: ", genj._stopCondition._maxTime)
            println(io, "Elapsed time: ", time() - genj._stopCondition._initialTime)
        end
    else
        error("Stop Condition has not been set yet. Use the function setStopCondition.")
    end

    return nothing
end # function
export showStopConditions
