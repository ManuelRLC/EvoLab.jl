

"""
    setCrossoverOperator(method::Function, varArgs...;
                        genj::GeneticJulia = GenJ,
                        probability::Number = 0.7,
                        nChildren::Int = -1)

Set the crossover operator of parents for `genj`, receiving a function that cross multiples individual representations and return one child or multiple children.
    This function constructs an structure of type `CrossoverOperator` and adds it to the main structure.

# Arguments
- `method::Function`: function that receives, first, a list of parents as arguments which are individual representation and `"varArgs"`, that is a list of arguments, as own arguments, and return a number between 1 and nParents of children, where each one is an individual representation. (For information about representation look [`IndividualRep`](@ref)). See `"Examples"`.
- `varArgs`: List of arguments for crossover method. See `"Examples"`.

# Keyword Arguments
- `genj::GeneticJulia = GenJ`: the main structure. For `code user`: don't modify the default value unless multiple experiments are goint to be run.
- `probability::Number = 0.7`: A floating point number, between `0` and `1`, that represents the probability of doing each single crossover operation.
- `nChildren::Int = -1`: The number of children as result of the crossover method. It must be either a number between `0` and `nParents` or `-1` which is equal to `nParents`.

## Note
The `CrossoverOperator` uses the `nParents` variable that define the number of parents per cross and it can be set through `setNParentsPerCross` function. The default value is `2`.

# Examples
```jldoctest
#Function with 2 parents, no more arguments and 1 child
function ExampleCrossParents1(Parent1::IndividualRep, Parent2::IndividualRep)
    #···Code···
    return children::IndividualRep # Type expressed here for user awareness
end

julia> setCrossoverOperator(ExampleCrossParents1, probability = 0.4, nChildren = 1)

_______________________________

#Function with more than 2 parents, no more arguments and the same number of children as parents.
function ExampleCrossParents2(Parent1::IndividualRep, Parent2::IndividualRep, Parent3::IndividualRep)
    #···Code···
    return children::Array{IndividualRep}(undef, 3) # Type expressed here for user awareness
end

julia> setCrossoverOperator(ExampleCrossParents2, probability = 0.6, nChildren = -1)

________________________________

#Function with more arguments and the same number of children as parents
function ExampleCrossParents3(Parent1::IndividualRep, Parent2::IndividualRep, arg1, arg2)
    #···Code···
    return children::Array{IndividualRep}(undef, 2) # Type expressed here for user awareness
end

julia> setCrossoverOperator(ExampleCrossParents3, arg1, arg2, probability = 0.6, nChildren = -1)
```

See also: [`CrossoverOperator`](@ref)
"""
function setCrossoverOperator(method::Function, varArgs...; genj::GeneticJulia = GenJ, probability::Number = 0.7, nChildren::Int = -1)

    if !(0 <= probability <= 1)
        error("Crossover probability must be within 0 and 1")
    end

    if nChildren != -1 && nChildren < 1
        error("Number of children per cross must be either -1 or greater than 0")
    end

    varArgs = [i for i in varArgs]
    genj._crossoverOp = CrossoverOperator(method, probability, nChildren, varArgs)
end # function
