"""
    getPhenotype(tree::CGPGenotype)

Obtains the phenotype of a given CGP genotype as an evaluable expresion (See [`Expr`](@ref)).

# Arguments
- `genotype::CGPGenotype`: genotype of the individual from which the phenotype is
    wanted.

# Returns
The phenotype of the individual as `Expr`.

See also: [`evaluate`](@ref)
"""
function getPhenotype(genotype::CGPGenotype)
    phenotype = Array{String}(undef, 0)
    representation = genotype._representation
    visitedFromRoot = Array{Int64}(undef, 0, 2)

    nodeIndex = 1
    parent = 0

    while nodeIndex != 0

        if nodeIndex > size(visitedFromRoot)[1]
            visitedFromRoot = vcat(visitedFromRoot, zeros(Int64, 1, 2))
            visitedFromRoot[end, 2] = parent

            if typeof(representation[nodeIndex]) <: TerminalNode

                if typeof(representation[nodeIndex]) <: VariableNode
                    push!(phenotype, getName(representation[nodeIndex]) * ",")

                elseif typeof(representation[nodeIndex]) <: ConstantNode
                    push!(phenotype, string(getName(representation[nodeIndex])) * ",")

                elseif typeof(representation[nodeIndex]) <: NoArgsFunctionNode
                    push!(phenotype, getName(representation[nodeIndex]) * "(),")
                end

            else typeof(representation[nodeIndex]) <: FunctionNode
                push!(phenotype, getName(representation[nodeIndex]) * "(")
            end
        end

        if visitedFromRoot[nodeIndex, 1] < getArity(representation[nodeIndex])
            parent = nodeIndex
            nodeIndex = size(visitedFromRoot)[1] + 1
        else
            if typeof(representation[nodeIndex]) <: FunctionNode
                push!(phenotype, "),")
            end
            nodeIndex = visitedFromRoot[nodeIndex, 2]
            if nodeIndex != 0
                visitedFromRoot[nodeIndex, 1] += 1
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
    compareFunctions(genotype::CGPGenotype, gpExperimentInfo::CGPInfo, objectives::Array)

This GP-exclusive fitness function compares the objective values given with the
ones obtained by the individual's evaluation using the values for the variables.
The fitness value that this function calculates is the MSE between the results of
the genotype for the given variable values and the objective values.

!!! note
    `Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::CGPGenotype`: genotype of the individual that is going to be evaluated.
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.

# User Arguments
- `objectives::Array`: objective values that are going to be compared.

# Returns
The MSE between the objective values and the results of evaluating the genotype
with the variables values set in [`setCGPInfo`](@ref).

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
function compareFunctions(genotype::CGPGenotype,
                          gpExperimentInfo::CGPInfo, objectives::Array)


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
precompile(compareFunctions, tuple(CGPGenotype,CGPInfo, Vector{Float64}))
