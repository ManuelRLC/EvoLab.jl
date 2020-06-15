"""
    setSelector(method::Function, varArgs...; genj::GenJulia = GenJ,
                nSelected::Real = 1.0, needsComparison::Bool = true,
                samplingWithRep::Bool = true)

Sets the selector of parents for `genj`, receiving a function that selects a
single individual among the population and the number of individuals that are
going to be selected. This function constructs a structure of type `Selector`
and adds it to the main structure.

# Arguments
- `method::Function`: function that receives the individuals of the population as
    first argument and `"varArgs"`, which is a list of arguments, as own arguments,
    and returns the index of the selected individual as an `Integer`.
- `varArgs`: list of arguments for the selection method. See `"Examples"`.

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.
- `nSelected::Real = 1.0`: if `Integer`, it represents the exact number
    of parents, whereas if `Float`, it represents a ratio of the population.
- `needsComparison::Bool = true`: tells wether the user wants the system to compare
    between the individuals in order to select the ones that will replace the old
    population.
- `samplingWithRep::Bool = true`: specifies if the selection is done with or without
    replacement.

If the user specifies that comparison between individuals is necessary, the
selection method must receive the `compareFunction` function as it is
shown in `"Examples"`.

# Examples
```jldoctest
julia> function SelectAnIndividual(population::Array{Individual})
    #···Code···
    return selectedIndex
end
SelectAnIndividual (generic function with 1 method)

julia> setSelector(SelectAnIndividual, nSelected = 1.0, needsComparison = false)
SelectionOperator(SelectAnIndividual, 1.0, false, true, Any[])
```

```jldoctest
# Fitness comparison was not set here
julia> function AlsoSelectAnIndividual(population::Array{Individual}, arg1, arg2)
    #···Code···
    return selectedIndex
end
AlsoSelectAnIndividual (generic function with 1 method)

julia> setSelector(AlsoSelectAnIndividual, arg1, arg2, nSelected = 2, needsComparison = false)
SelectionOperator(AlsoSelectAnIndividual, 1.0, false, true, Any[arg1, arg2])
```

```jldoctest
julia> function YetAnotherSelectAnIndividual(population::Array{Individual}, compareFitness::Function)
    #···Code···
    return selectedIndex
end
YetAnotherSelectAnIndividual (generic function with 1 method)

julia> setSelector(YetAnotherSelectAnIndividual, nSelected = 1.0, needsComparison = true)
SelectionOperator(YetAnotherSelectAnIndividual, 1.0, true, true, Any[])
```

```jldoctest
# Fitness comparison was set here
julia> function SelectAnIndividualWithoutRep(population::Array{Individual}, compareFitness::Function)
    #···Code···
    return selectedIndex
end
SelectAnIndividualWithoutRep (generic function with 1 method)

julia> setSelector(SelectAnIndividualWithoutRep, nSelected = 1.0, needsComparison = true, samplingWithRep = false)
SelectionOperator(SelectAnIndividualWithoutRep, 1.0, true, false, Any[])
```

See also: [`Selector`](@ref)
"""
function setSelector(method::Function, varArgs...; genj::GenJulia = GenJ,
                     nSelected::Real = 1.0,
                     needsComparison::Bool = true,
                     samplingWithRep::Bool = true)

    if typeof(nSelected) <: Integer
        if nSelected < 1
            error("Number of selected individuals must be greater than 0")
        end
    else
        if nSelected < 0.0
            error("Number of selected individuals must be a ratio greater than 0")
        end
    end

    varArgs = [i for i in varArgs]
    genj._selector = SelectionOperator(method, nSelected, needsComparison, samplingWithRep, varArgs)
end # function
export setSelector
