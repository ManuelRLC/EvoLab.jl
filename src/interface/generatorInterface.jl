"""
    setGenerator(method::Function, varArgs...; genj::GenJulia = GenJ,
                 popSize::Integer = 100, generateOneByOne::Bool = true)

Sets the generator of population for `genj`, receiving a function that generates
a single individual or a population of individuals and the number of individual
that are going to be generated. This function constructs a structure of type
`Generator` and adds it to the main structure.

# Arguments
- `method::Function`: function that receives `"varArgs"`, which is a list of
    arguments, as own arguments, and generates an `individual genotype`.
    (For information about representation look [`Genotype`](@ref))
- `varArgs`: list of arguments for the method of generation. See `"Examples"`.

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are goint to be run.
- `popSize::Integer = 100`: number of individuals that are going to be generated at
    the beginning of the experiment.
- `generateOneByOne::Bool = true`: tells wether the generation method generates
    a single individual or the whole population.

# Examples
```jldoctest
julia> function GenerateAnIndividual()
    #···Code···
    return indRep::Genotype # Type expressed here for user awareness
end

julia> setGenerator(GenerateAnIndividual, popSize = 100)
```

```jldoctest
julia> function AlsoGenerateAnIndividual(arg1, arg2)
    #···Code···
    return indRep::Genotype # Type expressed here for user awareness
end

julia> setGenerator(AlsoGenerateAnIndividual, arg1, arg2, popSize = 100)
```

```jldoctest
julia> function GenerateAPopulation()
    #···Code···
    return population::Array{Genotype} # Type expressed here for user awareness
end

julia> setGenerator(GenerateAPopulation, popSize = 100, generateOneByOne = false)
```

See also: [`Generator`](@ref)
"""
function setGenerator(method::Function, varArgs...; genj::GenJulia = GenJ,
                      popSize::Integer = 100, generateOneByOne::Bool = true)

    if popSize > 0
        varArgs = [i for i in varArgs]
        genj._generator = Generator(popSize, generateOneByOne, method, varArgs)
    else
        error("Population size must be a number greater than 0")
    end
end # function
export setGenerator
