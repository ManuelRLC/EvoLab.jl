using .EvoLab.GP.CGP: CGPGenotype, CGPInfo
using .EvoLab.GP.STGP: STGPGenotype, STGPInfo
using .EvoLab.GP.GEP: GEPGenotype, GEPInfo
using .EvoLab.GP.GE: GEGenotype, GEInfo
using .EvoLab.GP: getType


"""
    checkMethodsDefined(genj)

Check wether every tool of the structure of the experiment is defined or not.
"""
function checkParametersDefined(genj::GenJulia, index::Integer = 0)

    if index == 0
        if !isdefined(genj._experimentInfo, :_individualType)
            error("The experiment individualType must be set")
        end

        if !isdefined(genj._experimentInfo, :_algorithm)
            error("The experiment algorithm must be set")
        end

        if !isdefined(genj, :_evaluator)
            error("The evaluator must be set")
        end

        if !isdefined(genj, :_generator)
            error("The generator must be set")
        end

        if !isdefined(genj, :_selector)
            error("The selector must be set")
        end

        if !isdefined(genj, :_crossoverOp)
            error("The crossover operator must be set")
        end

        if !isdefined(genj, :_mutationOp)
            error("The mutation operator must be set")
        end

        if !isdefined(genj, :_replacementOp)
            error("The replacement operator must be set")
        end
    else
        if !isdefined(genj._experimentInfo, :_individualType)
            error("The experiment individualType must be set " * string(index))
        end

        if !isdefined(genj._experimentInfo, :_algorithm)
            error("The experiment algorithm must be set in experiment " * string(index))
        end

        if !isdefined(genj, :_evaluator)
            error("The evaluator must be set in experiment " * string(index))
        end

        if !isdefined(genj, :_generator)
            error("The generator must be set in experiment " * string(index))
        end

        if !isdefined(genj, :_selector)
            error("The selector must be set in experiment " * string(index))
        end

        if !isdefined(genj, :_crossoverOp)
            error("The crossover operator must be set in experiment " * string(index))
        end

        if !isdefined(genj, :_mutationOp)
            error("The mutation operator must be set in experiment " * string(index))
        end

        if !isdefined(genj, :_replacementOp)
            error("The replacement operator must be set in experiment " * string(index))
        end
    end
end # function


personalizedError(individualType, genj, index) = return nothing

"""
    checkParametersCorrectGP(genj::GenJulia, index::Int64 = 0)

Check that all the tools of the experiment are coherent.
"""
function checkParametersCorrectGP(genj::GenJulia, index::Int64 = 0)

    rng = Random.MersenneTwister(1234)

    ####### GA AND GP DISTINCTION #######

    if index == 0
        if !isdefined(genj._experimentInfo, :_GPExperimentInfo)
            error("Information about Genetic Programming problem has not been given for a GP problem ($(genj._experimentInfo._individualType)), this information must be specified in setGPInfo")
        elseif typeof(genj._experimentInfo._GPExperimentInfo) <: CGPInfo && genj._experimentInfo._individualType != CGPGenotype
            error("Information about Canonical Genetic Programming problem has been given for a non CGP problem ($(genj._experimentInfo._individualType))")
        elseif typeof(genj._experimentInfo._GPExperimentInfo) <: STGPInfo && genj._experimentInfo._individualType != STGPGenotype
            error("Information about Strongly Typed Genetic Programming problem has been given for a non STGP problem ($(genj._experimentInfo._individualType))")
        elseif typeof(genj._experimentInfo._GPExperimentInfo) <: GEPInfo && genj._experimentInfo._individualType != GEPGenotype
            error("Information about Gene Expression Programming problem has been given for a non GEP problem ($(genj._experimentInfo._individualType))")
        end
    else
        if !isdefined(genj._experimentInfo, :_GPExperimentInfo)
            error("Information about Genetic Programming problem has not been given for a GP problem ($(genj._experimentInfo._individualType)), this information must be specified in setGPInfo in experiment $index")
        elseif typeof(genj._experimentInfo._GPExperimentInfo) <: CGPInfo && genj._experimentInfo._individualType != CGPGenotype
            error("Information about Canonical Genetic Programming problem has been given for a non CGP problem ($(genj._experimentInfo._individualType)) in experiment $index")
        elseif typeof(genj._experimentInfo._GPExperimentInfo) <: STGPInfo && genj._experimentInfo._individualType != STGPGenotype
            error("Information about Strongly Typed Genetic Programming problem has been given for a non STGP problem ($(genj._experimentInfo._individualType)) in experiment $index")
        elseif typeof(genj._experimentInfo._GPExperimentInfo) <: GEPInfo && genj._experimentInfo._individualType != GEPGenotype
            error("Information about Gene Expression Programming problem has been given for a non GEP problem ($(genj._experimentInfo._individualType)) in experiment $index")
        end
    end

    if genj._experimentInfo._individualType == GEPGenotype || genj._experimentInfo._individualType == CGPGenotype
        functionSet = genj._experimentInfo._GPExperimentInfo._functionSet
        terminalSet = genj._experimentInfo._GPExperimentInfo._terminalSet

        if index == 0
            type = getType(terminalSet[1])
            nTerminals = length(terminalSet)

            for i=2:nTerminals
                if !(getType(terminalSet[i]) <: type)
                    error("A terminal has type different from $type. All terminals must have the same type ($(getType(terminalSet[i])))")
                end
            end

            for func in functionSet
                if !(getType(func) <: type)
                    error("A function returns a type different from $type ($(getType(func)))")
                end

                for argType in func._argTypes
                    if !(argType <: type)
                        error("A function receives an argument of type different from $type ($argType)")
                    end
                end
            end
        else
            type = getType(terminalSet[1])
            nTerminals = length(terminalSet)

            for i=2:nTerminals
                if !(getType(terminalSet[i]) <: type)
                    error("A terminal has type different from $type. All terminals must have the same type in experiment $index ($(getType(func)))")
                end
            end

            for func in functionSet
                if !(getType(func) <: type)
                    println(func)
                    error("A function returns a type different from $type in experiment $index ($(getType(func)))")
                end

                for argType in func._argTypes
                    if !(argType <: type)
                        error("A function receives an argument of type different from $type in experiment $index ($(getType(func)))")
                    end
                end
            end
        end
    end

    OneByOne = true
    All = true
    ind = 0

    try
        ind = genj._generator._method(genj._experimentInfo._GPExperimentInfo, rng, genj._generator._varArgs...)
    catch e
        if isa(e, MethodError)
            OneByOne = false
        end
    end
    
    try
        ind = genj._generator._method(genj._experimentInfo._GPExperimentInfo, one(UInt32), rng, genj._generator._varArgs...)
    catch e
        if isa(e, MethodError)
            All = false
        end
    end



    if index == 0
        if !(All || OneByOne)
            error("Generation method ($(genj._generator._method)) introduced is not compatible with arguments specified")
        end

        ind = All ? genj._generator._method(genj._experimentInfo._GPExperimentInfo, one(UInt32), rng, genj._generator._varArgs...) : genj._generator._method(genj._experimentInfo._GPExperimentInfo, rng, genj._generator._varArgs...)

        if !OneByOne && genj._generator._generateOneByOne
            error("Generation method ($(genj._generator._method)) receives the population size, however, generateOneByOne is set to true")
        end

        if typeof(ind) <: Array && OneByOne
            error("Generation method ($(genj._generator._method)) returns an array of individuals while generateOneByOne is set to true, it should return a single individual")
        end

        if !All && !genj._generator._generateOneByOne
            error("Generation method ($(genj._generator._method)) doesn't receive the population size, however, generateOneByOne is set to false")
        end

        if !(typeof(ind) <: Array) && All
            error("Generation method ($(genj._generator._method)) returns a single individual while generateOneByOne is set to false, it should return an array of individuals")
        end
    else

        if !(All || OneByOne)
            error("Generation method ($(genj._generator._method)) introduced is not compatible with arguments specified in experiment $index")
        end

        ind = All ? genj._generator._method(genj._experimentInfo._GPExperimentInfo, one(UInt32), rng, genj._generator._varArgs...) : genj._generator._method(genj._experimentInfo._GPExperimentInfo, rng, genj._generator._varArgs...)

        if !OneByOne && genj._generator._generateOneByOne
            error("Generation method ($(genj._generator._method)) receives the population size, however, generateOneByOne is set to true in experiment $index")
        end

        if typeof(ind) <: Array && OneByOne
            error("Generation method ($(genj._generator._method)) returns an array of individuals while generateOneByOne is set to true, it should return a single individual in experiment $index")
        end

        if !All && !genj._generator._generateOneByOne
            error("Generation method ($(genj._generator._method)) doesn't receive the population size, however, generateOneByOne is set to false in experiment $index")
        end

        if !(typeof(ind) <: Array) && All
            error("Generation method ($(genj._generator._method)) returns a single individual while generateOneByOne is set to false, it should return an array of individuals in experiment $index")
        end
    end


    margin = 1e-6
    nParents = genj._crossoverOp._nParents
    nChildren = genj._crossoverOp._nChildren
    individuals = Array{Genotype}(undef, nParents)
    popSize = genj._generator._popSize
    k = 0
    fitness = 0


    nSelectedParents = getNSelectedParents(genj._selector)
    if !(typeof(nSelectedParents) <: Integer)
        nSelectedParents = convert(Integer, round(nSelectedParents * popSize))
        remainder = nSelectedParents % nParents

        if remainder != 0
            nSelectedParents = nSelectedParents + nParents - remainder
        end

        if !genj._selector._samplingWithRep && nSelectedParents > popSize
            nSelectedParents -= nParents
        end
    end


    ####### GENERATION #######

    if genj._generator._generateOneByOne
        for i=1:nParents
            individuals[i] = genj._generator._method(genj._experimentInfo._GPExperimentInfo, rng, genj._generator._varArgs...)
        end
    else
        individuals = genj._generator._method(genj._experimentInfo._GPExperimentInfo, convert(UInt32, nParents), rng, genj._generator._varArgs...)
    end


    ####### CROSSOVER, MUTATION AND EVALUATION #######

    if index == 0

        if genj._replacementOp._eliteSize > genj._generator._popSize
            error("Size of elite set is greater than the size of the population")
        end

        if genj._crossoverOp._probability < margin && genj._mutationOp._probability < margin
            error("Either crossover or mutation or both must have a probability above 0")
        end

        if typeof(individuals[1]) != genj._experimentInfo._individualType
            error("Generation method ($(genj._generator._method)) should generate individuals (you generate $(typeof(individuals[1]))) of the same type as the one specified in individualType ($(genj._experimentInfo._individualType))")
        end

#fitness = fitnessEval(genj._evaluator._fitnessFunctions[1], genj._experimentInfo._GPExperimentInfo, individuals[1])
        try
            len = length(genj._evaluator._fitnessFunctions)
            k = 1

            for i=1:len
                fitness = fitnessEval(genj._evaluator._fitnessFunctions[i], genj._experimentInfo._GPExperimentInfo, individuals[1])

                if !(typeof(fitness) <: Real)
                    throw(TypeError(fitness, ""))
                end
                k = k + 1
            end
        catch e

            if isa(e, MethodError)
                error("Fitness function ($(genj._evaluator._fitnessFunctions[k]._fitnessFunction)) is not compatible with the individual type ($(genj._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The fitness ($fitness) of an individual generated by ($(genj._evaluator._fitnessFunctions[k]._fitnessFunction)) must be numerical")
            end
        end



        if (nSelectedParents % nParents) != 0
            error("The number of selected parents ($nSelectedParents) is not divisible by number of parents per cross (\$nParents)")
        end

        if !genj._selector._samplingWithRep && nSelectedParents > popSize
            error("Number of selected parents ($nSelectedParents) should not be greater than population size (\$popSize) when selection method is without replacement")
        end

#childCross = genj._crossoverOp._method(individuals..., genj._experimentInfo._GPExperimentInfo, rng, genj._crossoverOp._varArgs...)
        try
            childCross = genj._crossoverOp._method(individuals..., genj._experimentInfo._GPExperimentInfo, rng, genj._crossoverOp._varArgs...)

            len = length(childCross)
            if len != genj._crossoverOp._nChildren
                error("Children generated by crossover ($len) must match the number of children given as argument ($(genj._crossoverOp._nChildren))")
            end
            typeassert(childCross[1], typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The crossover method ($(genj._crossoverOp._method)) is not compatible with the individual type generated ($(genj._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childCross[1]))) generated by crossover does not match the type of its parents ($(genj._experimentInfo._individualType))")
            end
        end

        try
            childMut = genj._mutationOp._method(individuals[1], genj._experimentInfo._GPExperimentInfo, rng, genj._mutationOp._varArgs...)
            typeassert(childMut, typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The mutation method ($(genj._mutationOp._method)) is not compatible with the individual type generated ($(genj._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childMut))) generated by mutation does not match the type of its parent ($(genj._experimentInfo._individualType))")
            end
        end


    else


        if genj._replacementOp._eliteSize > genj._generator._popSize
            error("Size of elite set is greater than the size of the population in experiment $index")
        end

        if genj._crossoverOp._probability < margin && genj._mutationOp._probability < margin
            error("Either crossover or mutation or both must have a probability above 0 in experiment $index")
        end

        if typeof(individuals[1]) != genj._experimentInfo._individualType
            error("Generation method ($(genj._generator._method)) should generate individuals (you generate $(typeof(individuals[1]))) of the same type as the one specified in individualType ($(genj._experimentInfo._individualType)) in experiment $index")
        end


        try
            len = length(genj._evaluator._fitnessFunctions)
            k = 1

            for i=1:len
                fitness = fitnessEval(genj._evaluator._fitnessFunctions[i], genj._experimentInfo._GPExperimentInfo, individuals[1])

                if !(typeof(fitness) <: Real)
                    throw(TypeError(fitness, ""))
                end
                k = k + 1
            end
        catch e
            if isa(e, MethodError)
                error("Fitness function ($(genj._evaluator._fitnessFunctions[k]._fitnessFunction)) is not compatible with the individual type ($(genj._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The fitness ($fitness) of an individual generated by ($(genj._evaluator._fitnessFunctions[k]._fitnessFunction)) must be numerical in experiment $index")
            end
        end

        if (nSelectedParents % nParents) != 0
            error("The number of selected parents ($nSelectedParents) is not divisible by number of parents per cross ($nParents) in experiment $index")
        end

        if !genj._selector._samplingWithRep && nSelectedParents > popSize
            error("Number of selected parents ($nSelectedParents) should not be greater than population size ($popSize) when selection method is without replacement in experiment $index")
        end


        try
            childCross = genj._crossoverOp._method(individuals..., genj._experimentInfo._GPExperimentInfo, rng, genj._crossoverOp._varArgs...)
            len = length(childCross)
            if len != genj._crossoverOp._nChildren
                error("Children generated by crossover ($len) must match the number of children given as argument ($(genj._crossoverOp._nChildren)) in experiment $index")
            end
            typeassert(childCross[1], typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The crossover method ($(genj._crossoverOp._method)) is not compatible with the individual type generated ($(genj._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childCross[1]))) generated by crossover does not match the type of its parents ($(genj._experimentInfo._individualType)) in experiment $index")
            end
        end


        try
            childMut = genj._mutationOp._method(individuals[1], genj._experimentInfo._GPExperimentInfo, rng, genj._mutationOp._varArgs...)
            typeassert(childMut, typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The mutation method ($(genj._mutationOp._method)) is not compatible with the individual type generated ($(genj._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childMut))) generated by mutation does not match the type of its parent ($(genj._experimentInfo._individualType)) in experiment $index")
            end
        end

    end
end # function
precompile(checkParametersCorrectGP, tuple(GenJulia, Int64))



"""
    checkParametersCorrectGA(genj::GenJulia, index::Integer = 0)

Check that all the tools of the experiment are coherent.
"""
function checkParametersCorrectGA(genj::GenJulia, index::Integer = 0)
    rng = Random.MersenneTwister(1234)
    OneByOne = true
    All = true
    ind = 0

    ####### GA AND GP DISTINCTION #######

    if index == 0
        if isdefined(genj._experimentInfo, :_GPExperimentInfo)
            @warn "Information about Genetic Programming problem has been given for a non-GP problem ($(genj._experimentInfo._individualType)), this information will be dismissed"
        end
    else
        if isdefined(genj._experimentInfo, :_GPExperimentInfo)
            @warn "Information about Genetic Programming problem has been given for a non-GP problem ($(genj._experimentInfo._individualType)), this information will be dismissed in experiment $index"
        end
    end

    try
        ind = genj._generator._method(rng, genj._generator._varArgs...)
    catch e
        if isa(e, MethodError)
            OneByOne = false
        end
    end

    try
        ind = genj._generator._method(one(UInt32), rng, genj._generator._varArgs...)
    catch e
        if isa(e, MethodError)
            All = false
        end
    end

    if index == 0

        if !(All || OneByOne)
            error("Generation method ($(genj._generator._method)) introduced is not compatible with arguments specified")
        end

        ind = All ? genj._generator._method(one(UInt32), rng, genj._generator._varArgs...) : genj._generator._method(rng, genj._generator._varArgs...)

        if !OneByOne && genj._generator._generateOneByOne
            error("Generation method ($(genj._generator._method)) receives the population size, however, generateOneByOne is set to true")
        end

        if typeof(ind) <: Array && OneByOne
            error("Generation method ($(genj._generator._method)) returns an array of individuals while generateOneByOne is set to true, it should return a single individual")
        end

        if !All && !genj._generator._generateOneByOne
            error("Generation method ($(genj._generator._method)) doesn't receive the population size, however, generateOneByOne is set to false")
        end

        if !(typeof(ind) <: Array) && All
            error("Generation method ($(genj._generator._method)) returns a single individual while generateOneByOne is set to false, it should return an array of individuals")
        end
    else

        if !(All || OneByOne)
            error("Generation method ($(genj._generator._method)) introduced is not compatible with arguments specified in experiment $index")
        end

        ind = All ? genj._generator._method(one(UInt32), rng, genj._generator._varArgs...) : genj._generator._method(rng, genj._generator._varArgs...)

        if !OneByOne && genj._generator._generateOneByOne
            error("Generation method ($(genj._generator._method)) receives the population size, however, generateOneByOne is set to true in experiment $index")
        end

        if typeof(ind) <: Array && OneByOne
            error("Generation method ($(genj._generator._method)) returns an array of individuals while generateOneByOne is set to true, it should return a single individual in experiment $index")
        end

        if !All && !genj._generator._generateOneByOne
            error("Generation method ($(genj._generator._method)) doesn't receive the population size, however, generateOneByOne is set to false in experiment $index")
        end

        if !(typeof(ind) <: Array) && All
            error("Generation method ($(genj._generator._method)) returns a single individual while generateOneByOne is set to false, it should return an array of individuals in experiment $index")
        end
    end

    margin = 1e-6
    nParents = genj._crossoverOp._nParents
    nChildren = genj._crossoverOp._nChildren
    individuals = Array{Genotype}(undef, nParents)
    popSize = genj._generator._popSize
    fitness = 0
    k = 0

    nSelectedParents = getNSelectedParents(genj._selector)
    if !(typeof(nSelectedParents) <: Integer)
        nSelectedParents = convert(Integer, round(nSelectedParents * popSize))
        remainder = nSelectedParents % nParents

        if remainder != 0
            nSelectedParents = nSelectedParents + nParents - remainder
        end

        if !genj._selector._samplingWithRep && nSelectedParents > popSize
            nSelectedParents -= nParents
        end
    end

    ####### GENERATION #######

    if genj._generator._generateOneByOne
        for i=1:nParents
            individuals[i] = genj._generator._method(rng, genj._generator._varArgs...)
        end

    else
        individuals = genj._generator._method(convert(UInt32, nParents), rng, genj._generator._varArgs...)
    end

    ####### CROSSOVER, MUTATION AND EVALUATION #######

    if index == 0

        if genj._replacementOp._eliteSize > genj._generator._popSize
            error("Size of elite set is greater than the size of the population")
        end

        if genj._crossoverOp._probability < margin && genj._mutationOp._probability < margin
            error("Either crossover or mutation or both must have a probability above 0")
        end

        if typeof(individuals[1]) != genj._experimentInfo._individualType
            error("Generation method ($(genj._generator._method)) should generate individuals (you generate $(typeof(individuals[1]))) of the same type as the one specified in individualType ($(genj._experimentInfo._individualType))")
        end

        try
            len = length(genj._evaluator._fitnessFunctions)
            k = 1

            for i=1:len
                fitness = fitnessEval(genj._evaluator._fitnessFunctions[i], individuals[1])

                if !(typeof(fitness) <: Real)
                    throw(TypeError(fitness, ""))
                end
                k = k + 1
            end
        catch e
            if isa(e, MethodError)
                error("Fitness function ($(genj._evaluator._fitnessFunctions[k]._fitnessFunction)) is not compatible with the individual type ($(genj._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The fitness ($fitness) of an individual generated by ($(genj._evaluator._fitnessFunctions[k]._fitnessFunction)) must be numerical")
            end
        end

        if (nSelectedParents % nParents) != 0
            error("The number of selected parents ($nSelectedParents) is not divisible by number of parents per cross ($nParents)")
        end

        if !genj._selector._samplingWithRep && nSelectedParents > popSize
            error("Number of selected parents ($nSelectedParents) should not be greater than population size ($popSize) when selection method is without replacement")
        end
#childCross = genj._crossoverOp._method(individuals..., rng, genj._crossoverOp._varArgs...)
        try
            childCross = genj._crossoverOp._method(individuals..., rng, genj._crossoverOp._varArgs...)
            len = length(childCross)
            if len != genj._crossoverOp._nChildren
                error("Children generated by crossover ($len) must match the number of children given as argument ($(genj._crossoverOp._nChildren))")
            end
            typeassert(childCross[1], typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The crossover method ($(genj._crossoverOp._method)) is not compatible with the individual type generated ($(genj._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childCross[1]))) generated by crossover does not match the type of its parents ($(genj._experimentInfo._individualType))")
            end
        end

        try

            childMut = genj._mutationOp._method(individuals[1], rng, genj._mutationOp._varArgs...)
            typeassert(childMut, typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The mutation method ($(genj._mutationOp._method)) is not compatible with the individual type generated ($(genj._experimentInfo._individualType))")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childMut))) generated by mutation does not match the type of its parent ($(genj._experimentInfo._individualType))")
            end
        end
    else

        if genj._replacementOp._eliteSize > genj._generator._popSize
            error("Size of elite set is greater than the size of the population in experiment $index")
        end

        if genj._crossoverOp._probability < margin && genj._mutationOp._probability < margin
            error("Either crossover or mutation or both must have a probability above 0 in experiment $index")
        end

        if typeof(individuals[1]) != genj._experimentInfo._individualType
            error("Generation method ($(genj._generator._method)) should generate individuals (you generate $(typeof(individuals[1]))) of the same type as the one specified in individualType ($(genj._experimentInfo._individualType)) in experiment $index")
        end

        try
            len = length(genj._evaluator._fitnessFunctions)
            k = 1

            for i=1:len
                fitness = fitnessEval(genj._evaluator._fitnessFunctions[i], individuals[1])

                if !(typeof(fitness) <: Real)
                    throw(TypeError(fitness, ""))
                end
                k = k + 1
            end
        catch e
            if isa(e, MethodError)
                error("Fitness function ($(genj._evaluator._fitnessFunctions[k]._fitnessFunction)) is not compatible with the individual type ($(genj._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The fitness ($fitness) of an individual generated by ($(genj._evaluator._fitnessFunctions[k]._fitnessFunction)) must be numerical in experiment $index")
            end
        end

        if (nSelectedParents % nParents) != 0
            error("The number of selected parents ($nSelectedParents) is not divisible by number of parents per cross ($nParents) in experiment $index")
        end

        if !genj._selector._samplingWithRep && nSelectedParents > popSize
            error("Number of selected parents ($nSelectedParents) should not be greater than population size ($popSize) when selection method is without replacement in experiment $index")
        end

        try
            childCross = genj._crossoverOp._method(individuals..., rng, genj._crossoverOp._varArgs...)
            len = length(childCross)
            if len != genj._crossoverOp._nChildren
                error("Children generated by crossover ($len) must match the number of children given as argument ($(genj._crossoverOp._nChildren)) in experiment $index")
            end
            typeassert(childCross[1], typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The crossover method ($(genj._crossoverOp._method)) is not compatible with the individual type generated ($(genj._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childCross[1]))) generated by crossover does not match the type of its parents ($(genj._experimentInfo._individualType)) in experiment $index")
            end
        end

        try
            childMut = genj._mutationOp._method(individuals[1], rng, genj._mutationOp._varArgs...)
            typeassert(childMut, typeof(individuals[1]))
        catch e
            if isa(e, MethodError)
                error("The mutation method ($(genj._mutationOp._method)) is not compatible with the individual type generated ($(genj._experimentInfo._individualType)) in experiment $index")
            elseif isa(e, TypeError)
                error("The type of the child ($(typeof(childMut))) generated by mutation does not match the type of its parent ($(genj._experimentInfo._individualType)) in experiment $index")
            end
        end
    end
end
precompile(checkParametersCorrectGA, tuple(GenJulia, Int64))



"""
    checkParameters(genj)

Check that everything has been set correctly before running an experiment.
"""
function checkParametersCorrect(genj::GenJulia, index::Integer = 0)

    if reached_(genj._stopCondition)
        @warn "One of the stop conditions is fulfilled, use showStopConditions for further information"
    end

    if genj._experimentInfo._algorithm == SPEA && genj._evaluator._globalFitnessFunction._fitnessFunction == _noFunc_
        error("SPEA algorithm needs a global fitness function for pareto frontier setting")
    end

    if genj._experimentInfo._algorithm == SPEA && length(genj._evaluator._fitnessFunctions) == 1
        @warn "Using SPEA with only one fitness function ($(genj._evaluator._fitnessFunctions[1]._fitnessFunction))"
    end

    if genj._experimentInfo._individualType <: GPGenotype
        checkParametersCorrectGP(genj, index)
    else
        checkParametersCorrectGA(genj, index)
    end
end # function
