"
Generator represents the way that a population is going to be generated.

# Fields
-`_popSize::UInt32`: size of the population, number of individuals.
-`_generateOneByOne::Bool`: specifies wether the generation method generates
    a single individual each run or the whole population at a time.
-`_method::Function`: method used for generating the individuals.
-`_varArgs::Array{Any}`: arguments necessary for the generation method.
"
mutable struct Generator
    _popSize::UInt32
    _generateOneByOne::Bool
    _method::Function
    _varArgs::Array{Any}
end # struct



"""
    getPopSize(gen::Generator)::UInt32

Returns the population size assigned.
"""
getPopSize(gen::Generator)::UInt32 = gen._popSize
# function



"""
    getMethod(gen::Generator)::Function

Returns the method for generate the population.
"""
getMethod(gen::Generator)::Function = gen._method
# function



"""
    isGeneratedOneByOne(gen::Generator)::Bool

Returns whether the method generates individual one by one or all individuals in a single call
"""
isGeneratedOneByOne(gen::Generator)::Bool = gen._generateOneByOne
#function



"""
    getFunctionArgs(gen::Generator)::Array

Obtains the aditional arguments associated to initialization method.
"""
getFunctionArgs(gen::Generator)::Array = gen._varArgs
#function



function genPopulationOneByOne_!(generator::Generator, experimentInfo::ExperimentInfo,
                                population::Array{Individual})
    for i in eachindex(population)
        if getIndividualType(experimentInfo) <: GAGenotype
            genotype = generator._method(experimentInfo._rng, generator._varArgs...)
        else
            genotype = generator._method(experimentInfo._GPExperimentInfo, experimentInfo._rng, generator._varArgs...)
        end
        population[i] = Individual(genotype)
    end
end

function genPopulationAll_!(generator::Generator, experimentInfo::ExperimentInfo,
                           population::Array{Individual})::Array{Individual}


    if getIndividualType(experimentInfo) <: GAGenotype
        populationGenotype = generator._method(generator._popSize, experimentInfo._rng, generator._varArgs...)
        map!(x->Individual(x), population, populationGenotype)
    else
        populationGenotype = generator._method(experimentInfo._GPExperimentInfo, generator._popSize, experimentInfo._rng, generator._varArgs...)
        map!(x->Individual(x), population, populationGenotype)
    end

end

"""
    genPopulation_(generator::Generator, experimentInfo::ExperimentInfo)::Array{Individual}

Generates a population of individuals according to the method given by the Generator.
"""
function genPopulation_(generator::Generator, experimentInfo::ExperimentInfo)::Array{Individual}
    population = Array{Individual}(undef, getPopSize(generator))

    if isGeneratedOneByOne(generator)
        genPopulationOneByOne_!(generator, experimentInfo, population)
    else
        genPopulationAll_!(generator, experimentInfo, population)
    end
    return population
end # function

precompile(genPopulation_, tuple(Generator, ExperimentInfo))
