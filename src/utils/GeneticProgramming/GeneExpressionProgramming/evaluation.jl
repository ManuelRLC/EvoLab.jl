"""
    getPhenotype(tree::GEPGenotype)
documentation
"""
function getPhenotype(tree::GEPGenotype)

    representation = tree._representation
    lenRep = length(representation)

    phenotype = Array{String}(undef, 0)

    visitedFromRoot = zeros(Int64, lenRep, 4)
    visitedFromRoot[:, 1] = fill(-1, lenRep)
    visitedFromRoot[:, 4] = fill(-1, lenRep)
    visitedNodes = Array{Int64}(undef, 0)
    step = getArity(representation[1])
    currLevel = 0
    i = 1
    visitedFromRoot[i, 1] = currLevel

    while step != 0
        currLevel += 1
        i += 1
        currLevelNodes = collect(i:(i+step-1))
        visitedFromRoot[currLevelNodes, 1] = fill(currLevel, step)
        i += step - 1
        step = isempty(currLevelNodes) ? 0 : reduce(+, getArity.(representation[currLevelNodes]))
    end

    i = 1

    while i != 0

        if typeof(representation[i]) <: FunctionNode

            if findfirst(x->x==i, visitedNodes) == nothing
                push!(visitedNodes, i)
                push!(phenotype, getName(representation[i]) * "(")
            end

            if visitedFromRoot[i, 3] < getArity(representation[i])

                if visitedFromRoot[i, 4] == -1
                    prevSameLevel = representation[findprevIndexes(x -> visitedFromRoot[i, 1] == x, visitedFromRoot[:, 1], i-1)]
                    postSameLevel = findnextIndexes(x -> visitedFromRoot[i, 1] == x, visitedFromRoot[:, 1], i+1)
                    visitedFromRoot[i, 4] = isempty(prevSameLevel) ? length(postSameLevel) + 1 : reduce(+, getArity.(prevSameLevel)) + length(postSameLevel) + 1
                end

                parent = i
                i += visitedFromRoot[i, 4] + visitedFromRoot[i, 3]
                visitedFromRoot[i, 2] = parent
            else
                push!(phenotype, "),")
                i = visitedFromRoot[i, 2]
                if i != 0
                    visitedFromRoot[i, 3] += 1
                end
            end
        else

            if typeof(representation[i]) <: VariableNode
                push!(phenotype, getName(representation[i]) * ",")

            elseif typeof(representation[i]) <: ConstantNode
                push!(phenotype, string(getName(representation[i])) * ",")

            elseif typeof(representation[i]) <: NoArgsFunctionNode
                push!(phenotype, getName(representation[i]) * "(),")
            end

            i = visitedFromRoot[i, 2]
            if i != 0
                visitedFromRoot[i, 3] += 1
            end
        end
    end

    phenotype[end] = phenotype[end][1:end-1]

    if length(phenotype) == 1
        phenotype = Meta.parse(phenotype[1])
        return quote $phenotype end
    else
        return Meta.parse(join(phenotype))
    end
end # function



"""
    compareFunctions(genotype::GEPGenotype, gpExperimentInfo::GEPInfo, objectives::Array)

This GP-exclusive fitness function compares the objective values given with the
ones obtained by the individual's evaluation using the values for the variables.
The fitness value that this function calculates is the MSE between the results of
the genotype for the given variable values and the objective values.

!!! note
    `Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::GEPGenotype`: genotype of the individual that is going to be evaluated.
- `gpExperimentInfo::GEPInfo`: information about the GP experiment.

# User Arguments
- `objectives::Array`: objective values that are going to be compared.

# Returns
The MSE between the objective values and the results of evaluating the genotype
with the variables values set in [`setGEPInfo`](@ref).

# Examples
Setting the fitness function with some objective values.
```jdoctests
julia> objectives = [0, 1, 4, 9, 16, 25]
6-element Array{Int64,1}:
[...]

julia> setEvaluator([FitnessFunction(compareFunctions, objectives, weight=-1)])
[...]
```

See also: [`setEvaluator`](@ref), [`FitnessFunction`](@ref)
"""
function compareFunctions(genotype::GEPGenotype, gpExperimentInfo::GEPInfo,
                          objectives::Array)

    vars = gpExperimentInfo._variables
    nVars = length(vars)
    phenotype = getPhenotype(genotype)

    nValues = 1
    y = 0
    y_est = 0
    acc = 0
    failures = 0

    if nVars == 0

        y = objectives[1]

        try
            y_est = evalPhenotype(phenotype)

            if isnan(y_est) || abs(y_est) == Inf
                failures += 1
            else
                acc += (abs(y - y_est))^2
            end
        catch
            failures += 1
        end

    else
        nValues = size(gpExperimentInfo._varValues)[1]
        for i=1:nValues

            y = objectives[i]

            try
                y_est = evalPhenotype(phenotype, gpExperimentInfo._varValues[i])

                if isnan(y_est) || abs(y_est) == Inf
                    failures += 1
                else
                    acc += (abs(y - y_est))^2
                end
            catch e

                failures += 1
            end
        end
    end

    if failures > (nValues * 0.15)
        fitness = Inf
    else
        mse = acc/(nValues - failures)
        fitness = (acc + failures * mse * 3) / nValues
    end

    return fitness
end # function
