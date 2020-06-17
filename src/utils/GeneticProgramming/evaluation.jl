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
