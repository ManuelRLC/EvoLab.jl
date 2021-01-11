"""
    parseGPExperimentInfo(GPExperimentInfoDict::Dict, experiment::GenJulia)

documentation
"""
function parseGPExperimentInfo(type::Type{CGPGenotype}, GPInfoDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule
    nodesFile = get(GPInfoDict, "nodesFile", "")
    if !(typeof(nodesFile) <: String)
        error("nodesFile field must be a string with the path of the file containing the information about the nodes")
    end

    maxTreeDepth = get(GPInfoDict, "maxTreeDepth", false)
    if maxTreeDepth != false
        if typeof(maxTreeDepth) <: String
            try
                aux = parentModule.eval(Meta.parse(maxTreeDepth))
                maxTreeDepth = aux
            catch e
                error("Maximum tree depth field is not defined: ", maxTreeDepth)
            end
        end

        if !(typeof(maxTreeDepth) <: Integer)
            error("Maximum tree depth must be an integer number greater than 0: ", maxTreeDepth)
        end
    else
        @warn "Maximum tree depth not set in a Genetic Programming problem, maximum depth will be set to 3 by default"
        maxTreeDepth = 3
    end

    varValues = get(GPInfoDict, "varValues", Array{NamedTuple}(undef, 0))
    if !(typeof(varValues) <: Array)
        error("varValues field must be an array with the arrays of values for each variable of the problem")
    else
        for i=eachindex(varValues)
            try
                arg = Meta.parse(varValues[i])
                varValues[i] = parentModule.eval(arg)
                if !(typeof(varValues[i]) <: Array)
                    error("varValues field must be an array with the arrays of values for each variable of the problem")
                end
            catch e
                error("varValues field must be an array with the arrays of values for each variable of the problem")
            end
        end
    end

    setCGPInfo(varValues..., nodesFile=nodesFile, maxTreeDepth=maxTreeDepth, genj=experiment)
end
