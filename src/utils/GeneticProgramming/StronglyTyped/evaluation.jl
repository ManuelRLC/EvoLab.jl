"""
    getPhenotype(tree::STGPGenotype)

Obtains the phenotype of a given STGP genotype as an evaluable expresion (See [`Expr`](@ref)).

# Arguments
- `genotype::CGPGenotype`: genotype of the individual from which the phenotype is
    wanted.

# Returns
The phenotype of the individual as `Expr`.

See also: [`evaluate`](@ref)
"""
function getPhenotype(genotype::STGPGenotype)
    phenotype = Array{String}(undef, 0)
    representation = genotype._representation
    visitedFromRoot = Array{Int64}(undef, 0, 2)

    nodeIndex = 1
    parent = 0

    while nodeIndex != 0

        if nodeIndex > size(visitedFromRoot)[1]
            visitedFromRoot = vcat(visitedFromRoot, zeros(Int64, 1, 2))
            visitedFromRoot[end, 2] = parent

            if typeof(representation[nodeIndex]) <: TerminalNode

                if typeof(representation[nodeIndex]) <: VariableNode
                    push!(phenotype, getName(representation[nodeIndex]) * ",")

                elseif typeof(representation[nodeIndex]) <: ConstantNode
                    push!(phenotype, string(getName(representation[nodeIndex])) * ",")

                elseif typeof(representation[nodeIndex]) <: NoArgsFunctionNode
                    push!(phenotype, getName(representation[nodeIndex]) * "(),")
                end

            else typeof(representation[nodeIndex]) <: FunctionNode
                push!(phenotype, getName(representation[nodeIndex]) * "(")
            end
        end

        if visitedFromRoot[nodeIndex, 1] < getArity(representation[nodeIndex])
            parent = nodeIndex
            nodeIndex = size(visitedFromRoot)[1] + 1
        else
            if typeof(representation[nodeIndex]) <: FunctionNode
                push!(phenotype, "),")
            end
            nodeIndex = visitedFromRoot[nodeIndex, 2]
            if nodeIndex != 0
                visitedFromRoot[nodeIndex, 1] += 1
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



"""
    getRepresentation(genotype::STGPGenotype)

documentation
"""
getRepresentation(genotype::STGPGenotype) = getPhenotype(genotype)
# function
