"""
    parseGPExperimentInfo(GPExperimentInfoDict::Dict, experiment::GenJulia)

documentation
"""
function parseGPExperimentInfo(type::Type{GEPGenotype}, GEPInfoDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule
    nodesFile = get(GEPInfoDict, "nodesFile", "")
    if !(typeof(nodesFile) <: String)
        error("nodesFile field must be a string with the path of the file containing the information about the nodes")
    end

    head = get(GEPInfoDict, "head", false)
    if head != false
        if typeof(head) <: String
            try
                aux = parentModule.eval(Meta.parse(head))
                head = aux
            catch e
                error("Head field is not defined: ", head)
            end
        end

        if !(typeof(head) <: Integer)
            error("Head must be an integer number greater than 0: ", head)
        end
    else
        @warn "head field not set in a GEP problem, head length will be set to 7 by default"
        head = 7
    end

    varValues = get(GEPInfoDict, "varValues", Array{NamedTuple}(undef, 0))
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

    setGEPInfo(varValues..., nodesFile=nodesFile, head=head, genj=experiment)
end
