"""
    changeSymbol!(expr, namedTuple)

Changes the symbols of the named tuple found in the expression into their actual
values.
"""
function changeSymbol!(expr, namedTuple)
    function changeRec!(list)
        for i=1:length(list)
            if typeof(list[i]) <: Expr
                changeRec!(list[i].args)
            elseif typeof(list[i]) <: Symbol
                if haskey(namedTuple, list[i])
                    list[i] = namedTuple[list[i]]
                end
            end
        end
    end # function

    changeRec!(expr.args)
end # function



"""
    evalPhenotype(phenotype::Expr, varsDict::NamedTuple)

Evaluates a phenotype using a named tuple to change the symbols of the variables
into their actual values.

# Arguments
- `phenotype::Expr`: phenotype of a GP tree, obtained by [`getPhenotype`](@ref).
- `varsDict::NamedTuple`: named tuple with the variables used for a GP problem
    and their respective values.

# Returns
The evaluation of the phenotype with the variables' values.

See documentation for [`FitnessFunction`](@ref) for instructions about how to
evaluate GP individuals.
"""
function evalPhenotype(phenotype::Expr, varsDict::NamedTuple)
    newPhenotype = copy(phenotype)
    changeSymbol!(newPhenotype, varsDict)
    return eval(newPhenotype)
end # function



"""
    evalPhenotype(phenotype::Expr, variables::Array{String}, varValues...)

Evaluates a phenotype using a named tuple to change the symbols of the variables
into their actual values.

# Arguments
- `phenotype::Expr`: phenotype of a GP tree, obtained by [`getPhenotype`](@ref).
- `variables::Array{String}`: names of the variables of the problem.
- `varValues`: values of the variables of the problem.

# Returns
The evaluation of the phenotype with the variables' values.

See documentation for [`FitnessFunction`](@ref) for instructions about how to
evaluate GP individuals.
"""
function evalPhenotype(phenotype::Expr, variables::Array{String}, varValues...)
    nVars = length(variables)
    vars = [Meta.parse(x) for x in variables]
    vars = (vars...,)

    varsdict = NamedTuple{vars}(varValues)

    return evaluate(phenotype, varsdict)
end # function



"""
    evalPhenotype(phenotype::Expr)

Evaluates a phenotype of a GP problem that has no variables in it.

# Arguments
- `phenotype::Expr`: phenotype of a GP tree, obtained by [`getPhenotype`](@ref).

# Returns
The evaluation of the phenotype.

See documentation for [`FitnessFunction`](@ref) for instructions about how to
evaluate GP individuals.
"""
function evalPhenotype(phenotype::Expr)
    return eval(phenotype)
end # function



"""
    compareFunctions(genotype::GPGenotype,
                    gpExperimentInfo::GPExperimentInfo, objectives::Array,
                    values...)

This GP-exclusive fitness function compares the objective values given with the
ones obtained by the individual's evaluation using the values for the variables.
The fitness value that this function calculates is the MSE between the results of
the genotype for the given variable values and the objective values.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::GPGenotype`: genotype of the individual that is going to be evaluated.
- `gpExperimentInfo::GPExperimentInfo`: information about the GP experiment.

# User Arguments
- `objectives::Array`: objective values that are going to be compared.
- `values`: values of the variables. Must be in the same order as the variables
    are in the GP experiment information (see documentation of [`GPExperimentInfo`](@ref)
    and [`getVariables`](@ref)).

# Returns
The MSE between the objective values and the results of evaluating the genotype
with the given variables values.

# Examples
```jdoctests
julia> objectives = [0, 1, 4, 9, 16, 25] #Objective values
6-element Array{Int64,1}:
[...]

julia> xValues = [0, 1, 2, 3, 4 , 5] #Values for variable x
6-element Array{Int64,1}:
[...]

julia> setEvaluator([FitnessFunction(compareFunctions, objectives, xValues, weight=-1)])
Evaluator(...)
```

See also: [`setEvaluator`](@ref), [`FitnessFunction`](@ref)
"""

"""function compareFunctions(genotype::GPGenotype,
                          gpExperimentInfo::GPExperimentInfo, objectives::Array,
                          values...)


    vars = getVariables(gpExperimentInfo)
    nVars = length(vars)

    vars = [Meta.parse(x) for x in vars]
    vars = (vars...,)
    phenotype = getPhenotype(genotype)

    values = [i for i in values]
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
        nValues = length(values[1])
        varValues = Array{Number}(undef, nVars)
        for i=1:nValues

            for j=1:nVars
                varValues[j] = values[j][i]
            end
            varsdict = NamedTuple{vars}(varValues)

            y = objectives[i]

            try
                y_est = evaluate(phenotype, varsdict)

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
end # function"""
