"""
    checkMethodsDefined(GenJ)

documentation
"""
function checkParametersDefined(GenJ::GeneticJulia, index::Int = 0)

    if index == 0
        if !isdefined(GenJ._experimentInfo, :_individualType)
            error("The experiment individualType must be set")
        end

        if !isdefined(GenJ._experimentInfo, :_algorithm)
            error("The experiment algorithm must be set")
        end

        if !isdefined(GenJ, :_evaluator)
            error("The evaluator must be set")
        end

        if !isdefined(GenJ, :_generator)
            error("The generator must be set")
        end

        if !isdefined(GenJ, :_selector)
            error("The selector must be set")
        end

        if !isdefined(GenJ, :_crossoverOp)
            error("The crossover operator must be set")
        end

        if !isdefined(GenJ, :_mutationOp)
            error("The mutation operator must be set")
        end

        if !isdefined(GenJ, :_replacementOp)
            error("The replacement operator must be set")
        end
    else
        if !isdefined(GenJ._experimentInfo, :_individualType)
            error("The experiment individualType must be set " * string(index))
        end

        if !isdefined(GenJ._experimentInfo, :_algorithm)
            error("The experiment algorithm must be set in experiment " * string(index))
        end

        if !isdefined(GenJ, :_evaluator)
            error("The evaluator must be set in experiment " * string(index))
        end

        if !isdefined(GenJ, :_generator)
            error("The generator must be set in experiment " * string(index))
        end

        if !isdefined(GenJ, :_selector)
            error("The selector must be set in experiment " * string(index))
        end

        if !isdefined(GenJ, :_crossoverOp)
            error("The crossover operator must be set in experiment " * string(index))
        end

        if !isdefined(GenJ, :_mutationOp)
            error("The mutation operator must be set in experiment " * string(index))
        end

        if !isdefined(GenJ, :_replacementOp)
            error("The replacement operator must be set in experiment " * string(index))
        end
    end
end # function


function checkParametersCorrectGP(GenJ::GeneticJulia, index::Int = 0)

    rng = Random.MersenneTwister(1234)
    if index == 0
        if !isdefined(GenJ._experimentInfo, :_GPExperimentInfo)
            error("Information about Genetic Programming problem has not been given for a GP problem ($(GenJ._experimentInfo._individualType)), this information must be specified in setGPInfo")
        end
    else
        if !isdefined(GenJ._experimentInfo, :_GPExperimentInfo)
            error("Information about Genetic Programming problem has not been given for a GP problem ($(GenJ._experimentInfo._individualType)), this information must be specified in setGPInfo in experiment $index")
        end
    end

    functionSet = GenJ._experimentInfo._GPExperimentInfo._functionSet
    terminalSet = GenJ._experimentInfo._GPExperimentInfo._terminalSet

    OneByOne = true
    All = true
    ind = 0

    try
        ind = GenJ._generator._method(functionSet, terminalSet, 3, rng, GenJ._generator._varArgs...)
    catch e
        if isa(e, MethodError)
            OneByOne = false
        end
    end

    try
        ind = GenJ._generator._method(1, functionSet, terminalSet, 3, rng, GenJ._generator._varArgs...)
    catch e
        if isa(e, MethodError)
            All = false
        end
    end

    if index == 0

        if !(All || OneByOne)
            error("Generation method ($(GenJ._generator._method)) introduced is not compatible with arguments specified")
        end

        ind = All ? GenJ._generator._method(1, functionSet, terminalSet, 3, rng, GenJ._generator._varArgs...) : GenJ._generator._method(functionSet, terminalSet, 3, rng, GenJ._generator._varArgs...)

        if !OneByOne && GenJ._generator._generateOneByOne
            error("Generation method ($(GenJ._generator._method)) receives the population size, however, generateOneByOne is set to true")
        end

        if typeof(ind) <: Array && OneByOne
            error("Generation method ($(GenJ._generator._method)) returns an array of individuals while generateOneByOne is set to true, it should return a single individual")
        end

        if !All && !GenJ._generator._generateOneByOne
            error("Generation method ($(GenJ._generator._method)) doesn't receive the population size, however, generateOneByOne is set to false")
        end

        if !(typeof(ind) <: Array) && All
            error("Generation method ($(GenJ._generator._method)) returns a single individual while generateOneByOne is set to false, it should return an array of individuals")
        end
    else

        if !(All || OneByOne)
            error("Generation method ($(GenJ._generator._method)) introduced is not compatible with arguments specified in experiment $index")
        end

        ind = All ? GenJ._generator._method(1, functionSet, terminalSet, 3, rng, GenJ._generator._varArgs...) : GenJ._generator._method(functionSet, terminalSet, 3, rng, GenJ._generator._varArgs...)

        if !OneByOne && GenJ._generator._generateOneByOne
            error("Generation method ($(GenJ._generator._method)) receives the population size, however, generateOneByOne is set to true in experiment $index")
        end

        if typeof(ind) <: Array && OneByOne
            error("Generation method ($(GenJ._generator._method)) returns an array of individuals while generateOneByOne is set to true, it should return a single individual in experiment $index")
        end

        if !All && !GenJ._generator._generateOneByOne
            error("Generation method ($(GenJ._generator._method)) doesn't receive the population size, however, generateOneByOne is set to false in experiment $index")
        end

        if !(typeof(ind) <: Array) && All
            error("Generation method ($(GenJ._generator._method)) returns a single individual while generateOneByOne is set to false, it should return an array of individuals in experiment $index")
        end
    end

    margin = 1e-6
    nParents = GenJ._crossoverOp._nParents
    nChildren = GenJ._crossoverOp._nChildren
    individuals = Array{Genotype}(undef, nParents)
    popSize = GenJ._generator._popSize
    k = 0
    fitness = 0

    nSelectedParents = getNSelectedParents(GenJ._selector)
    if !(typeof(nSelectedParents) <: Int)
        nSelectedParents = convert(Int, round(nSelectedParents * popSize))
        remainder = nSelectedParents % nParents

        if remainder != 0
            nSelectedParents = nSelectedParents + nParents - remainder
        end

        if !GenJ._selector._samplingWithRep && nSelectedParents > popSize
            nSelectedParents -= nParents
        end
    end

    if GenJ._generator._generateOneByOne
        for i=1:nParents
            individuals[i] = GenJ._generator._method(GenJ._experimentInfo._GPExperimentInfo._functionSet, GenJ._experimentInfo._GPExperimentInfo._terminalSet, 3, rng, GenJ._generator._varArgs...)
        end

    else
        individuals = GenJ._generator._method(nParents, GenJ._experimentInfo._GPExperimentInfo._functionSet, GenJ._experimentInfo._GPExperimentInfo._terminalSet, 3, rng, GenJ._generator._varArgs...)
    end


    if index == 0
        if GenJ._crossoverOp._probability < margin && GenJ._mutationOp._probability < margin
            error("Either crossover or mutation or both must have a probability above 0")
        end

        if typeof(individuals[1]) != GenJ._experimentInfo._individualType
            error("Generation method ($(GenJ._generator._method)) should generate individuals (you generate $(typeof(individuals[1]))) of the same type as the one specified in individualType ($(GenJ._experimentInfo._individualType))")
        end
#fitness = fitnessEval(GenJ._evaluator._fitnessFunctions[1], GenJ._experimentInfo._GPExperimentInfo, individuals[1])
        try
            len = length(GenJ._evaluator._fitnessFunctions)
            k = 1

            for i=1:len
                fitness = fitnessEval(GenJ._evaluator._fitnessFunctions[i], GenJ._experimentInfo._GPExperimentInfo, individuals[1])

                if !(typeof(fitness) <: Number)
                    throw(TypeError(fitness, ""))
                end
                k = k + 1
            end
        catch e

            if isa(e, MethodError)
                error("Fitness function ($(GenJ._evaluator._fitnessFunctions[k]._fitnessFunction)) is not compatible with the individual type ($(GenJ._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The fitness ($fitness) of an individual generated by ($(GenJ._evaluator._fitnessFunctions[k]._fitnessFunction)) must be numerical")
            end
        end

        if (nSelectedParents % nParents) != 0
            error("The number of selected parents ($nSelectedParents) is not divisible by number of parents per cross ($nParents)")
        end

        if !GenJ._selector._samplingWithRep && nSelectedParents > popSize
            error("Number of selected parents ($nSelectedParents) should not be greater than population size ($popSize) when selection method is without replacement")
        end

        try
            childCross = GenJ._crossoverOp._method(individuals..., 3, rng, GenJ._crossoverOp._varArgs...)
            len = length(childCross)
            if len != GenJ._crossoverOp._nChildren
                error("Children generated by crossover ($len) must match the number of children given as argument ($(GenJ._crossoverOp._nChildren))")
            end
            typeassert(childCross[1], typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The crossover method ($(GenJ._crossoverOp._method)) is not compatible with the individual type generated ($(GenJ._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childCross[1]))) generated by crossover does not match the type of its parents ($(GenJ._experimentInfo._individualType))")
            end
        end

        try
            childMut = GenJ._mutationOp._method(individuals[1], 3, GenJ._generator._functionSet, GenJ._generator._terminalSet, rng, GenJ._mutationOp._varArgs...)
            typeassert(childMut, typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The mutation method ($(GenJ._mutationOp._method)) is not compatible with the individual type generated ($(GenJ._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childMut))) generated by mutation does not match the type of its parent ($(GenJ._experimentInfo._individualType))")
            end
        end

    else
        if GenJ._crossoverOp._probability < margin && GenJ._mutationOp._probability < margin
            error("Either crossover or mutation or both must have a probability above 0 in experiment $index")
        end

        if typeof(individuals[1]) != GenJ._experimentInfo._individualType
            error("Generation method ($(GenJ._generator._method)) should generate individuals (you generate $(typeof(individuals[1]))) of the same type as the one specified in individualType ($(GenJ._experimentInfo._individualType)) in experiment $index")
        end

        try
            len = length(GenJ._evaluator._fitnessFunctions)
            k = 1

            for i=1:len
                fitness = fitnessEval(GenJ._evaluator._fitnessFunctions[i], GenJ._experimentInfo._GPExperimentInfo, individuals[1])

                if !(typeof(fitness) <: Number)
                    throw(TypeError(fitness, ""))
                end
                k = k + 1
            end
        catch e
            if isa(e, MethodError)
                error("Fitness function ($(GenJ._evaluator._fitnessFunctions[k]._fitnessFunction)) is not compatible with the individual type ($(GenJ._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The fitness ($fitness) of an individual generated by ($(GenJ._evaluator._fitnessFunctions[k]._fitnessFunction)) must be numerical in experiment $index")
            end
        end

        if (nSelectedParents % nParents) != 0
            error("The number of selected parents ($nSelectedParents) is not divisible by number of parents per cross ($nParents) in experiment $index")
        end

        if !GenJ._selector._samplingWithRep && nSelectedParents > popSize
            error("Number of selected parents ($nSelectedParents) should not be greater than population size ($popSize) when selection method is without replacement in experiment $index")
        end

        try
            childCross = GenJ._crossoverOp._method(individuals..., 3, rng, GenJ._crossoverOp._varArgs...)
            len = length(childCross)
            if len != GenJ._crossoverOp._nChildren
                error("Children generated by crossover ($len) must match the number of children given as argument ($(GenJ._crossoverOp._nChildren)) in experiment $index")
            end
            typeassert(childCross[1], typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The crossover method ($(GenJ._crossoverOp._method)) is not compatible with the individual type generated ($(GenJ._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childCross[1]))) generated by crossover does not match the type of its parents ($(GenJ._experimentInfo._individualType)) in experiment $index")
            end
        end

        try
            childMut = GenJ._mutationOp._method(individuals[1], 3, GenJ._generator._functionSet, GenJ._generator._terminalSet, rng, GenJ._mutationOp._varArgs...)
            typeassert(childMut, typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The mutation method ($(GenJ._mutationOp._method)) is not compatible with the individual type generated ($(GenJ._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childMut))) generated by mutation does not match the type of its parent ($(GenJ._experimentInfo._individualType)) in experiment $index")
            end
        end

    end


end

function checkParametersCorrectGA(GenJ::GeneticJulia, index::Int = 0)
    rng = Random.MersenneTwister(1234)
    OneByOne = true
    All = true
    ind = 0

    if index == 0
        if isdefined( GenJ._experimentInfo, :_GPExperimentInfo)
            @warn "Information about Genetic Programming problem has been given for a non-GP problem ($(GenJ._experimentInfo._individualType)), this information will be dismissed"
        end
    else
        if isdefined( GenJ._experimentInfo, :_GPExperimentInfo)
            @warn "Information about Genetic Programming problem has been given for a non-GP problem ($(GenJ._experimentInfo._individualType)), this information will be dismissed in experiment $index"
        end
    end

    try
        ind = GenJ._generator._method(rng, GenJ._generator._varArgs...)
    catch e
        if isa(e, MethodError)
            OneByOne = false
        end
    end

    try
        ind = GenJ._generator._method(1, rng, GenJ._generator._varArgs...)
    catch e
        if isa(e, MethodError)
            All = false
        end
    end

    if index == 0

        if !(All || OneByOne)
            error("Generation method ($(GenJ._generator._method)) introduced is not compatible with arguments specified")
        end

        ind = All ? GenJ._generator._method(1, rng, GenJ._generator._varArgs...) : GenJ._generator._method(rng, GenJ._generator._varArgs...)

        if !OneByOne && GenJ._generator._generateOneByOne
            error("Generation method ($(GenJ._generator._method)) receives the population size, however, generateOneByOne is set to true")
        end

        if typeof(ind) <: Array && OneByOne
            error("Generation method ($(GenJ._generator._method)) returns an array of individuals while generateOneByOne is set to true, it should return a single individual")
        end

        if !All && !GenJ._generator._generateOneByOne
            error("Generation method ($(GenJ._generator._method)) doesn't receive the population size, however, generateOneByOne is set to false")
        end

        if !(typeof(ind) <: Array) && All
            error("Generation method ($(GenJ._generator._method)) returns a single individual while generateOneByOne is set to false, it should return an array of individuals")
        end
    else

        if !(All || OneByOne)
            error("Generation method ($(GenJ._generator._method)) introduced is not compatible with arguments specified in experiment $index")
        end

        ind = All ? GenJ._generator._method(1, rng, GenJ._generator._varArgs...) : GenJ._generator._method(rng, GenJ._generator._varArgs...)

        if !OneByOne && GenJ._generator._generateOneByOne
            error("Generation method ($(GenJ._generator._method)) receives the population size, however, generateOneByOne is set to true in experiment $index")
        end

        if typeof(ind) <: Array && OneByOne
            error("Generation method ($(GenJ._generator._method)) returns an array of individuals while generateOneByOne is set to true, it should return a single individual in experiment $index")
        end

        if !All && !GenJ._generator._generateOneByOne
            error("Generation method ($(GenJ._generator._method)) doesn't receive the population size, however, generateOneByOne is set to false in experiment $index")
        end

        if !(typeof(ind) <: Array) && All
            error("Generation method ($(GenJ._generator._method)) returns a single individual while generateOneByOne is set to false, it should return an array of individuals in experiment $index")
        end
    end


    margin = 1e-6
    nParents = GenJ._crossoverOp._nParents
    nChildren = GenJ._crossoverOp._nChildren
    individuals = Array{Genotype}(undef, nParents)
    popSize = GenJ._generator._popSize
    fitness = 0
    k = 0

    nSelectedParents = getNSelectedParents(GenJ._selector)
    if !(typeof(nSelectedParents) <: Int)
        nSelectedParents = convert(Int, round(nSelectedParents * popSize))
        remainder = nSelectedParents % nParents

        if remainder != 0
            nSelectedParents = nSelectedParents + nParents - remainder
        end

        if !GenJ._selector._samplingWithRep && nSelectedParents > popSize
            nSelectedParents -= nParents
        end
    end

    if GenJ._generator._generateOneByOne
        for i=1:nParents
            individuals[i] = GenJ._generator._method(rng, GenJ._generator._varArgs...)
        end

    else
        individuals = GenJ._generator._method(nParents, rng, GenJ._generator._varArgs...)
    end

    if index == 0
        if GenJ._crossoverOp._probability < margin && GenJ._mutationOp._probability < margin
            error("Either crossover or mutation or both must have a probability above 0")
        end

        if typeof(individuals[1]) != GenJ._experimentInfo._individualType
            error("Generation method ($(GenJ._generator._method)) should generate individuals (you generate $(typeof(individuals[1]))) of the same type as the one specified in individualType ($(GenJ._experimentInfo._individualType))")
        end
fitnessEval(GenJ._evaluator._fitnessFunctions[1], individuals[1])
        try
            len = length(GenJ._evaluator._fitnessFunctions)
            k = 1

            for i=1:len
                fitness = fitnessEval(GenJ._evaluator._fitnessFunctions[i], individuals[1])

                if !(typeof(fitness) <: Number)
                    throw(TypeError(fitness, ""))
                end
                k = k + 1
            end
        catch e
            if isa(e, MethodError)
                error("Fitness function ($(GenJ._evaluator._fitnessFunctions[k]._fitnessFunction)) is not compatible with the individual type ($(GenJ._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The fitness ($fitness) of an individual generated by ($(GenJ._evaluator._fitnessFunctions[k]._fitnessFunction)) must be numerical")
            end
        end

        if (nSelectedParents % nParents) != 0
            error("The number of selected parents ($nSelectedParents) is not divisible by number of parents per cross ($nParents)")
        end

        if !GenJ._selector._samplingWithRep && nSelectedParents > popSize
            error("Number of selected parents ($nSelectedParents) should not be greater than population size ($popSize) when selection method is without replacement")
        end

        try
            childCross = GenJ._crossoverOp._method(individuals..., rng, GenJ._crossoverOp._varArgs...)
            len = length(childCross)
            if len != GenJ._crossoverOp._nChildren
                error("Children generated by crossover ($len) must match the number of children given as argument ($(GenJ._crossoverOp._nChildren))")
            end
            typeassert(childCross[1], typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The crossover method ($(GenJ._crossoverOp._method)) is not compatible with the individual type generated ($(GenJ._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childCross[1]))) generated by crossover does not match the type of its parents ($(GenJ._experimentInfo._individualType))")
            end
        end

        try
            childMut = GenJ._mutationOp._method(individuals[1], rng, GenJ._mutationOp._varArgs...)
            typeassert(childMut, typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The mutation method ($(GenJ._mutationOp._method)) is not compatible with the individual type generated ($(GenJ._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childMut))) generated by mutation does not match the type of its parent ($(GenJ._experimentInfo._individualType))")
            end
        end
    else

        if GenJ._crossoverOp._probability < margin && GenJ._mutationOp._probability < margin
            error("Either crossover or mutation or both must have a probability above 0 in experiment $index")
        end

        if typeof(individuals[1]) != GenJ._experimentInfo._individualType
            error("Generation method ($(GenJ._generator._method)) should generate individuals (you generate $(typeof(individuals[1]))) of the same type as the one specified in individualType ($(GenJ._experimentInfo._individualType)) in experiment $index")
        end

        try
            len = length(GenJ._evaluator._fitnessFunctions)
            k = 1

            for i=1:len
                fitness = fitnessEval(GenJ._evaluator._fitnessFunctions[i], individuals[1])

                if !(typeof(fitness) <: Number)
                    throw(TypeError(fitness, ""))
                end
                k = k + 1
            end
        catch e
            if isa(e, MethodError)
                error("Fitness function ($(GenJ._evaluator._fitnessFunctions[k]._fitnessFunction)) is not compatible with the individual type ($(GenJ._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The fitness ($fitness) of an individual generated by ($(GenJ._evaluator._fitnessFunctions[k]._fitnessFunction)) must be numerical in experiment $index")
            end
        end

        if (nSelectedParents % nParents) != 0
            error("The number of selected parents ($nSelectedParents) is not divisible by number of parents per cross ($nParents) in experiment $index")
        end

        if !GenJ._selector._samplingWithRep && nSelectedParents > popSize
            error("Number of selected parents ($nSelectedParents) should not be greater than population size ($popSize) when selection method is without replacement in experiment $index")
        end

        try
            childCross = GenJ._crossoverOp._method(individuals..., rng, GenJ._crossoverOp._varArgs...)
            len = length(childCross)
            if len != GenJ._crossoverOp._nChildren
                error("Children generated by crossover ($len) must match the number of children given as argument ($(GenJ._crossoverOp._nChildren)) in experiment $index")
            end
            typeassert(childCross[1], typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The crossover method ($(GenJ._crossoverOp._method)) is not compatible with the individual type generated ($(GenJ._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childCross[1]))) generated by crossover does not match the type of its parents ($(GenJ._experimentInfo._individualType)) in experiment $index")
            end
        end

        try
            childMut = GenJ._mutationOp._method(individuals[1], rng, GenJ._mutationOp._varArgs...)
            typeassert(childMut, typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The mutation method ($(GenJ._mutationOp._method)) is not compatible with the individual type generated ($(GenJ._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childMut))) generated by mutation does not match the type of its parent ($(GenJ._experimentInfo._individualType)) in experiment $index")
            end
        end
    end
end


"""
    checkParameters(GenJ)

Checks that everything has been set correctly before running an experiment.
"""
function checkParametersCorrect(GenJ::GeneticJulia, index::Int = 0)

    if GenJ._experimentInfo._individualType <: GPGenotype
        checkParametersCorrectGP(GenJ, index)
    else
        checkParametersCorrectGA(GenJ, index)
    end

end # function
