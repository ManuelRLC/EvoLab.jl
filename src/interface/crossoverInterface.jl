"""
    setCrossoverOperator(method::Function, varArgs...; genj::GenJulia = GenJ,
                         probability::AbstractFloat = 0.7, nParents::Integer = 2,
                         nChildren::Integer = -1)

Sets the crossover operator of parents for `genj`, receiving a function that
crosses multiples individual representations and returns one child or multiple
children. This function constructs a structure of type `CrossoverOperator` and
adds it to the main structure.

# Arguments
- `method::Function`: function that receives, first, a list of parents as
    arguments which are individual representations and `"varArgs"`, which is a
    list of arguments, as own arguments, and returns a number between 1 and
    nParents of children in an array, where each one is an individual's genotype.
    (For information about genotypes look [`Genotype`](@ref)). See `"Examples"`.
- `varArgs`: list of arguments for crossover method. See `"Examples"`.

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.
- `probability::AbstractFloat = 0.7`: a floating point number, between `0` and `1`,
    that represents the probability of doing each single crossover operation.
- `nParents::Integer = 2`: the number of parents that are going to be crossed. It
    must be a number greater than 0.
- `nChildren::Integer = -1`: the number of children as result of the crossover method.
    It can be any number greater than 0, while -1 can be used to express that the number
    of children generated is the same as the number of parents.

# Examples
```jldoctest
julia> #Function with 2 parents, no more arguments and 1 child
julia> function ExampleCrossParents1(Parent1::Genotype, Parent2::Genotype)
    #···Code···
    return children::Array{Genotype} # Type expressed here for user awareness
end

julia> setCrossoverOperator(ExampleCrossParents1, probability = 0.4, nChildren = 1)
```
```jldoctest
julia> #Function with more than 2 parents, no more arguments and the same number of children as parents.
julia> function ExampleCrossParents2(Parent1::Genotype, Parent2::Genotype, Parent3::Genotype)
    #···Code···
    return children::Array{Genotype} # Type expressed here for user awareness
end

julia> setCrossoverOperator(ExampleCrossParents2, probability = 0.6, nParents = 3)
```
```jldoctest
julia> #Function with more arguments and the same number of children as parents
julia> function ExampleCrossParents3(Parent1::Genotype, Parent2::Genotype, arg1, arg2)
    #···Code···
    return children::Array{Genotype}(undef, 2) # Type expressed here for user awareness
end

julia> setCrossoverOperator(ExampleCrossParents3, arg1, arg2, probability = 0.6)
```

See also: [`CrossoverOperator`](@ref)
"""
function setCrossoverOperator(method::Function, varArgs...; genj::GenJulia = GenJ,
                              probability::AbstractFloat = 0.7, nParents::Integer = 2,
                              nChildren::Integer = -1)

    if !(0 <= probability <= 1)
        error("Crossover probability ($probability) must be within 0 and 1")
    end

    if nParents < 1
        error("Number of parents ($nParents) given must be greater than 0")
    end

    if nChildren != -1 && nChildren < 1
        error("Number of children ($nChildren) per cross must be either -1 or greater than 0")
    end

    if nChildren == -1
        nChildren = nParents
    end

    varArgs = [i for i in varArgs]
    genj._crossoverOp = CrossoverOperator(method, probability, nParents, nChildren, varArgs)
end # function
export setCrossoverOperator



"""
    setNullCrossover()

Makes the crossover non-existent for the evolutionary proccess.
This function constructs a structure of type `CrossoverOperator` and adds it to the main structure.

At least, one between crossover and mutation (or both) must exist in the experiment.
"""
function setNullCrossover(;genj::GenJulia = GenJ)
    noFunction() = nothing
    genj._crossoverOp = CrossoverOperator(noFunction, 0.0, 2, -1, [])
end
export setNullCrossover
