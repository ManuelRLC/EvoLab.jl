"""
    basicExperiment(; genj::GenJulia = GenJ)

Runs a single experiment with the tools and methods specified in `genj`.

# Keyword Arguments
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify the default value unless multiple experiments are going to be run.

See also: [`run`](@ref)
"""
function basicExperiment(genj::GenJulia)

    initTime(genj)
    genPopulation!(genj)
    evaluate!(genj, genj._population)
    initBestIndividual(genj)

    while !(reached(genj))

        saveResults(genj)
        selectedParents = selectParents(genj)
        offspring = cross(genj, selectedParents)
        mutatedOffspring = mutate(genj, offspring)
        evaluate!(genj, mutatedOffspring)
        replacePopulation!(genj, mutatedOffspring)
    end

    saveResults(genj)
end # function
precompile(basicExperiment, tuple(GenJulia))
export basicExperiment



"""
    basicExperimentDeep(; genj::GenJulia = GenJ)

!!! warning
    For testing, don't use.
"""
function basicExperimentDeep(genj::GenJulia = GenJ)
    """println("Init")
    @time initTime(genj)
    println("GenPop")
    @time genPopulation!(genj)
    println("Evaluate")
    @time evaluate!(genj, genj._population)
    println("InitBest")
    @time initBestIndividual(genj)

    while !(reached(genj))

        println("Save")
        @time saveResults(genj)
        println("Select")
        @time selectedParents = selectParents(genj)
        println("cross")
        @time offspring = cross(genj, selectedParents)
        println("Mutate")
        @time mutatedOffspring = mutate(genj, offspring)
        println("Evaluate")
        @time evaluate!(genj, mutatedOffspring)
        println("Replace")
        @time replacePopulation!(genj, mutatedOffspring)

    end

    println("Save")
    @time saveResults(genj)"""
end # function



"""
    SPEA(genj::GenJulia, archiveSize::Integer)

documentation
"""
function SPEA(genj::GenJulia, archiveSize::Int64)

    getDominant(population::Array{Individual}) = filter(x->getGlobalFitness(x)==1, population)

    function truncateArchive(archive::Array{Individual})

        k = round(Integer, sqrt(archiveSize + genj._generator._popSize))
        rest = length(archive) - archiveSize
        fitnesses = getFitness(archive)
        distanceMatrix = pairwiseDistance(fitnesses, fitnesses, euclideanDistance)

        for i=1:rest
            nearestDistances = sum(distanceMatrix[1, getKnearest(distanceMatrix[1,:], k)])
            bestIndex = 1
            for j=2:size(distanceMatrix)[1]
                current = sum(distanceMatrix[j, getKnearest(distanceMatrix[j,:], k)])
                if current < nearestDistances
                    nearestDistances = current
                    bestIndex = j
                end
            end
            distanceMatrix = distanceMatrix[1:end .!= bestIndex, 1:end .!= bestIndex]
            archive = archive[1:end .!= bestIndex]
        end

        return archive
    end

    initTime(genj)
    genPopulation!(genj)
    evaluate!(genj, genj._population)
    initBestIndividual(genj)
    archive = getDominant(genj._population)

    while !reached(genj)

        saveResults(genj)
        if length(archive) > archiveSize
            archive=truncateArchive(archive)
        end
        selectedParents = selectParents(genj, union(genj._population, archive))
        offspring = cross(genj, selectedParents)
        mutatedOffspring = mutate(genj, offspring)
        evaluate!(genj, mutatedOffspring)
        replacePopulation!(genj, mutatedOffspring)
        archive = getDominant(union(genj._population, archive))
    end

    saveResults(genj)
end # function
precompile(SPEA, tuple(GenJulia, Int64))
export SPEA
