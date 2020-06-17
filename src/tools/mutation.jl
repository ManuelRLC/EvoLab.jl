"
MutationOperator represents the method that mutates the individuals selected to
create a new generation of individuals.

# Fields
- `_method::Function`: method used for mutation.
- `_probability::Float32`: probability of mutation.
- `_varArgs::Array{Any}`: arguments necessary for the mutation method.
"
struct MutationOperator
    _method::Function
    _probability::Float32
    _varArgs::Array{Any}
end # struct



"""
    getMethod(mutationOp::MutationOperator)::Function

Returns the method for mutate the offspring.
"""
getMethod(mutationOp::MutationOperator)::Function = mutationOp._method
# function



"""
    getMutateProbability(mutationOp::MutationOperator)::Float32

Obtains the probability for a set of individuals to be mutated.
"""
getMutateProbability(mutationOp::MutationOperator)::Float32 = mutationOp._probability
# function



"""
    getFunctionArgs(mutationOp::MutationOperator)::Array

Obtains the aditional arguments associated to mutation method.
"""
getFunctionArgs(mutationOp::MutationOperator)::Array = mutationOp._varArgs
#function



"""
    getDefaultMutationOp(individualType::DataType)::Tuple{Function, Array}

Returns a default mutation method for each registered individual type. For
`BinaryGenotype`, it is [`standardMutation`](@ref) with a probability of 0.1;
for `IntegerGenotype`, it is [`uniformMutation`](@ref) of one gene within a range of 0:10;
for both `CGPGenotype` and `STGPGenotype` it is [`pointMutation`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`geneMutation`](@ref).
"""
function getDefaultMutationOp(individualType::Genotype)
    return nothing
end # function



"""
    mutate_(mutationOp::MutationOperator, offspring::Array{Individual},
            experimentInfo::ExperimentInfo)::Array{Individual}

Performs a mutation on a set of individuals.
"""
function mutate_(mutationOp::MutationOperator, offspring::Array{Individual},
                 experimentInfo::ExperimentInfo)::Array{Individual}

    nSelected = length(offspring)
    offspringRep = getGenotype(offspring)
    rng = getRNG(experimentInfo)
    mutateProbability = getMutateProbability(mutationOp)
    method = getMethod(mutationOp)
    functionArgs = getFunctionArgs(mutationOp)


    if experimentInfo._individualType <: GAGenotype
        for i in eachindex(offspring)

            random = rand(rng)

            if random < mutateProbability
                offspringRep[i] = method(offspringRep[i], rng,  functionArgs...)
                offspring[i] = Individual(offspringRep[i])
            end
        end
    else
        for i in eachindex(offspring)

            random = rand(rng)

            if random < mutateProbability
                offspringRep[i] = method(offspringRep[i], experimentInfo._GPExperimentInfo, rng, functionArgs...)
                offspring[i] = Individual(offspringRep[i])
            end
        end
    end

    return offspring
end # function
