"""
    printExperimentInfo(outputFile::String = "", genj::GenJulia = GenJ)

Print the information about an experiment.
"""
function printExperimentInfo(outputFile::String = "", genj::GenJulia = GenJ)

    io = outputFile != "" ? open(outputFile, "a") : Base.stdout

    # Experiment Information
    flush(io)
    println(io, "\n\tExperiment information:")
    println(io, "\t\t· Individual Type → $(genj._experimentInfo._individualType)")
    if isdefined(genj._experimentInfo, :_GPExperimentInfo)
        println(io, "\t\t· Genetic Programming Experiment Information:")

        if typeof(genj._experimentInfo._GPExperimentInfo) <: GEInfo
            #verbose para ge
            print(io, "\t\t\t· Variables → ")
            for i=1:(length(genj._experimentInfo._GPExperimentInfo._variables)-1)
                print(io, "$(genj._experimentInfo._GPExperimentInfo._variables[i]), ")
            end
            (length(genj._experimentInfo._GPExperimentInfo._variables) != 0) ? println(io, "$(genj._experimentInfo._GPExperimentInfo._variables[end])") : println(io, "None")
        elseif typeof(genj._experimentInfo._GPExperimentInfo) <: CGPInfo ||
               typeof(genj._experimentInfo._GPExperimentInfo) <: STGPInfo ||
               typeof(genj._experimentInfo._GPExperimentInfo) <: GEPInfo

            println(io, "\t\t\t· Function Set → $(typeof(genj._experimentInfo._GPExperimentInfo._functionSet)) $(size(genj._experimentInfo._GPExperimentInfo._functionSet))")
            println(io, "\t\t\t· Terminal Set → $(typeof(genj._experimentInfo._GPExperimentInfo._terminalSet)) $(size(genj._experimentInfo._GPExperimentInfo._terminalSet))")

            if typeof(genj._experimentInfo._GPExperimentInfo) <: GEPInfo
                println(io, "\t\t\t· Head Size → $(genj._experimentInfo._GPExperimentInfo._head)")
                println(io, "\t\t\t· Tail Size → $(genj._experimentInfo._GPExperimentInfo._tail)")
            else
                println(io, "\t\t\t· Maximum Tree Depth → $(genj._experimentInfo._GPExperimentInfo._maxTreeDepth)")
            end

            print(io, "\t\t\t· Variables → ")
            for i=1:(length(genj._experimentInfo._GPExperimentInfo._variables)-1)
                print(io, "$(genj._experimentInfo._GPExperimentInfo._variables[i]._name), ")
            end
            (length(genj._experimentInfo._GPExperimentInfo._variables) != 0) ? println(io, "$(genj._experimentInfo._GPExperimentInfo._variables[end]._name)") : println(io, "None")
        end
    end
    println(io, "\t\t· Random Seed → $(genj._experimentInfo._randomSeed)")
    print(io, "\t\t· Evolutionary Algorithm → $(genj._experimentInfo._algorithm)(")
    for i=1:length(genj._experimentInfo._algorithmArgs)-1
        print(io, "$(genj._experimentInfo._algorithmArgs[i]), ")
    end
    length(genj._experimentInfo._algorithmArgs) != 0 ? println(io, "$(genj._experimentInfo._algorithmArgs[end]))") : println(io, ")")

    # Stop Conditions
    println(io, "\tStop Conditions:")
    genj._stopCondition._maxEvaluations != -1 && println(io, "\t\t· Maximum Evaluations → $(genj._stopCondition._maxEvaluations)")
    genj._stopCondition._maxIterations != -1 && println(io, "\t\t· Maximum Iterations → $(genj._stopCondition._maxIterations)")
    genj._stopCondition._maxIterNotImproving != -1 && println(io, "\t\t· Maximum Iterations without improving → $(genj._stopCondition._maxIterNotImproving)")
    genj._stopCondition._maxTime != Inf && println(io, "\t\t· Maximum Time → $(genj._stopCondition._maxTime)")

    # Evaluation
    println(io, "\tEvaluation:")
    for ff in genj._evaluator._fitnessFunctions
        println(io, "\t\t· Fitness function → $(ff._fitnessFunction)")
        println(io, "\t\t· Weight → $(ff._weight)")
    end
    if genj._evaluator._globalFitnessFunction._fitnessFunction != _noFunc_
        print(io, "\t\t· Global Fitness Function → $(genj._evaluator._globalFitnessFunction._fitnessFunction)(")
        for i=1:length(genj._evaluator._globalFitnessFunction._varArgs)-1
            print(io, "$(genj._evaluator._globalFitnessFunction._varArgs[i]), ")
        end
        length(genj._evaluator._globalFitnessFunction._varArgs) != 0 ? println(io, "$(genj._evaluator._globalFitnessFunction._varArgs[end]))") : println(io, ")")
    end
    println(io, "\t\t· Comparison Function → $(genj._evaluator._compareFunction)")
    println(io, "\t\t· Fitness Comparison Mode → $(genj._evaluator._compareFunctionArgs)")

    # Generation
    println(io, "\tGeneration:")
    println(io, "\t\t· Population Size → $(genj._generator._popSize)")
    println(io, "\t\t· Individuals Generated One By One → $(genj._generator._generateOneByOne)")
    print(io, "\t\t· Generation Method → $(genj._generator._method)(")
    for i=1:length(genj._generator._varArgs)-1
        print(io, "$(genj._generator._varArgs[i]), ")
    end
    length(genj._generator._varArgs) != 0 ? println(io, "$(genj._generator._varArgs[end]))") : println(io, ")")

    # Selection
    println(io, "\tSelection:")
    print(io, "\t\t· Selection Method → $(genj._selector._method)(")
    for i=1:length(genj._selector._varArgs)-1
        print(io, "$(genj._selector._varArgs[i]), ")
    end
    length(genj._selector._varArgs) != 0 ? println(io, "$(genj._selector._varArgs[end]))") : println(io, ")")
    println(io, typeof(genj._selector._nSelectedParents) == Integer ? "\t\t· # of Selected Parents → $(genj._selector._nSelectedParents)" : "\t\t· # of Selected Parents → $(round(genj._selector._nSelectedParents*100, digits=2))%")
    println(io, "\t\t· Method needs to compare between individuals → $(genj._selector._needsComparison)")
    #genj._selector._needsComparison && println(io, "\t\t· Comparison Mode → $(genj._selector._individualMode)")
    println(io, "\t\t· Sampling with Replacement → $(genj._selector._samplingWithRep)")

    # Crossover
    println(io, "\tCrossover")
    print(io, "\t\t· Crossover Method → $(genj._crossoverOp._method)(")
    for i=1:length(genj._crossoverOp._varArgs)-1
        print(io, "$(genj._crossoverOp._varArgs[i]), ")
    end
    length(genj._crossoverOp._varArgs) != 0 ? println(io, "$(genj._crossoverOp._varArgs[end]))") : println(io, ")")
    println(io, "\t\t· Crossover Probability → $(round(genj._crossoverOp._probability*100, digits=2))%")
    println(io, "\t\t· Number of Parents → $(genj._crossoverOp._nParents)")
    println(io, "\t\t· Number of Children → $(genj._crossoverOp._nChildren)")

    # Mutation
    println(io, "\tMutation")
    print(io, "\t\t· Mutation Method → $(genj._mutationOp._method)(")
    for i=1:length(genj._mutationOp._varArgs)-1
        print(io, "$(genj._mutationOp._varArgs[i]), ")
    end
    length(genj._mutationOp._varArgs) != 0 ? println(io, "$(genj._mutationOp._varArgs[end]))") : println(io, ")")
    println(io, "\t\t· Mutation Probability → $(round(genj._mutationOp._probability*100, digits=2))%")

    # Replacement
    println(io, "\tReplacement:")
    print(io, "\t\t· Replacement Method → $(genj._replacementOp._method)(")
    for i=1:length(genj._replacementOp._varArgs)-1
        print(io, "$(genj._replacementOp._varArgs[i]), ")
    end
    length(genj._replacementOp._varArgs) != 0 ? println(io, "$(genj._replacementOp._varArgs[end]))") : println(io, ")")
    println(io, "\t\t· Method needs to compare between individuals → $(genj._replacementOp._needsComparison)")
    #genj._replacementOp._needsComparison && println(io, "\t\t· Comparison Mode → $(genj._replacementOp._individualMode)")

    io == Base.stdout || close(io)
    return nothing
end # function
