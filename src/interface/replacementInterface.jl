"""
    setReplacementOperator(method::Function, varArgs...;
                           genj::GenJulia = GenJ,
                           needsComparison::Bool = false)

Sets the replacement operator of the population for `genj`.
This function constructs a structure of type `ReplacementOperator` and adds it
to the main structure.

# Arguments
- `method::Function`: method that will tell which individuals of the population and
    the offspring will remain for the next generation.
- `varArgs`: list of arguments for the replacement method. See `"Examples"`.

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.
- `needsComparison::Bool = false`: tells wether the user wants the system to compare
    between the individuals in order to select the ones that will replace the old
    population.
- `eliteSize::Integer`: number of fittest individuals to be maintained if there
    is elitism.

# Examples
```jldoctest
julia> function ExampleReplacement(population::Array{Individual}, offspring::Array{Individual}, arg1, arg2)
    #···Code···
    return selectedIndexesFromPopulation, selectedIndexesFromOffspring
end
ExampleReplacement (generic function with 1 method)

julia> setReplacementOperator(ExampleReplacement, arg1, arg2)
ReplacementOperator(false, 0, ExampleReplacement, Any[arg1, arg2])
```

```jldoctest
julia> function ExampleReplacement(population::Array{Individual}, offspring::Array{Individual}, compare::Function, arg1, arg2)
    #···Code···
    return selectedIndexesFromPopulation, selectedIndexesFromOffspring
end
ExampleReplacement (generic function with 1 method)

julia> setReplacementOperator(ExampleReplacement, arg1, arg2, needsComparison=true, eliteSize=1)
ReplacementOperator(true, 1, ExampleReplacement, Any[arg1, arg2])
```

See also: [`ReplacementOperator`](@ref)
"""
function setReplacementOperator(method::Function, varArgs...;
                                genj::GenJulia = GenJ,
                                needsComparison::Bool = false,
                                eliteSize::Integer = 0)

    varArgs = [i for i in varArgs]
    genj._replacementOp = ReplacementOperator(needsComparison, eliteSize, method, varArgs)
end # function
export setReplacementOperator
