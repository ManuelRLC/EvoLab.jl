"""
    setEvaluator(fitnessFunctions::Array{FitnessFunction}; genj::GenJulia = GenJ,
                globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_),
                compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")

Sets the evaluator for `genj`, receiving an array with structures for all the fitness functions
(See [FitnessFunction](@ref)). This function constructs a structure of type
`Evaluator` and adds it to the main structure.

# Arguments
- `fitnessFunctions::Array{FitnessFunction}`: each function must evaluate an individual,
    receiving the individual's genotype and returning a fitness.
    (For information about genotypes look [`Genotype`](@ref))

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't
    modify the default value unless multiple experiments are going to be run.
- `globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_)`: second-phase
    fitness function that is going to be evaluated once the other 'raw' fitness
    functions have been. For example, for [SPEA](@ref) algorithm, this fitness
    function serves to assign each individual its fitness level in the pareto front.
- `compareFunction::Function=_noFunc_`: function used to compare between individuals.
- `compareFunctionArgs::String = "rawW"`: tells the evaluator what is going to be
    compared. "raw" is for fitness comparison, "rawW" is for weighted fitness comparison,
    "global" is for second-phase fitness comparison, "globalW" is for weighted
    second-phase fitness comparison, "both" is for both fitness and second-phase
    fitness comparison and "bothW" is for both weighted fitness and weighted
    second-phase fitness comparison.

See also: [`Evaluator`](@ref), [FitnessFunction](@ref)
"""
function setEvaluator(fitnessFunctions::Array{FitnessFunction}; genj::GenJulia = GenJ,
                      globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_),
                      compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")

    if findfirst(x-> x==compareFunctionArgs, ["raw","rawW", "global", "globalW", "both", "bothW"]) == nothing
        error("Invalid compareFunctionArgs ($compareFunctionArgs), it should be either raw, rawW, global, globalW, both or bothW")
    end
    compareFitness = getParametrizedCompareFunction(compareFunction, compareFunctionArgs, getWeights(fitnessFunctions))

    genj._evaluator = Evaluator(fitnessFunctions, globalFitnessFunction, compareFitness, compareFunctionArgs)
end # function



"""
    setEvaluator(args)

Sets the evaluator for `genj`, receiving a single structure for the fitness function
(See [FitnessFunction](@ref)). This function constructs a structure of type
`Evaluator` and adds it to the main structure.

# Arguments
- `fitnessFunction::FitnessFunction`: the fitness function, which must receive
    the individual's genotype and return a fitness. (For information about
    genotypes look [`Genotype`](@ref))

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't
    modify the default value unless multiple experiments are going to be run.
- `globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_)`: second-phase
    fitness function that is going to be evaluated once the other 'raw' fitness
    functions have been. For example, for [SPEA](@ref) algorithm, this fitness
    function serves to assign each individual its fitness level in the pareto front.
- `compareFunction::Function=_noFunc_`: function used to compare between individuals.
- `compareFunctionArgs::String = "rawW"`: tells the evaluator what is going to be
    compared. "raw" is for fitness comparison, "rawW" is for weighted fitness comparison,
    "global" is for second-phase fitness comparison, "globalW" is for weighted
    second-phase fitness comparison, "both" is for both fitness and second-phase
    fitness comparison and "bothW" is for both weighted fitness and weighted
    second-phase fitness comparison.

See also: [`Evaluator`](@ref), [FitnessFunction](@ref)
"""
function setEvaluator(fitnessFunction::FitnessFunction; genj::GenJulia = GenJ,
                      globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_),
                      compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")
    setEvaluator([fitnessFunction], genj=genj, globalFitnessFunction=globalFitnessFunction,
                 compareFunction=compareFunction, compareFunctionArgs=compareFunctionArgs)
end # function



"""
    setEvaluator(functions::Array{Function}, weights::Array{Real}; genj::GenJulia = GenJ,
                 globalFitnessFunction::FitnessFunction = FitnessFunction(nullGlobalFunction),
                 compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")

Sets the evaluator for `genj`, receiving an array with a function per fitness
and an array with a weight per fitness. This function constructs a structure of
type `Evaluator` and adds it to the main structure.

# Arguments
- `functions::Array{Function}`: each function must evaluate an individual,
    receiving the individual's genotype and returning a fitness.
    (For information about genotypes look [`Genotype`](@ref))
- `weights::Array{Real}`: each weight, in absolute value, represents the
    importance of its fitness in the system, whereas the sign is representative
    of maximization (positive) or minimization (negative).

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't
    modify the default value unless multiple experiments are going to be run.
- `globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_)`: second-phase
    fitness function that is going to be evaluated once the other 'raw' fitness
    functions have been. For example, for [SPEA](@ref) algorithm, this fitness
    function serves to assign each individual its fitness level in the pareto front.
- `compareFunction::Function=_noFunc_`: function used to compare between individuals.
- `compareFunctionArgs::String = "rawW"`: tells the evaluator what is going to be
    compared. "raw" is for fitness comparison, "rawW" is for weighted fitness comparison,
    "global" is for second-phase fitness comparison, "globalW" is for weighted
    second-phase fitness comparison, "both" is for both fitness and second-phase
    fitness comparison and "bothW" is for both weighted fitness and weighted
    second-phase fitness comparison.

See also: [`Evaluator`](@ref), [FitnessFunction](@ref)
"""
function setEvaluator(functions::Array{Function}, weights::Array{Real}; genj::GenJulia = GenJ,
                      globalFitnessFunction::FitnessFunction = FitnessFunction(nullGlobalFunction),
                      compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")
    if length(functions) != length(weights)
        error("The number of fitness functions must be the same as the number of weights")
    end
    fitnessFunctions = Array{FitnessFunction}(undef, length(functions))

    for i=1:length(functions)
        fitnessFunctions[i] = FitnessFunction(functions[i], weight = weights[i])
    end

    setEvaluator(fitnessFunctions, genj=genj, globalFitnessFunction=globalFitnessFunction, compareFunction=compareFunction, compareFunctionArgs=compareFunctionArgs)
end # function



"""
    setEvaluator(functions::Array{Function}; genj::GenJulia = GenJ,
                 globalFitnessFunction::FitnessFunction = FitnessFunction(nullGlobalFunction),
                 compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")

Sets the evaluator for `genj`, receiving an array with a function per fitness,
stablishing all the weights to one, meaning that all the fitnesses need to be
maximized and have the same importance. This function constructs a structure of
type `Evaluator` and adds it to the main structure.

# Arguments
- `functions::Array{Function}`: each function must evaluate an individual,
    receiving the individual's genotype and returning a fitness.
    (For information about genotypes look [`Genotype`](@ref))

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.
- `globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_)`: second-phase
    fitness function that is going to be evaluated once the other 'raw' fitness
    functions have been. For example, for [SPEA](@ref) algorithm, this fitness
    function serves to assign each individual its fitness level in the pareto front.
- `compareFunction::Function=_noFunc_`: function used to compare between individuals.
- `compareFunctionArgs::String = "rawW"`: tells the evaluator what is going to be
    compared. "raw" is for fitness comparison, "rawW" is for weighted fitness comparison,
    "global" is for second-phase fitness comparison, "globalW" is for weighted
    second-phase fitness comparison, "both" is for both fitness and second-phase
    fitness comparison and "bothW" is for both weighted fitness and weighted
    second-phase fitness comparison.

See also: [`Evaluator`](@ref), [FitnessFunction](@ref)
"""
function setEvaluator(functions::Array{Function}; genj::GenJulia = GenJ,
                      globalFitnessFunction::FitnessFunction = FitnessFunction(nullGlobalFunction),
                      compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")
    # The weights are stablished to one, which mean, the fitnesses are going to be maximized
    weights = ones(Real, length(functions))
    setEvaluator(functions, weights, genj=genj, globalFitnessFunction=globalFitnessFunction,
                 compareFunction=compareFunction, compareFunctionArgs=compareFunctionArgs)
end # function



"""
    setEvaluator(fitnessFunction1::Function, weights1::Real, varArgs...; genj::GenJulia = GenJ,
                 globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_),
                 compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")

Sets the evaluator for `genj`, receiving pair of functions and a related weights per fitness.
This function constructs a structure of type `Evaluator` and adds it to the main structure.

# Arguments
- `fitnessFunction1::Function`: function for the first fitness that must
    evaluate an individual, receiving the individual's genotype and
    returning a fitness. (For information about genotypes look [`genotype`](@ref))
- `weights1::Real`: weight for the first fitness, in absolute value, it
    represents the importance of its fitness in the system, whereas the sign is
    representative of maximization (positive) or minimization (negative).
- `varArgs`: pairs of fitness function and asociate weights. See `"Examples"`. It can be empty.

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.
- `globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_)`: second-phase
    fitness function that is going to be evaluated once the other 'raw' fitness
    functions have been. For example, for [SPEA](@ref) algorithm, this fitness
    function serves to assign each individual its fitness level in the pareto front.
- `compareFunction::Function=_noFunc_`: function used to compare between individuals.
- `compareFunctionArgs::String = "rawW"`: tells the evaluator what is going to be
    compared. "raw" is for fitness comparison, "rawW" is for weighted fitness comparison,
    "global" is for second-phase fitness comparison, "globalW" is for weighted
    second-phase fitness comparison, "both" is for both fitness and second-phase
    fitness comparison and "bothW" is for both weighted fitness and weighted
    second-phase fitness comparison.

# Examples
```jldoctest
julia> setEvaluator(myComputeFitnessFunction, 1.0)

julia> setEvaluator(myFitnesFunction1, 1.0, myFitnessFunction2, 0.7, myFitnessFunction3, -1.0)
```

See also: [`Evaluator`](@ref), [FitnessFunction](@ref)
"""
function setEvaluator(fitnessFunction1::Function, weights1::Real, varArgs...; genj::GenJulia = GenJ,
                      globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_),
                      compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")
    len = length(varArgs)
    if isodd(len)
        error("The number of fitness functions must be the same as the number of weights")
    else
        functions = Array{Function}(undef,1+div(len, 2))
        weights = Array{Real}(undef,1+div(len, 2))

        functions[1] = fitnessFunction1
        weights[1] = weights1

        for i=1:len
            if isodd(i)
                if typeof(varArgs[i]) <: Function
                    functions[div(i,2)+2] = varArgs[i]
                else
                    error("The odd positions in the arguments of the evaluator must be fitness functions")
                end
            else
                if typeof(varArgs[i]) <: Real
                    weights[div(i,2)+1] = varArgs[i]
                else
                    error("The even positions in the arguments of the evaluator must be weights")
                end
            end
        end

        setEvaluator(functions, weights, genj=genj, globalFitnessFunction=globalFitnessFunction,
                     compareFunction=compareFunction, compareFunctionArgs=compareFunctionArgs)
    end
end # function



"""
    setEvaluator(fitnessFunction1::Function, varArgs...; genj::GenJulia = GenJ,
                 globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_),
                 compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")

Sets the evaluator for `genj`, receiving a set of function or a individual one,
stablishing the weights to one, meaning that all the fitnesses need to be maximized.
This function constructs a structure of type `Evaluator` and adds it to the main structure.

# Arguments
- `fitnessFunction1::Function`: function for the first fitness that must
    evaluate an individual, receiving the individual's genotype and returning
    a `fitness`. (For information about genotypes look [`Genotype`](@ref))
- `varArgs`: list of fitness function. See `"Examples"`. It can be empty.

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.
- `globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_)`: second-phase
    fitness function that is going to be evaluated once the other 'raw' fitness
    functions have been. For example, for [SPEA](@ref) algorithm, this fitness
    function serves to assign each individual its fitness level in the pareto front.
- `compareFunction::Function=_noFunc_`: function used to compare between individuals.
- `compareFunctionArgs::String = "rawW"`: tells the evaluator what is going to be
    compared. "raw" is for fitness comparison, "rawW" is for weighted fitness comparison,
    "global" is for second-phase fitness comparison, "globalW" is for weighted
    second-phase fitness comparison, "both" is for both fitness and second-phase
    fitness comparison and "bothW" is for both weighted fitness and weighted
    second-phase fitness comparison.

# Examples
```jldoctest
julia> setEvaluator(myComputeFitnessFunction)

julia> setEvaluator(myFitnesFunction1, myFitnessFunction2, myFitnessFunction3)
```

See also: [`Evaluator`](@ref), [FitnessFunction](@ref)
"""
function setEvaluator(fitnessFunction1::Function, varArgs...; genj::GenJulia = GenJ,
                      globalFitnessFunction::FitnessFunction = FitnessFunction(_noFunc_),
                      compareFunction::Function=_noFunc_, compareFunctionArgs::String = "rawW")
    len = length(varArgs)
    functions = Array{Function}(undef,1+len)
    weights = ones(Real, 1+len)
    functions[1] = fitnessFunction1

    for i=1:len
        if typeof(varArgs[i]) <: Function
            functions[i+1] = varArgs[i]
        else
            error("The arguments of the evaluator must be fitness functions")
        end
    end

    setEvaluator(functions, weights, genj=genj, globalFitnessFunction=globalFitnessFunction,
                 compareFunction=compareFunction, compareFunctionArgs=compareFunctionArgs)
end # function
export setEvaluator
