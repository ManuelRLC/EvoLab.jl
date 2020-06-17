"
Store information about the population throughout the generations. The user
chooses what information will be stored and displayed and wether it will be
displayed during the experiment or at the end of it.

# Fields
- `_outputFile::String`: the output file in which the results will be dumped.
    If not set, the results will be displayed in the REPL.
- `_batchSize::Int16`: size of the batch of generations for results collecting.
    If it is set to 3, the system will collect the information of the population
    each three generations. If it is set to 0, the system will collect the
    information of the last generation of the experiment. If it is set to -1 or
    below, the system will not collect any information.
- `_printDuringExperiment::Bool`: wether to display the information during the
    experiment or not.
- `_fitnessValues::Array{Float64}`: array to store the fitness values of the
    individuals of the population throughout the generations.
- `_bestFitnessValues::Array{Float64}`: array to store the fitness values of the
    best individuals of the population throughout the generations.
- `_meanFitness::Array{Float64}`: array to store the means of the fitness values
    of the individuals of the population throughout the generations.
- `_stdFitness::Array{Float64}`: array to store the standard deviation of the
    fitness values of the individuals of the population throughout the generations.
- `_bestIndividuals::Array{Any}`: array to store the representations and phenotypes
    of the best individuals of the population throughout the generations.
- `_indexes::Base.OneTo`: indexes of the fitness values that are not global.
- `_global::Bool`: whether there is a global fitness or not.

See also: [`setExperimentSummary`](@ref)
"
struct ExperimentSummary
    _outputFile::String
    _batchSize::Int16
    _printDuringExperiment::Bool

    _fitnessValues::Array{Float64}
    _bestFitnessValues::Array{Float64}
    _meanFitness::Array{Float64}
    _varFitness::Array{Float64}
    _bestIndividuals::Array{Any}

    _indexes::Base.OneTo
    _global::Bool

    ExperimentSummary() = new("", -1, false, Array{Float64}(undef, 0),
                        Array{Float64}(undef, 0), Array{Float64}(undef, 0),
                        Array{Float64}(undef, 0), Array{Any}(undef, 0),
                        Base.OneTo(0), false)

    ExperimentSummary(outputFile::String, batchSize::Int, printDuringExperiment::Bool,
                      fitnessValues::Array{Float64}, bestFitnessValues::Array{Float64},
                      meanFitness::Array{Float64}, varFitness::Array{Float64},
                      bestIndividual::Array{Any}, indexes::Base.OneTo, glob::Bool) =
                          new(outputFile, batchSize, printDuringExperiment,
                          fitnessValues, bestFitnessValues, meanFitness,
                          varFitness, bestIndividual, indexes, glob)

end # struct



"""
    getOutputFile(summary::ExperimentSummary)::String

Obtains the output file for the experiment summary.
"""
getOutputFile(summary::ExperimentSummary)::String = summary._outputFile
# function



"""
    getBatchSize(summary::ExperimentSummary)::Int16

Obtains the batch size for results collection.
"""
getBatchSize(summary::ExperimentSummary)::Int16 = summary._batchSize
# function



"""
    printDuringExperiment(summary::ExperimentSummary)::Bool

Checks if printing during the experiment is enabled.
"""
printDuringExperiment(summary::ExperimentSummary)::Bool = summary._printDuringExperiment
# function



"""
    displayFitness(summary::ExperimentSummary)::Bool

Checks if the user wants to display the fitness values of the individuals
throughout the generations.
"""
displayFitness(summary::ExperimentSummary)::Bool = !(isempty(summary._fitnessValues))
# function



"""
    displayBestFitness(summary::ExperimentSummary)::Bool

Checks if the user wants to display the best fitness values of the individuals
throughout the generations.
"""
displayBestFitness(summary::ExperimentSummary)::Bool = !(isempty(summary._bestFitnessValues))
# function



"""
    displayMeanFitness(summary::ExperimentSummary)::Bool

Checks if the user wants to display the mean of the fitness values of the individuals
throughout the generations.
"""
displayMeanFitness(summary::ExperimentSummary)::Bool = !(isempty(summary._meanFitness))
# function



"""
    displaySTDFitness(summary::ExperimentSummary)::Bool

Checks if the user wants to display the standard deviation of the fitness values
of the individuals throughout the generations.
"""
displayVARFitness(summary::ExperimentSummary) = !(isempty(summary._varFitness))
# function



"""
    somethingToDisplay(summary::ExperimentSummary)::Bool

Checks if there is something to display from the summary.
"""
function somethingToDisplay(summary::ExperimentSummary)::Bool
    return getBatchSize(summary) >= 0 && (displayFitness(summary) ||
           displayBestFitness(summary) || displayMeanFitness(summary) ||
           displayVARFitness(summary))
end # function



"""
    anyToDisplay(summary::ExperimentSummary)::Array{Float64}

Returns the first thing that can be displayed.
"""
function displayAnything(summary::ExperimentSummary)::Array{Float64}
    if displayFitness(summary)
        return summary._fitnessValues
    elseif displayBestFitness(summary)
        return summary._bestFitnessValues
    elseif displayMeanFitness(summary)
        return summary._meanFitness
    elseif displayVARFitness(summary)
        return summary._stdFitness
    end
end # function




"""
    saveFitness(summary::ExperimentSummary, fitnesses::Array{Float64},
                currIter::Int, globalFitnesses::Array{Float64})

Saves the fitness values of the individuals of a generation.
"""
function saveFitness(summary::ExperimentSummary, fitnesses::Array{Float64},
                     currIter::Int, globalFitnesses::Array{Float64})

    index = div(currIter, getBatchSize(summary))
    summary._fitnessValues[summary._indexes, :, index] = fitnesses
    summary._fitnessValues[end, :, index] = globalFitnesses

    return nothing
end # function



"""
    saveBestFitness(summary::ExperimentSummary, bestFitness::Array{Float64},
                    representation::Union{Array,Expr}, currIter::Integer,
                    bestGlobalFitness::Float64 = NaN)

Saves the best fitness values of a generation.
"""
function saveBestFitness(summary::ExperimentSummary, bestFitness::Array{Float64},
                         representation::Union{Array,Expr}, currIter::Integer,
                         bestGlobalFitness::Float64 = NaN)

    index = div(currIter, getBatchSize(summary))
    summary._bestFitnessValues[summary._indexes, index] = bestFitness
    summary._bestFitnessValues[end, index] = bestGlobalFitness
    summary._bestIndividuals[index] = representation

    return nothing
end # function



"""
    saveMeanFitness(summary::ExperimentSummary, fitness::Array{Float64},
                    currIter::Integer, globalFitnesses::Array{Float64})

Saves the mean of fitness values of the individuals of a generation.
"""
function saveMeanFitness(summary::ExperimentSummary, fitness::Array{Float64},
                         currIter::Integer, globalFitnesses::Array{Float64})

    index = div(currIter, getBatchSize(summary))
    summary._meanFitness[summary._indexes, index] = Statistics.mean(fitness, dims = 2)
    summary._meanFitness[end, index] = Statistics.mean(globalFitnesses)

    return nothing
end # function



"""
    saveVARFitness(summary::ExperimentSummary, fitness::Array{Float64},
                   currIter::Integer, globalFitnesses::Array{Float64})

Saves the variance of fitness values of the individuals of a generation.
"""
function saveVARFitness(summary::ExperimentSummary, fitness::Array{Float64},
                        currIter::Integer, globalFitnesses::Array{Float64})

    index = div(currIter, getBatchSize(summary))

    if displayMeanFitness(summary)
        summary._varFitness[summary._indexes, index] =
                                    Statistics.varm(fitness, summary._meanFitness[summary._indexes, index], dims=2)
        summary._varFitness[end, index] = Statistics.varm(globalFitnesses, summary._meanFitness[end, index])
    else

        summary._varFitness[summary._indexes, index] = Statistics.var(fitness, dims=2)
        summary._varFitness[end, index] = Statistics.var(globalFitnesses)
    end

    return nothing
end # function




"""
    displayInformation_(summary::ExperimentSummary; displayFitness::Bool = true,
                      displayBestFitness::Bool = true, displayMeanFitness::Bool = true,
                      displayVARFitness::Bool = true, outputFile::String = "")

displays all the information in the summary.
"""
function printInformation_(summary::ExperimentSummary; printFitness::Bool = true,
                                     printBestFitness::Bool = true, printFitnessMean::Bool = true,
                                     printFitnessVAR::Bool = true, outputFile::String = "")

    if somethingToDisplay(summary) && (printFitness || printBestFitness ||
        printFitnessMean || printFitnessVAR)

        if outputFile == ""
            outputFile = getOutputFile(summary)
        elseif outputFile == "Base.stdout"
            outputFile = ""
        end
        io = outputFile != "" ? open(outputFile, "a") : Base.stdout
        flush(io)

        batchSize = getBatchSize(summary)
        anyDisplayable = displayAnything(summary)
        nGens = axes(anyDisplayable)[end]

        for gen = nGens
            println(io, "GENERATION ", batchSize * gen, ":")
            println(io)

            if displayFitness(summary) && printFitness
                println(io, "  RESULTS OF ALL THE INDIVIDUALS")
                println(io, "  ------------------------------")
                indexes = axes(summary._fitnessValues)
                # For each individual
                for ind = indexes[2]

                    println(io, "\tIndividual ", ind, ": ")
                    # For each fitness
                    for fit = summary._indexes
                        println(io, "\t  Fitness Value ", fit, ": ", summary._fitnessValues[fit, ind, gen])
                    end
                    if summary._global
                        println(io, "\t  Global Fitness Value: ", summary._fitnessValues[end, ind, gen])
                    end
                    println(io)

                end

                println(io)
            end


            if displayBestFitness(summary) && printBestFitness
                println(io, "  RESULTS OF THE BEST INDIVIDUAL")
                println(io, "  ------------------------------")

                # For each fitness
                for fit = summary._indexes
                    println(io, "\tFitness Value", fit, " of the Best Individual: ", summary._bestFitnessValues[fit, gen])
                end
                if summary._global
                    println(io, "\tGlobal Fitness Value of the Best Individual: ", summary._bestFitnessValues[end, gen])
                end
                println(io, "\tBest Individual: ", summary._bestIndividuals[gen])
                println(io)
            end

            if displayMeanFitness(summary) && printFitnessMean
                println(io, "  MEAN OF THE RESULTS")
                println(io, "  -------------------")
                for fit = summary._indexes
                    println(io, "\tMean of Fitness ", fit, ": ", summary._meanFitness[fit, gen])
                end
                if summary._global
                    println(io, "\tMean of Global Fitness: ", summary._meanFitness[end, currGeneration])
                end
                println(io)
            end

            if displayVARFitness(summary) && printFitnessVAR
                println(io, "  VARIANCE OF THE RESULTS")
                println(io, "  ---------------------------------")
                for fit = summary._indexes
                    println(io, "\tVariance of Fitness ", fit, ": ", summary._varFitness[fit, gen])
                end
                if summary._global
                    println(io, "\ttVariance of Global Fitness: ", summary._varFitness[end, gen])
                end
                println(io)
            end

            println(io, "============================")
            println(io)
            println(io)

            io == Base.stdout || close(io)
        end
    elseif !(somethingToDisplay(summary))
        println("Nothing to display! Set the information that you want to display by calling setExperimentSummary function")
    else
        println("Nothing to display!")
    end

    return nothing
end # function



"""
    printLastInformation_(summary::ExperimentSummary, currGeneration::Integer)

Prints the last bit of information collected of the summary.
"""
function printLastInformation_(summary::ExperimentSummary, currGeneration::Integer)

    if somethingToDisplay(summary)

        outputFile = getOutputFile(summary)
        io = outputFile != "" ? open(outputFile, "a") : Base.stdout
        flush(io)
        currGeneration = div(currGeneration, getBatchSize(summary))

        if displayFitness(summary)
            println(io, "  RESULTS OF ALL THE INDIVIDUALS")
            println(io, "  ------------------------------")
            indexes = axes(summary._fitnessValues)
            # For each individual
            for ind = indexes[2]

                println(io, "\tIndividual ", ind, ": ")
                # For each fitness
                for fit = summary._indexes
                    println(io, "\t  Fitness Value ", fit, ": ", summary._fitnessValues[fit, ind, currGeneration])
                end
                if summary._global
                    println(io, "\t  Global Fitness Value: ", summary._fitnessValues[end, ind, currGeneration])
                end
                println(io)

            end

            println(io)
        end

        if displayBestFitness(summary)
            println(io, "  RESULTS OF THE BEST INDIVIDUAL")
            println(io, "  ------------------------------")

            # For each fitness
            for fit = summary._indexes
                println(io, "\tFitness Value", fit, " of the Best Individual: ", summary._bestFitnessValues[fit, currGeneration])
            end
            if summary._global
                println(io, "\tGlobal Fitness Value of the Best Individual: ", summary._bestFitnessValues[end, currGeneration])
            end
            println(io, "\tBest Individual: ", summary._bestIndividuals[currGeneration])
            println(io)
        end

        if displayMeanFitness(summary)
            println(io, "  MEAN OF THE RESULTS")
            println(io, "  -------------------")
            for fit = summary._indexes
                println(io, "\tMean of Fitness ", fit, ": ", summary._meanFitness[fit, currGeneration])
            end
            if summary._global
                println(io, "\tMean of Global Fitness: ", summary._meanFitness[end, currGeneration])
            end
            println(io)
        end

        if displayVARFitness(summary)
            println(io, "  VARIANCE OF THE RESULTS")
            println(io, "  ---------------------------------")
            for fit = summary._indexes
                println(io, "\tVariance of Fitness ", fit, ": ", summary._varFitness[fit, currGeneration])
            end
            if summary._global
                println(io, "\ttVariance of Global Fitness: ", summary._varFitness[end, currGeneration])
            end
            println(io)
        end

        io == Base.stdout || close(io)
    end

    return nothing
end # function
