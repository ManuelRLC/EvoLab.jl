"""
    getPhenotype(gramm::Grammar, genotype::GEGenotype)

Obtains the phenotype as expresion in Julia from a grammatical tree.
"""
function getPhenotype(gramm::Grammar, genotype::GEGenotype)

    if !genotype._valid
        return quote Inf end
    end
    tree = genotype._tree
    stack = [tree]
    result = Array{String}(undef, 0)

    while !isempty(stack)
        node = popfirst!(stack)
        if isLeaf(node)
            push!(result, getRepresentation(gramm, node))
        else
            children = getChildren(node)
            nChildren = length(children)
            for i=1:nChildren
                pushfirst!(stack, children[i])
            end
        end
    end
    if length(result) == 1
        result = Meta.parse(result[1])
        return quote $result end
    else
        aux = Meta.parse(join(result))
        if !(typeof(aux) <: Expr)
            return quote $aux end
        else
            return aux
        end
    end
end



"""
    compareFunctions(genotype::GEGenotype, gpExperimentInfo::GPExperimentInfo, objectives::Array)

This GP-exclusive fitness function compares the objective values given with the
ones obtained by the individual's evaluation using the values for the variables.
The fitness value that this function calculates is the MSE between the results of
the genotype for the given variable values and the objective values.

!!! note
    `Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::GPGenotype`: genotype of the individual that is going to be evaluated.
- `gpExperimentInfo::GPExperimentInfo`: information about the GP experiment.

# User Arguments
- `objectives::Array`: objective values that are going to be compared.

# Returns
The MSE between the objective values and the results of evaluating the genotype
with the variables values set in [`setGEInfo`](@ref).

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
function compareFunctions(genotype::GEGenotype, gpExperimentInfo::GEInfo,
                          objectives::Array)


    vars = gpExperimentInfo._variables
    nVars = length(vars)
    phenotype = getPhenotype(gpExperimentInfo._grammar, genotype)

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
