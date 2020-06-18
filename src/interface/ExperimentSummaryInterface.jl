"""
    setExperimentSummary(genj::GenJulia = GenJ; batchSize::UInt16 = -1)

documentation
"""
function setExperimentSummary(genj::GenJulia = GenJ; batchSize::Integer = 0,
                              printFitness::Bool = true, printBestFitness::Bool = true,
                              printFitnessMean::Bool = true, printFitnessVAR::Bool = true,
                              printDuringExperiment::Bool = false, outputFile::String = "")

    if batchSize < 0
        genj._experimentInfo._experimentSummary = ExperimentSummary()
    else
        if !(isdefined(genj, :_generator))
            error("Generator must be defined first")
        elseif !(isdefined(genj, :_evaluator))
            error("Evaluator must be defined first")
        elseif !(isdefined(genj, :_stopCondition))
            error("StopCondition must be defined first")
        end

        popSize = getPopSize(genj._generator)
        nFitness = getNumberFitness(genj._evaluator)
        hasGlobal = hasGlobalFitnessFunction(genj._evaluator)
        maxIter = getMaxIterations(genj._stopCondition)

        if batchSize == 0
            batchSize = maxIter
        end

        intDiv = div(maxIter, batchSize)

        # Using column-first order for higher performance
        if printFitness
            fitnessValues = Array{Float64}(undef, (nFitness+1, popSize, intDiv))
        else
            fitnessValues = Array{Float64}(undef, 0)
        end

        if printBestFitness
            bestFitnessValues = Array{Float64}(undef, (nFitness+1, intDiv))
            bestIndividuals = Array{Any}(undef, intDiv)
        else
            bestFitnessValues = Array{Float64}(undef, 0)
            bestIndividuals = Array{Any}(undef, 0)
        end

        if printFitnessMean
            meanFitness = Array{Float64}(undef, (nFitness+1, intDiv))
        else
            meanFitness = Array{Float64}(undef, 0)
        end

        if printFitnessVAR
            varFitness = Array{Float64}(undef, (nFitness+1, intDiv))
        else
            varFitness = Array{Float64}(undef, 0)
        end

        GenJ._experimentInfo._experimentSummary = ExperimentSummary(outputFile,
                                                                    batchSize,
                                                                    printDuringExperiment,
                                                                    fitnessValues,
                                                                    bestFitnessValues,
                                                                    meanFitness,
                                                                    varFitness,
                                                                    bestIndividuals,
                                                                    Base.OneTo(nFitness),
                                                                    hasGlobal)
    end

    return nothing
end # function
export setExperimentSummary



"""
    printInformation(genj::GenJulia = GenJ; printFitness::Bool = true,
                     printBestFitness::Bool = true, printMeanFitness::Bool = true,
                     printVARFitness::Bool = true, outputFile::String = "")

Prints all the information of the experiment.
"""
function printInformation(genj::GenJulia = GenJ; printFitness::Bool = true,
                          printBestFitness::Bool = true, printFitnessMean::Bool = true,
                          printFitnessVAR::Bool = true, outputFile::String = "")

    if isdefined(genj._experimentInfo, :_experimentSummary)
        printInformation_(genj._experimentInfo._experimentSummary, printFitness=printFitness,
                          printBestFitness=printBestFitness, printFitnessMean=printFitnessMean,
                          printFitnessVAR=printFitnessVAR, outputFile=outputFile)
    else
        error("The experiment has not been set with an information summary (See \"setExperimentSummary\")")
    end

    return nothing
end # function
export printInformation


"""
    printLastInformation(genj::GenJulia = GenJ, currGen::Integer = 0)

Prints the last bit of information collected of the experiment.
"""
function printLastInformation(genj::GenJulia = GenJ, currGen::Integer = 0)

    if currGen == 0
        currGen = getCurrentIteration(genj._stopCondition)
    end

    printLastInformation_(genj._experimentInfo._experimentSummary, currGen)

    return nothing
end # function
export printLastInformation
