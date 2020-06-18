"""
    getPhenotype(tree::GEPGenotype)
documentation
"""
function getPhenotype(tree::GEPGenotype)

    representation = tree._representation
    lenRep = length(representation)

    phenotype = Array{String}(undef, 0)

    visitedFromRoot = zeros(Int64, lenRep, 4)
    visitedFromRoot[:, 1] = fill(-1, lenRep)
    visitedFromRoot[:, 4] = fill(-1, lenRep)
    visitedNodes = Array{Int64}(undef, 0)
    step = getArity(representation[1])
    currLevel = 0
    i = 1
    visitedFromRoot[i, 1] = currLevel

    while step != 0
        currLevel += 1
        i += 1
        currLevelNodes = collect(i:(i+step-1))
        visitedFromRoot[currLevelNodes, 1] = fill(currLevel, step)
        i += step - 1
        step = isempty(currLevelNodes) ? 0 : reduce(+, getArity.(representation[currLevelNodes]))
    end

    i = 1

    while i != 0

        if typeof(representation[i]) <: FunctionNode

            if findfirst(x->x==i, visitedNodes) == nothing
                push!(visitedNodes, i)
                push!(phenotype, getName(representation[i]) * "(")
            end

            if visitedFromRoot[i, 3] < getArity(representation[i])

                if visitedFromRoot[i, 4] == -1
                    prevSameLevel = representation[findprevIndexes(x -> visitedFromRoot[i, 1] == x, visitedFromRoot[:, 1], i-1)]
                    postSameLevel = findnextIndexes(x -> visitedFromRoot[i, 1] == x, visitedFromRoot[:, 1], i+1)
                    visitedFromRoot[i, 4] = isempty(prevSameLevel) ? length(postSameLevel) + 1 : reduce(+, getArity.(prevSameLevel)) + length(postSameLevel) + 1
                end

                parent = i
                i += visitedFromRoot[i, 4] + visitedFromRoot[i, 3]
                visitedFromRoot[i, 2] = parent
            else
                push!(phenotype, "),")
                i = visitedFromRoot[i, 2]
                if i != 0
                    visitedFromRoot[i, 3] += 1
                end
            end
        else

            if typeof(representation[i]) <: VariableNode
                push!(phenotype, getName(representation[i]) * ",")

            elseif typeof(representation[i]) <: ConstantNode
                push!(phenotype, string(getName(representation[i])) * ",")

            elseif typeof(representation[i]) <: NoArgsFunctionNode
                push!(phenotype, getName(representation[i]) * "(),")
            end

            i = visitedFromRoot[i, 2]
            if i != 0
                visitedFromRoot[i, 3] += 1
            end
        end
    end

    phenotype[end] = phenotype[end][1:end-1]

    if length(phenotype) == 1
        phenotype = Meta.parse(phenotype[1])
        return quote $phenotype end
    else
        return Meta.parse(join(phenotype))
    end
end # function
