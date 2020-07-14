"""
    parseGPExperimentInfo(GPExperimentInfoDict::Dict, experiment::GenJulia)

Throw an error because there is not a parsing function for an specific GP problem.
"""
function parseGPExperimentInfo(type::EvoLab.GPGenotype, GPExperimentInfoDict::Dict, experiment::GenJulia)
    error("For this specific GP problem (", type, "), the following function must be defined: parseGPExperimentInfo(type::", type, ", GPExperimentInfoDict::Dict, experiment::GenJulia)")
end # function



"""
    parseExperimentInfo(experimentInfo::Dict, experiment::GenJulia)

Parse the information about the experiment.
"""
function parseExperimentInfo(experimentInfoDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule

    individualType = get(experimentInfoDict, "individualType", false)
    if individualType != false
        individualType = parentModule.eval(Meta.parse(individualType))
        setIndividualType(individualType, genj=experiment)
    else
        error("individualType field in ExperimentInfo is mandatory and must be set")
    end

    randomSeed = get(experimentInfoDict, "randomSeed", false)
    if randomSeed != false
        if typeof(randomSeed) <: String
            try
                aux = parentModule.eval(Meta.parse(randomSeed))
                randomSeed = aux
            catch e
                error("Random seed field is not defined: ", randomSeed)
            end
        end

        if !(typeof(randomSeed) <: Integer) || randomSeed < 0
            error("Random seed must be an integer number greater or equal than 0", randomSeed)
        end
        setRandomSeed(randomSeed, genj=experiment)
    end

    rng = get(experimentInfoDict, "rng", false)
    if rng != false
        try
            aux = Meta.parse(rng)
            rng = parentModule.eval(aux)
        catch e
            error("The following random number generator is not defined: ", rng)
        end
        if typeof(rng) <: Random.AbstractRNG
            setRNG(rng, genj=experiment)
        else
            error("The following random number generator is not a random number generator: ", rng)
        end
    end

    if rng != false && randomSeed != false
        @warn "Random number generator and random seed have been provided, random seed will be dismissed"
    elseif rng == false && randomSeed == false
        println("entro aqui?")
        setRNG(Random.GLOBAL_RNG, genj=experiment)
    end

    gpExperimentInfoDict = get(experimentInfoDict, "GPExperimentInfo", false)
    if individualType <: GPGenotype && gpExperimentInfoDict != false
        parseGPExperimentInfo(individualType, gpExperimentInfoDict, experiment)
    elseif gpExperimentInfoDict != false
        @warn "Information about Genetic Programming problem has been given for a non-GP problem ($individualType), this information will be dismissed"
    end

    algorithm = get(experimentInfoDict, "algorithm", false)
    if algorithm == false
        algorithm = basicExperiment
    else
        try
            aux = parentModule.eval(Meta.parse(algorithm))
            algorithm = aux
        catch e
            error("The following function of ExperimentInfo is not defined: ", algorithm)
        end
        if !(typeof(algorithm) <: Function)
            error("The following function of ExperimentInfo is not a function: ", algorithm)
        end
    end

    varArgs = get(experimentInfoDict, "arguments", [])
    if !(typeof(varArgs) <: Array)
        varArgs = [varArgs]
    end
    for i=1:length(varArgs)
        try
            arg = Meta.parse(varArgs[i])
            varArgs[i] = parentModule.eval(arg)
        catch e
            # Empty
        end
    end

    setAlgorithm(algorithm, varArgs..., genj=experiment)
end # function



"""
    parseFitnessFunction(fitnessFunctionDict::Dict, experiment::GenJulia)

Parse a FitnessFunction dictionary.
"""
function parseFitnessFunction(fitnessFunctionDict::Dict, parentModule::Module, index::Integer)

    fitnessFunction = get(fitnessFunctionDict, "function", false)
    if fitnessFunction == false
        error("No function specified for FitnessFunction dictionary number $index")
    else
        try
            aux = parentModule.eval(Meta.parse(fitnessFunction))
            fitnessFunction = aux
        catch e
            error("The following function of Evaluator is not defined in FitnessFunction dictionary number $index: '$(fitnessFunction)'")
        end
        if !(typeof(fitnessFunction) <: Function)
            error("The following function of Evaluator is not a function in FitnessFunction dictionary number $index: '$(fitnessFunction)'")
        end
    end

    weight = get(fitnessFunctionDict, "weight", 1.0)
    if typeof(weight) <: String
        try
            aux = parentModule.eval(Meta.parse(weight))
            weight = aux
        catch e
            error("Weight field is not defined: ", weight)
        end
    end

    if !(typeof(weight) <: Real)
        error("weight field in fitness function number", index, " must be a real number: ", weight)
    end

    varArgs = get(fitnessFunctionDict, "arguments", [])
    if !(typeof(varArgs) <: Array)
        varArgs = [varArgs]
    end
    for i=1:length(varArgs)

        try
            arg = Meta.parse(varArgs[i])
            varArgs[i] = parentModule.eval(arg)
        catch e
            # Empty
        end
    end

    return FitnessFunction(fitnessFunction, varArgs..., weight = weight)
end # function



"""
    parseEvaluator(evaluatorDict::Dict)

Parse the information about the Evaluator.
"""
function parseEvaluator(evaluatorDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule
    local aux

    globalFitnessFunction = get(evaluatorDict, "globalFitnessFunction", false)
    globalFitnessFunctionArgs = get(evaluatorDict, "globalFitnessFunctionArgs", [])

    if !(typeof(globalFitnessFunctionArgs) <: Array)
        globalFitnessFunctionArgs = [globalFitnessFunctionArgs]
    end

    if globalFitnessFunction != false
        try
            aux = parentModule.eval(Meta.parse(globalFitnessFunction))
        catch e
            error("The following function of Evaluator is not defined: '$(globalFitnessFunction)'")
        end
        if typeof(aux) <: Function
            globalFitnessFunction = FitnessFunction(aux, globalFitnessFunctionArgs...)
        else
            error("The following function of Evaluator is not a function: '$(globalFitnessFunction)'")
        end
    else
        globalFitnessFunction = FitnessFunction(_noFunc_)
    end

    fitnessComparisonMode = get(evaluatorDict, "fitnessComparisonMode", "rawW")
    if !(typeof(fitnessComparisonMode) <: String)
        error("fitnessComparisonMode field in Evaluator must be a string: ($fitnessComparisonMode)")
    end

    fitnessFunctionsStrings = get(evaluatorDict, "fitnessFunctions", [])
    if !(typeof(fitnessFunctionsStrings) <: Array)
        fitnessFunctionsStrings = [fitnessFunctionsStrings]
    end

    lenFitnessFunctions = length(fitnessFunctionsStrings)
    if lenFitnessFunctions == 0
        error("A fitness function must be provided in JSON-> GenJulia-> Evaluator")
    end

    if typeof(fitnessFunctionsStrings[1]) <: Dict
        nFitnessFunctions = length(fitnessFunctionsStrings)
        fitnessFunctions = Array{FitnessFunction}(undef, nFitnessFunctions)
        for i=1:nFitnessFunctions
            fitnessFunctions[i] = parseFitnessFunction(fitnessFunctionsStrings[i]["FitnessFunction"], parentModule, i)
        end

        setEvaluator(fitnessFunctions, genj=experiment, globalFitnessFunction=globalFitnessFunction, compareFunctionArgs=fitnessComparisonMode)
    else
        weights = Array{Real}(undef,1)
        weightsNumber = get(evaluatorDict, "weights", [])

        if typeof(weightsNumber) <: String
            try
                aux = parentModule.eval(Meta.parse(weightsNumber))
                weightsNumber = aux
            catch e
                error("weights field is not defined: ", weightsNumber)
            end
        else
            if !(typeof(weightsNumber) <: Array)
                weightsNumber = [weightsNumber]
            end
        end
        try
            weights = convert(Array{Real}, weightsNumber)
        catch e
            if isa(e, MethodError)
                error("weights field must be an array of numbers")
            end
        end

        fitnessFunctions = Array{Function}(undef, lenFitnessFunctions)
        for i=1:lenFitnessFunctions
            try
                aux = parentModule.eval(Meta.parse(fitnessFunctionsStrings[i]))
                fitnessFunctions[i] = aux
            catch e
                error("The following function of Evaluator is not defined: ", fitnessFunctionsStrings[i])
            end
            if !(typeof(fitnessFunctions[i]) <: Function)
                error("The following function of Evaluator is not a function: ", fitnessFunctionsStrings[i])
            end
        end

        lenWeights = length(weights)
        if lenWeights != 0 && lenWeights != lenFitnessFunctions
            error("If weights are provided, they must be in the same amount as fitness functions")
        end

        if lenWeights == 0
            setEvaluator(fitnessFunctions, genj=experiment,
                         globalFitnessFunction=globalFitnessFunction,
                         compareFunctionArgs=fitnessComparisonMode)
        else
            setEvaluator(fitnessFunctions, weights, genj=experiment,
                         globalFitnessFunction=globalFitnessFunction,
                         compareFunctionArgs=fitnessComparisonMode)
        end
    end
end # function



"""
    parseGenerator(generatorDict::Dict, experiment::GenJulia)

Parse the information about the Generator.
"""
function parseGenerator(generatorDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule

    popSize = get(generatorDict, "popSize", 100)
    if typeof(popSize) <: String
        try
            aux = parentModule.eval(Meta.parse(popSize))
            popSize = aux
        catch e
            error("popSize field in Generator not defined: ", popSize)
        end
    end
    if !(typeof(popSize) <: Integer)
        error("popSize field (", popSize, ") must be an integer number")
    end

    method = get(generatorDict, "method", false)
    if method == false
        error("Generation method must always be provided")
    end
    try
        aux = parentModule.eval(Meta.parse(method))
        method = aux
    catch e
        error("The following function of Generator: ", method, ", is not defined")
    end
    if !(typeof(method) <: Function)
        error("The following function of Generator: ", method, ", is not a function")
    end

    generateOneByOne = get(generatorDict, "generateOneByOne", true)
    if generateOneByOne == 1
        generateOneByOne = true
    elseif generateOneByOne == 0
        generateOneByOne = false
    end
    if typeof(generateOneByOne) <: String
        try
            aux = parentModule.eval(Meta.parse(generateOneByOne))
            generateOneByOne = aux
        catch e
            error("generateOneByOne field in Generator is not defined: ", generateOneByOne)
        end
    end
    if !(typeof(generateOneByOne) <: Bool)
        error("generateOneByOne field must be boolean, true if generation method creates individuals one by one or false if it generates the whole population")
    end

    varArgs = get(generatorDict, "arguments", [])
    if !(typeof(varArgs) <: Array)
        varArgs = [varArgs]
    end
    for i=1:length(varArgs)
        try
            arg = Meta.parse(varArgs[i])
            varArgs[i] = parentModule.eval(arg)
        catch e
            # Empty
        end
    end

    setGenerator(method, varArgs..., genj=experiment, popSize=popSize, generateOneByOne=generateOneByOne)
end # function



"""
    parseSelector(selectorDict::Dict, experiment::GenJulia)

Parse the information about the Selector.
"""
function parseSelector(selectorDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule

    method = get(selectorDict, "method", false)
    if method == false
        aux = getDefaultSelector()
        method = aux[1]
        varArgs = aux[2]
        @warn "Method for selection has not been provided, functionArgs or individualMode introduced will be dismissed, '$method' will be the default selection method"

        nSelected = get(selectorDict, "nSelected", 1.0)
        if typeof(nSelected) <: String
            try
                aux = parentModule.eval(Meta.parse(nSelected))
                nSelected = aux
            catch e
                error("nSelected field in Selector is not defined: ", nSelected)
            end
        end
        if !(typeof(nSelected) <: Real)
            error("nSelected field ", nSelected, " must be a number")
        end

        samplingWithRep = get(selectorDict, "samplingWithRep", true)
        if samplingWithRep == 1
            samplingWithRep = true
        elseif samplingWithRep == 0
            samplingWithRep = false
        end
        if typeof(samplingWithRep) <: String
            try
                aux = parentModule.eval(Meta.parse(samplingWithRep))
                samplingWithRep = aux
            catch
                error("samplingWithRep field in Selector is not defined: ", samplingWithRep)
            end
        end
        if !(typeof(samplingWithRep) <: Bool)
            error("samplingWithRep field in Selector must be boolean")
        end

        setSelector(method,varArgs..., genj=experiment, nSelected=nSelected,
                    samplingWithRep=samplingWithRep)
    else

        try
            aux = parentModule.eval(Meta.parse(method))
            method = aux
        catch e
            error("The following function of Selector: '$method', is not defined")
        end
        if !(typeof(method) <: Function)
            error("The following function of Selector: '$method', is not a function")
        end

        nSelected = get(selectorDict, "nSelected", 1.0)
        if typeof(nSelected) <: String
            try
                aux = parentModule.eval(Meta.parse(nSelected))
                nSelected = aux
            catch e
                error("nSelected field in Selector is not defined: ", nSelected)
            end
        end
        if !(typeof(nSelected) <: Real)
            error("nSelected field ", nSelected, " must be a number")
        end

        needsComparison = get(selectorDict, "needsComparison", true)
        if needsComparison == 1
            needsComparison = true
        elseif needsComparison == 0
            needsComparison = false
        end
        if typeof(needsComparison) <: String
            try
                aux = parentModule.eval(Meta.parse(needsComparison))
                needsComparison = aux
            catch
                error("needsComparison field in Selector is not defined: ", needsComparison)
            end
        end
        if !(typeof(needsComparison) <: Bool)
            error("needsComparison field in Selector must be boolean")
        end

        samplingWithRep = get(selectorDict, "samplingWithRep", true)
        if samplingWithRep == 1
            samplingWithRep = true
        elseif samplingWithRep == 0
            samplingWithRep = false
        end
        if typeof(samplingWithRep) <: String
            try
                aux = parentModule.eval(Meta.parse(samplingWithRep))
                samplingWithRep = aux
            catch
                error("samplingWithRep field in Selector is not defined: ", samplingWithRep)
            end
        end
        if !(typeof(samplingWithRep) <: Bool)
            error("samplingWithRep field in Selector must be boolean")
        end

        varArgs = get(selectorDict, "arguments", [])
        if !(typeof(varArgs) <: Array)
            varArgs = [varArgs]
        end
        for i=1:length(varArgs)
            try
                arg = Meta.parse(varArgs[i])
                varArgs[i] = parentModule.eval(arg)
            catch e
                # Empty
            end
        end

        setSelector(method, varArgs..., genj=experiment, nSelected=nSelected,
                    needsComparison=needsComparison, samplingWithRep=samplingWithRep)
    end
end # function



"""
    parseCrossover(crossoverDict::Dict, experiment::GenJulia)

Parse the information about the Crossover.
"""
function parseCrossover(crossoverDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule

    method = get(crossoverDict, "method", false)
    if method == false
        if !isdefined(experiment._experimentInfo, :_individualType) || !isPredefinedType(type)
            error("Either a crossover method or one of the predefined types(BinaryGA, IntegerGA, CanonicalGP) must be provided. The predefined types can be set in individualType field.")
        end
        type = experiment._experimentInfo._individualType
        aux = getDefaultCrossoverOp(type)
        method = aux[1]
        varArgs = aux[2]
        @warn "Method for crossover has not been provided, functionArgs introduced will be dismissed, '$method' will be the default crossover method"

        probability = get(crossoverDict, "probability", 0.7)
        if typeof(probability) <: String
            try
                aux = parentModule.eval(Meta.parse(probability))
                probability = aux
            catch e
                error("probability field in Crossover is not defined: ", probability)
            end
        end
        if !(typeof(probability) <: AbstractFloat)
            error("probability field ", probability, " must be a floating point number")
        end

        nParents = get(crossoverDict, "nParents", 2)
        if typeof(nParents) <: String
            try
                aux = parentModule.eval(Meta.parse(nParents))
                nParents = aux
            catch e
                error("nParents field in Crossover is not defined: ", nParents)
            end
        end
        if !(typeof(nParents) <: Integer)
            error("nParents field ", nParents, " must be an integer number")
        end

        nChildren = get(crossoverDict, "nChildren", -1)
        if typeof(nChildren) <: String
            try
                aux = parentModule.eval(Meta.parse(nChildren))
                nChildren = aux
            catch e
                error("nChildren field in Crossover is not defined: ", nChildren)
            end
        end
        if !(typeof(nChildren) <: Integer)
            error("nChildren field ", nChildren, " must be an integer number")
        end

        setCrossoverOperator(method, varArgs..., genj=experiment, probability=probability, nParents=nParents, nChildren=nChildren)
    else

        try
            aux = parentModule.eval(Meta.parse(method))
            method = aux
        catch e
            error("The following function of Crossover: ", method, ", is not defined")
        end
        if !(typeof(method) <: Function)
            error("The following function of Crossover: ", method, ", is not a function")
        end

        probability = get(crossoverDict, "probability", 0.7)
        if typeof(probability) <: String
            try
                aux = parentModule.eval(Meta.parse(probability))
                probability = aux
            catch e
                error("probability field in Crossover is not defined: ", probability)
            end
        end
        if !(typeof(probability) <: AbstractFloat)
            error("probability field ", probability, " must be a floating point number")
        end

        nParents = get(crossoverDict, "nParents", 2)
        if typeof(nParents) <: String
            try
                aux = parentModule.eval(Meta.parse(nParents))
                nParents = aux
            catch e
                error("nParents field in Crossover is not defined: ", nParents)
            end
        end
        if !(typeof(nParents) <: Integer)
            error("nParents field ", nParents, " must be an integer number")
        end

        nChildren = get(crossoverDict, "nChildren", -1)
        if typeof(nChildren) <: String
            try
                aux = parentModule.eval(Meta.parse(nChildren))
                nChildren = aux
            catch e
                error("nChildren field in Crossover is not defined: ", nChildren)
            end
        end
        if !(typeof(nChildren) <: Integer)
            error("nChildren field ", nChildren, " must be an integer number")
        end

        varArgs = get(crossoverDict, "arguments", [])
        if !(typeof(varArgs) <: Array)
            varArgs = [varArgs]
        end
        for i=1:length(varArgs)
            try
                arg = Meta.parse(varArgs[i])
                varArgs[i] = parentModule.eval(arg)
            catch e
                # Empty
            end
        end

        setCrossoverOperator(method, varArgs..., genj=experiment, probability=probability, nParents=nParents, nChildren=nChildren)
    end
end # function



"""
    parseMutation(mutationDict::Dict, experiment::GenJulia)

Parse the information about the Mutation.
"""
function parseMutation(mutationDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule

    method = get(mutationDict, "method", false)
    if method == false
        if !isdefined(experiment._experimentInfo, :_individualType) || !isPredefinedType(type)
            error("Either a mutation method or one of the predefined types(BinaryGA, IntegerGA, CanonicalGP) must be provided. The predefined types can be set in individualType field.")
        end
        type = experiment._experimentInfo._individualType
        aux = getDefaultMutationOp(type)
        method = aux[1]
        varArgs = aux[2]
        @warn "Method for mutation has not been provided, functionArgs introduced will be dismissed, '$method' will be the default mutation method"

        probability = get(mutationDict, "probability", 0.7)
        if typeof(probability) <: String
            try
                aux = parentModule.eval(Meta.parse(probability))
                probability = aux
            catch e
                error("probability field in Mutation is not defined: ", probability)
            end
        end
        if !(typeof(probability) <: AbstractFloat)
            error("probability field ", probability, " must be a floating point number")
        end

        setMutationOperator(method, varArgs..., genj=experiment, probability=probability)

    else
        try
            aux = parentModule.eval(Meta.parse(method))
            method = aux
        catch e
            error("The following function of Mutation: ", method, ", is not defined")
        end
        if !(typeof(method) <: Function)
            error("The following function of Mutation: ", method, ", is not a function")
        end

        probability = get(mutationDict, "probability", 0.7)
        if typeof(probability) <: String
            try
                aux = parentModule.eval(Meta.parse(probability))
                probability = aux
            catch e
                error("probability field in Mutation is not defined: ", probability)
            end
        end
        if !(typeof(probability) <: AbstractFloat)
            error("probability field ", probability, " must be a floating point number")
        end

        varArgs = get(mutationDict, "arguments", [])
        if !(typeof(varArgs) <: Array)
            varArgs = [varArgs]
        end
        for i=1:length(varArgs)
            try
                arg = Meta.parse(varArgs[i])
                varArgs[i] = parentModule.eval(arg)
            catch e
                # Empty
            end
        end

        setMutationOperator(method, varArgs..., genj=experiment, probability=probability)
    end
end # function



"""
    parseReplacement(replacementDict::Dict, experiment::GenJulia)

Parse the information about the Replacement.
"""
function parseReplacement(replacementDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule

    method = get(replacementDict, "method", false)
    if method == false
        if !isdefined(experiment._experimentInfo, :_individualType) || !isPredefinedType(type)
            error("Either a replacement method or one of the predefined types(BinaryGA, IntegerGA, CanonicalGP) must be provided. The predefined types can be set in individualType field.")
        end
        type = experiment._experimentInfo._individualType
        aux = getDefaultMutationOp(type)
        method = aux[1]
        varArgs = aux[2]
        @warn "Method for replacement has not been provided, functionArgs introduced will be dismissed, '$method' will be the default replacement method"

        setReplacementOperator(method, varArgs..., genj=experiment)

    else
        try
            aux = parentModule.eval(Meta.parse(method))
            method = aux
        catch e
            error("The following function of Replacement: ", method, ", is not defined")
        end
        if !(typeof(method) <: Function)
            error("The following function of Replacement: ", method, ", is not a function")
        end

        needsComparison = get(replacementDict, "needsComparison", false)
        if needsComparison == 1
            needsComparison = true
        elseif needsComparison == 0
            needsComparison = false
        end
        if typeof(needsComparison) <: String
            try
                aux = parentModule.eval(Meta.parse(needsComparison))
                needsComparison = aux
            catch
                error("needsComparison field in Replacement is not defined: ", needsComparison)
            end
        end
        if !(typeof(needsComparison) <: Bool)
            error("needsComparison field in Replacement must be boolean")
        end

        eliteSize = get(replacementDict, "eliteSize", 0)
        if typeof(eliteSize) <: String
            try
                aux = parentModule.eval(Meta.parse(eliteSize))
                eliteSize = aux
            catch e
                error("eliteSize field in Replacement is not defined: ", eliteSize)
            end
        end
        if !(typeof(eliteSize) <: Integer)
            error("eliteSize field in Replacement must be an integer number: ", eliteSize)
        end

        varArgs = get(replacementDict, "arguments", [])
        if !(typeof(varArgs) <: Array)
            varArgs = [varArgs]
        end
        for i=1:length(varArgs)
            try
                arg = Meta.parse(varArgs[i])
                varArgs[i] = parentModule.eval(arg)
            catch e
                # Empty
            end
        end

        setReplacementOperator(method, varArgs..., genj=experiment,
                               needsComparison=needsComparison, eliteSize=eliteSize)
    end
end # function



"""
    parseStopCondition(stopConditionDict::Dict, experiment::GenJulia)

Parse the information about the Stop Condition.
"""
function parseStopCondition(stopConditionDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule

    maxEvaluations = get(stopConditionDict, "maxEvaluations", typemax(Int64))
    if typeof(maxEvaluations) <: String
        try
            aux = parentModule.eval(Meta.parse(maxEvaluations))
            maxEvaluations = aux
        catch e
            error("maxEvaluations field in StopCondition is not defined: ", maxEvaluations)
        end
    end
    if !(typeof(maxEvaluations) <: Integer)
        error("maxEvaluations field ", maxEvaluations, " must be an integer number")
    end

    maxIterations = get(stopConditionDict, "maxIterations", typemax(Int64))
    if typeof(maxIterations) <: String
        try
            aux = parentModule.eval(Meta.parse(maxIterations))
            maxIterations = aux
        catch e
            error("maxIterations field in StopCondition is not defined: ", maxIterations)
        end
    end
    if !(typeof(maxIterations) <: Integer)
        error("maxIterations field ", maxIterations, " must be an integer number")
    end

    maxIterNotImproving = get(stopConditionDict, "maxIterNotImproving", typemax(Int64))
    if typeof(maxIterNotImproving) <: String
        try
            aux = parentModule.eval(Meta.parse(maxIterNotImproving))
            maxIterNotImproving = aux
        catch e
            error("maxIterNotImproving field in StopCondition is not defined: ", maxIterNotImproving)
        end
    end
    if !(typeof(maxIterNotImproving) <: Integer)
        error("maxIterNotImproving field ", maxIterNotImproving, " must be an integer number")
    end

    maxTime = get(stopConditionDict, "maxTime", Inf)
    if typeof(maxTime) <: String
        try
            aux = parentModule.eval(Meta.parse(maxTime))
            maxTime = aux
        catch e
            error("maxTime field in StopCondition is not defined: ", maxTime)
        end
    end
    if !(typeof(maxTime) <: AbstractFloat)
        error("maxTime field ", maxTime, " must be a floating point number")
    end

    setStopCondition(genj=experiment, maxEvaluations=maxEvaluations,
                     maxIterations=maxIterations, maxIterNotImproving=maxIterNotImproving,
                     maxTime=maxTime)
end # function



"""
    parseExperimentSummary(summaryDict::Dict, experiment::GenJulia)

Parse the information about the Experiment Summary.
"""
function parseExperimentSummary(summaryDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule

    outputFile = get(summaryDict, "outputFile", "")
    if !(typeof(outputFile) <: String)
        error("outputFile field in Experiment Summary must be a string")
    end

    batchSize = get(summaryDict, "batchSize", 0)
    if typeof(batchSize) <: String
        try
            aux = parentModule.eval(Meta.parse(batchSize))
            batchSize = aux
        catch e
            error("batchSize field in ExperimentSummary is not defined: ", batchSize)
        end
    end
    if !(typeof(batchSize) <: Integer)
        error("batchSize field in Experiment Summary must be an integer number", batchSize)
    end

    printDuringExperiment = get(summaryDict, "printDuringExperiment", false)
    if typeof(printDuringExperiment) <: String
        try
            aux = parentModule.eval(Meta.parse(printDuringExperiment))
            printDuringExperiment = aux
        catch e
            error("printDuringExperiment field in ExperimentSummary is not defined: ", printDuringExperiment)
        end
    end
    if !(typeof(printDuringExperiment) <: Bool)
        error("printDuringExperiment field in Experiment Summary must be either true or false", printDuringExperiment)
    end

    printFitness = get(summaryDict, "printFitness", true)
    if typeof(printFitness) <: String
        try
            aux = parentModule.eval(Meta.parse(printFitness))
            printFitness = aux
        catch e
            error("printFitness field in ExperimentSummary is not defined: ", printFitness)
        end
    end
    if !(typeof(printFitness) <: Bool)
        error("printFitness field in Experiment Summary must be either true or false", printFitness)
    end

    printBestFitness = get(summaryDict, "printBestFitness", true)
    if typeof(printBestFitness) <: String
        try
            aux = parentModule.eval(Meta.parse(printBestFitness))
            printBestFitness = aux
        catch e
            error("printBestFitness field in ExperimentSummary is not defined: ", printBestFitness)
        end
    end
    if !(typeof(printBestFitness) <: Bool)
        error("printBestFitness field in Experiment Summary must be either true or false", printBestFitness)
    end

    printFitnessMean = get(summaryDict, "printFitnessMean", true)
    if typeof(printFitnessMean) <: String
        try
            aux = parentModule.eval(Meta.parse(printFitnessMean))
            printFitnessMean = aux
        catch e
            error("printFitnessMean field in ExperimentSummary is not defined: ", printFitnessMean)
        end
    end
    if !(typeof(printFitnessMean) <: Bool)
        error("printFitnessMean field in Experiment Summary must be either true or false", printFitnessMean)
    end

    printFitnessVAR = get(summaryDict, "printFitnessVAR", true)
    if typeof(printFitnessVAR) <: String
        try
            aux = parentModule.eval(Meta.parse(printFitnessVAR))
            printFitnessVAR = aux
        catch e
            error("printFitnessVAR field in ExperimentSummary is not defined: ", printFitnessVAR)
        end
    end
    if !(typeof(printFitnessVAR) <: Bool)
        error("printFitnessVAR field in Experiment Summary must be either true or false", printFitnessVAR)
    end

    setExperimentSummary(genj=experiment, outputFile=outputFile, batchSize=batchSize,
                         printDuringExperiment=printDuringExperiment, printFitness=printFitness,
                         printBestFitness=printBestFitness, printFitnessMean=printFitnessMean,
                         printFitnessVAR=printFitnessVAR)
end # function



"""
    generateMainStructure(jsonFile::String; verbose::Bool = true)

Generate the array of structures for each experiment of the configuration file.
"""
function generateMainStructure(jsonFile::String; verbose::Bool = true,
                               parentModule::Module = Main)
    file=open(jsonFile)
    dictionary = JSON.parse(file)
    close(file)

    nExperiments = length(dictionary["Experiments"])
    experiments = Array{GenJulia}(undef, nExperiments)

    if verbose
        println("\n")
        println("Reading JSON file")
        println("##########################")
    end
    for i=1:nExperiments
        if verbose
            print("\t· Experiment $i ")
        end
        experiments[i] = GenJulia()

        experiments[i]._experimentInfo = ExperimentInfo()
        setParentModule(parentModule, genj=experiments[i])

        experimentInfoDict = get(dictionary["Experiments"][i]["GenJulia"], "ExperimentInfo", false)
        if experimentInfoDict != false
            parseExperimentInfo(experimentInfoDict, experiments[i])
        end

        evaluator = get(dictionary["Experiments"][i]["GenJulia"], "Evaluator", false)
        if evaluator != false
            parseEvaluator(evaluator, experiments[i])
        else
            error("Evaluator is a mandatory field in GenJulia")
        end

        generatorDict = get(dictionary["Experiments"][i]["GenJulia"], "Generator", false)
        if generatorDict != false
            parseGenerator(generatorDict, experiments[i])
        else
            error("Generator is a mandatory field in GenJulia")
        end

        selectorDict = get(dictionary["Experiments"][i]["GenJulia"], "Selector", false)
        if selectorDict != false
            parseSelector(selectorDict, experiments[i])
        end

        crossoverDict = get(dictionary["Experiments"][i]["GenJulia"], "Crossover", false)
        if crossoverDict != false
            parseCrossover(crossoverDict, experiments[i])
        end

        mutationDict = get(dictionary["Experiments"][i]["GenJulia"], "Mutation", false)
        if mutationDict != false
            parseMutation(mutationDict, experiments[i])
        end

        replacementDict = get(dictionary["Experiments"][i]["GenJulia"], "Replacement", false)
        if replacementDict != false
            parseReplacement(replacementDict, experiments[i])
        end

        stopConditionDict = get(dictionary["Experiments"][i]["GenJulia"], "StopConditions", false)
        if stopConditionDict != false
            parseStopCondition(stopConditionDict, experiments[i])
        end

        summaryDict = get(dictionary["Experiments"][i]["GenJulia"], "ExperimentSummary", false)
        if summaryDict != false
            parseExperimentSummary(summaryDict, experiments[i])
        end

        if verbose
            println("→ Experiment correctly read ✔")
        end
    end
    if verbose
        println("##########################\n")
    end

    return experiments
end # function
