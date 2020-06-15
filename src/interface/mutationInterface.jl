"""
    setMutationOperator(method::Function, varArgs...; genj::GenJulia = GenJ,
                        probability::AbstractFloat = 0.3)

Sets the mutation operator of parents for `genj`, receiving a function that
mutates an individual and returns the genotype of the mutated child. This function
constructs a structure of type `MutationOperator` and adds it to the main structure.

# Arguments
- `method::Function`: function that receives, first, a parent as argument which
    is an individual's genotype and `"varArgs"`, which is a list of arguments,
    as own arguments, and returns the genotype of the mutated child.
    (For information about representation look [`Genotype`](@ref)). See `"Examples"`.
- `varArgs`: list of arguments for the mutation method. See `"Examples"`.

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.
- `probability::AbstractFloat = 0.3`: a floating point number, between `0` and `1`,
    that represents the probability of doing each single mutation operation.

# Examples
```jldoctest
julia> #Function without extra arguments
julia> function ExampleMutation(Individual::Genotype)
    #···Code···
    return children::Genotype # Type expressed here for user awareness
end

julia> setMutationOperator(ExampleMutation, probability = 0.1)
```

```jldoctest
julia> #Function with extra arguments
julia> function AlsoExampleMutation(Individual::Genotype, arg1, arg2)
    #···Code···
    return children::Genotype # Type expressed here for user awareness
end

julia> setMutationOperator(AlsoExampleMutation, arg1, arg2, probability = 0.1)
```

See also: [`MutationOperator`](@ref)
"""
function setMutationOperator(method::Function, varArgs...; genj::GenJulia = GenJ,
                             probability::AbstractFloat = 0.3)

    if 0 <= probability <= 1
        varArgs = [i for i in varArgs]
        genj._mutationOp = MutationOperator(method, probability, varArgs)
    else
        error("Mutation probability must be within 0 and 1")
    end
end # function
export setMutationOperator



"""
    setNullMutation()
Makes the mutation non-existent for the evolutionary proccess.
This function constructs a structure of type `CrossoverOperator` and adds it to the main structure.

At least, one between crossover and mutation (or both) must exist in the experiment.
"""
function setNullMutation(; genj::GenJulia = GenJ)
    noFunction() = nothing
    genj._mutationOp = MutationOperator(noFunction, 0.0, [])
end # function
export setNullMutation
