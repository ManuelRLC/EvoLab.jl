"""
    parseGPExperimentInfo(GPExperimentInfoDict::Dict, experiment::GenJulia)

documentation
"""
function parseGPExperimentInfo(type::Type{GEGenotype}, GPInfoDict::Dict, experiment::GenJulia)
    parentModule = experiment._experimentInfo._parentModule
    grammar = get(GPInfoDict, "Grammar", "")
    if typeof(grammar) <: Dict
        N = get(grammar, "N", "")

        if N == ""
            error("Field N of Grammar must be an array containing the non-terminal symbols as strings or a variable containing it")
        elseif typeof(N) <: AbstractString
            try
                aux = parentModule.eval(Meta.parse(N))
            catch e
                error("An string has been introduced for Field N of Grammar and it isn't a defined variable: ", N)
            end
            if !(typeof(aux) <: AbstractArray && eltype(typeof(aux[1])) <: AbstractSring)
                error("Field N of Grammar must be an array containing the non-terminal symbols as strings or a variable containing it")
            end
            N = aux
        elseif typeof(N) <: Array
            if !(typeof(N[1]) <: AbstractString)
                error("Field N of Grammar must be an array containing the non-terminal symbols as strings or a variable containing it")
            end
        else
            error("Field N of Grammar must be an array containing the non-terminal symbols as strings or a variable containing it")
        end

        T = get(grammar, "T", "")
        if T == ""
            error("Field T of Grammar must be an array containing the terminal symbols as strings or a variable containing it")
        elseif typeof(T) <: AbstractString
            try
                aux = parentModule.eval(Meta.parse(T))
            catch e
                error("An string has been introduced for Field T of Grammar and it isn't a defined variable: ", T)
            end
            if !(typeof(aux) <: AbstractArray && eltype(typeof(aux[1])) <: AbstractSring)
                error("Field T of Grammar must be an array containing the terminal symbols as strings or a variable containing it")
            end
            T = aux
        elseif typeof(T) <: Array
            if !(typeof(T[1]) <: AbstractString)
                error("Field T of Grammar must be an array containing the terminal symbols as strings or a variable containing it")
            end
        else
            error("Field T of Grammar must be an array containing the terminal symbols as strings or a variable containing it")
        end

        P = get(grammar, "P", "")
        if P == ""
            error("Field P of Grammar must be an array containing production rules as strings or a variable containing it")
        elseif typeof(P) <: AbstractString
            try
                aux = parentModule.eval(Meta.parse(P))
            catch e
                error("An string has been introduced for Field P of Grammar and it isn't a defined variable: ", P)
            end
            if !(typeof(aux) <: AbstractArray && eltype(typeof(aux[1])) <: AbstractSring)
                error("Field P of Grammar must be an array containing production rules as strings or a variable containing it")
            end
            P = aux
        elseif typeof(P) <: Array
            if !(typeof(P[1]) <: AbstractString)
                eerror("Field P of Grammar must be an array containing production rules as strings or a variable containing it")
            end
        else
            error("Field P of Grammar must be an array containing production rules as strings or a variable containing it")
        end

        S = get(grammar, "S", "")
        if !(typeof(S) <: AbstractString)
            error("Field S of Grammar must be a string")
        end
        if S == ""
            error("Field S of Grammar couldn't be an empty string")
        end
    else
        error("Field Grammar of GPExperimentInfo must be a JSON dictionary and must exist")
    end

    maxProductions = get(GPInfoDict, "maxProductions", false)
    if maxProductions != false
        if typeof(maxProductions) <: String
            try
                aux = parentModule.eval(Meta.parse(maxProductions))
                maxProductions = aux
            catch e
                error("Maximum productions field is not defined: ", maxProductions)
            end
        end

        if !(typeof(maxProductions) <: Integer)
            error("Maximum productions must be an integer number greater than 0: ", maxProductions)
        end
    else
        @warn "Maximum productions not set in a Grammatical Evolution problem, maximum productions will be set to 15, maybe it is not enough for the user grammar."
        maxProductions = 15
    end

    maxDepth = get(GPInfoDict, "maxDepth", false)

    if maxDepth != false
        if typeof(maxDepth) <: String
            try
                aux = parentModule.eval(Meta.parse(maxDepth))
                maxDepth = aux
            catch e
                error("Maximum depth field is not defined: ", maxDepth)
            end
        end

        if !(typeof(maxDepth) <: Integer)
            error("Maximum depth must be an integer number greater than 0 if introduced: ", maxDepth)
        end
    else
        maxDepth = -1
    end



    variables = get(GPInfoDict, "variables", [])

    if typeof(variables) <: AbstractString
        try
            aux = parentModule.eval(Meta.parse(variables))
            variables = aux
        catch e
            error("An string has been introduced for Field variables of GPExperimentInfo and it isn't a defined variable: ", variables)
        end
    end

    if !(typeof(variables) <: Array) || !(typeof(variables[1]) <: AbstractString)
        error("variables field must be an array with identifier of the variables as strings or a variable containing it")
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

    N = convert(Array{String}, N)
    T = convert(Array{String}, T)
    P = convert(Array{String}, P)
    variables = convert(Array{String}, variables)


    setGEInfo(N, T, P, S, variables, varValues...; maxProductions=maxProductions, maxDepth=maxDepth, genj=experiment)
end
