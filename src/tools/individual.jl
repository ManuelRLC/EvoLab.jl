"
Abstract type from which every individual genotype inherits.

See also: [`GAGenotype`](@ref), [`GPGenotype`](@ref)
"
abstract type Genotype end
# abstract type
export Genotype



"
Abstract type for every GA genotypes.

See also: [`BinaryGenotype`](@ref), [`IntegerGenotype`](@ref)
"
abstract type GAGenotype <: Genotype end
# abstract type
export GAGenotype



"
Abstract type for every GP genotypes.

See also: [`CGPGenotype`](@ref), [`STGPGenotype`](@ref), [`GEPGenotype`](@ref),
 [`GEGenotype`](@ref)
"
abstract type GPGenotype <: Genotype end
# abstract type
export GPGenotype



"""
    getRepresentation(genotype::GAGenotype)

Returns the representation of the genotype.
"""
getRepresentation(genotype::Genotype) = genotype._representation
# function
export getRepresentation



"
Main struct for individuals which contains the genotype and its fitnesses.

# Fields
- `_genotype::Genotype`: representation of the individual.
- `_fitness::Array{Real}`: fitness values of the individual.
- `_globalFitness::Real`: second-phase fitness value (if set) of the
    individual.

See also: [`Genotype`](@ref)
"
mutable struct Individual
    _genotype::Genotype
    _fitness::Array{Float64}
    _globalFitness::Float64

    Individual(genotype::Genotype, fitness::Array{Float64}, globalFitness::Float64) = new(genotype, fitness, globalFitness)
    Individual(genotype::Genotype, fitness::Array{Float64}) = new(genotype, fitness, NaN)
    Individual(genotype::Genotype, fitness::Float64) = new(genotype, [fitness], NaN)
    Individual(genotype::Genotype) = new(genotype, Array{Float64}(undef, 0), NaN)
    Individual() = new()
end



"""
    hasNullFitness(individual::Individual)::Bool

Checks whether an individual has been evaluated yet or not.
"""
function hasNullFitness(individual::Individual)::Bool
    isempty(individual._fitness)
end # function



"""
    getNumberFitness(ind::Individual)::Int

Returns the number of fitness values that the individual has.
"""
function getNumberFitness(ind::Individual)::Int
    length(ind._fitness)
end # function



"""
    getFitness(ind::Individual, index::Integer)::Float64

Returns the fitness value of the individual at the specified index.
"""
function getFitness(ind::Individual, index::Integer)::Float64
    ind._fitness[index]
end # function



"""
    getFitness(ind::Individual)::Array{Float64}

Returns all the fitness values of the individual.
"""
function getFitness(ind::Individual)::Array{Float64}
    copy(ind._fitness)
end # function



"""
    getFitness(population::Array{Individual})::Array{Float64}

Obtains the array of fitness values from the population.
"""
function getFitness(population::Array{Individual})::Array{Float64}
    len = length(population)
    nFitness = getNumberFitness(population)
    fitnessArray = Array{Float64}(undef, nFitness, len)

    for i = eachindex(population)
        fitnessArray[:, i] = getFitness(population[i])
    end

    return fitnessArray
end # function
export getFitness



"""
    getGlobalFitness(ind::Individual)::Float64

Returns the second-phase fitness value of the individual.
"""
function getGlobalFitness(ind::Individual)::Float64
    ind._globalFitness
end # function



"""
    getGlobalFitness(population::Array{Individual})::Array{Float64}

Obtains the array of second-phase fitness values of the population.
"""
function getGlobalFitness(population::Array{Individual})::Array{Float64}
    len = length(population)

    globalFitnessArray = Array{Float64}(undef, len)

    for i=eachindex(population)
        globalFitnessArray[i] = getGlobalFitness(population[i])
    end
    return globalFitnessArray
end # function
export getGlobalFitness



"""
    setFitness!(ind::Individual, fitness::Array{Float64})

Sets the fitness values of the individual.
"""
function setFitness!(ind::Individual, fitness::Array{Float64})
    ind._fitness = fitness
    nothing
end # function



"""
    setFitness!(ind::Individual, fitness::Float64; index::Integer = 1)

Sets a fitness value of the individual.
"""
function setFitness!(ind::Individual, fitness::Float64; index::Integer = 1)
    ind._fitness[index] = fitness
    nothing
end # function



"""
    setGlobalFitness!(ind::Individual, fitness::Real)

Sets the second-phase fitness value of the individual.
"""
function setGlobalFitness!(ind::Individual, fitness::Real)
    ind._globalFitness = fitness
    return nothing
end # function



"""
    setGlobalFitness!(population::Array{Individual}, globalFitnesses::Array{Float64})

Sets the second-phase fitness value of the individuals of a population.
"""
function setGlobalFitness!(population::Array{Individual}, globalFitnesses::Array{Float64})
    for i=eachindex(population)
        setGlobalFitness!(population[i], globalFitnesses[i])
    end
    return nothing
end # function



"""
    isPredefinedType(individualInfo::DataType)::Bool

Checks wether an individual type is one of the predefined ones or not.
"""
function isPredefinedType(individualInfo::DataType)::Bool
    findfirst(x->individualInfo <: x, [BinaryGenotype, IntegerGenotype, CGPGenotype,
                                       STGPGenotype, GEPGenotype, GEGenotype]) != nothing
end # function



"""
    getNumberFitness(population::Array{Individual})::Int

Returns the number of fitness values that the individual has.
"""
function getNumberFitness(population::Array{Individual})::Int
    getNumberFitness(population[1])
end # function



"""
    getGenotype(ind::Individual, saveCopy::Bool = false)::Genotype

Returns the individual's genotype. If `saveCopy` is set to `true`, the genotype
returned will be a copy of the original (this is used to prevent from modifications
that could cause undetermined behaviour).

# Arguments
- `individual::Individual`: the individual that contains the genotype.
- `saveCopy::Bool = false`: if set to `true`, a copy of the genotype will be
    returned.

# Returns
The genotype of the individual.
"""
function getGenotype(individual::Individual, saveCopy::Bool = false)::Genotype
    if saveCopy
        return copyGenotype(individual._genotype)
    else
        return individual._genotype
    end
end # function



"""
    getGenotype(population::Array{Individual}, saveCopy::Bool = false)::Array{Genotype}

Returns the individuals' genotypes of the population. If `saveCopy` is set to
`true`, the genotype returned will be a copy of the original (this is used to
prevent from modifications that could cause undetermined behaviour).

# Arguments
- `population::Array{Individual}`: the population of individuals.
- `saveCopy::Bool = false`: if set to `true`, a copy of the genotype will be
    returned.

# Returns
The genotype of the individual.
"""
function getGenotype(population::Array{Individual}, saveCopy::Bool = false)::Array{Genotype}

    len = length(population)
    selectedGenotype = Array{Genotype}(undef, len)

    for i=eachindex(population)
        selectedGenotype[i] = getGenotype(population[i], saveCopy)
    end

    return selectedGenotype
end # function
export getGenotype



"""
    copyInd(individual::Individual)::Individual

Returns a copy of an individual.
"""
function copyInd(individual::Individual)::Individual
    return Individual(getGenotype(individual), getFitness(individual), getGlobalFitness(individual))
end # function



"""
    population::Array{Individual}::Array{Individual}

Returns a copy of a population.
"""
function copyPop(population::Array{Individual})::Array{Individual}
    len = length(population)
    newPop = Array{Individual}(undef, len)
    for i=eachindex(population)
        newPop[i] = copyInd(population[i])
    end
    return newPop
end # function
