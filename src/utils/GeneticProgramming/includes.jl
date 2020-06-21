module GP

using ..EvoLab: GPGenotype, Random, JSON, GenJulia, GenJ, GPExperimentInfo, setGPExperimentInfo
import ..EvoLab: parseGPExperimentInfo, getDefaultCrossoverOp, getDefaultMutationOp,
                 getRepresentation

include("nodes.jl")
include("nodeSetsParser.jl")
include("evaluation.jl")
include("initialization.jl")
include("crossover.jl")
include("mutation.jl")
include("miscTreeFunctions.jl")

export evalPhenotype, chooseAnotherNode

module CGP
import ..GP: parseGPExperimentInfo, getDefaultCrossoverOp, getDefaultMutationOp,
             growGenerator, fullGenerator, rampedHalfHalfGenerator, getPhenotype,
             onePointCross, oneChildSubtreeCross, subtreeCross, onePointMutation,
             pointMutation, subtreeMutation, getRepresentation
using ..GP: GenJulia, GenJ, GPExperimentInfo, setGPExperimentInfo,
            GPGenotype, Random, Node, FunctionNode, TerminalNode, VariableNode, ConstantNode,
            NoArgsFunctionNode, getName, getType, getArity, createNodes,
            evalPhenotype, chooseAnotherNode, compareFunctions

include("Canonical/includes.jl")

precompile(compareFunctions, tuple(CGPGenotype, CGPInfo, Vector{Float64}))

export CGPGenotype, CGPInfo, getPhenotype, compareFunctions, onePointCross,
       oneChildSubtreeCross, subtreeCross, getDefaultCrossoverOp, growGenerator,
       fullGenerator, rampedHalfHalfGenerator, onePointMutation, pointMutation,
       subtreeMutation, getDefaultMutationOp, copyGenotype, parseGPExperimentInfo,
       evalPhenotype, getRepresentation
end # module

module STGP

import ..GP: parseGPExperimentInfo, getDefaultCrossoverOp, getDefaultMutationOp,
             growGenerator, fullGenerator, rampedHalfHalfGenerator, getPhenotype,
             onePointCross, oneChildSubtreeCross, subtreeCross, onePointMutation,
             pointMutation, subtreeMutation, getRepresentation
using ..GP: GenJulia, GenJ, GPExperimentInfo, setGPExperimentInfo,
            GPGenotype, Random, Node, FunctionNode, TerminalNode, VariableNode, ConstantNode,
            NoArgsFunctionNode, getName, getType, getArity, createNodes,
            evalPhenotype, chooseAnotherNode, compareFunctions

include("StronglyTyped/includes.jl")

precompile(compareFunctions, tuple(STGPGenotype, STGPInfo, Vector{Float64}))

export STGPGenotype, STGPInfo, getPhenotype, compareFunctions, onePointCross,
       oneChildSubtreeCross, subtreeCross, getDefaultCrossoverOp, growGenerator,
       fullGenerator, rampedHalfHalfGenerator, onePointMutation, pointMutation,
       subtreeMutation, copyGenotype, parseGPExperimentInfo, evalPhenotype,
       getRepresentation
end # module

module GEP

import ..GP: parseGPExperimentInfo, getDefaultCrossoverOp, getDefaultMutationOp,
             growGenerator, fullGenerator, rampedHalfHalfGenerator, getPhenotype,
             getRepresentation
using ..GP: GenJulia, GenJ, GPExperimentInfo, setGPExperimentInfo,
            GPGenotype, Random, Node, FunctionNode, TerminalNode, VariableNode, ConstantNode,
            NoArgsFunctionNode, getName, getType, getArity, createNodes,
            evalPhenotype, compareFunctions
using ....EvoLab: findprevIndexes, findnextIndexes

include("GeneExpressionProgramming/includes.jl")

precompile(compareFunctions, tuple(GEPGenotype, GEPInfo, Vector{Float64}))

export GEPGenotype, GEPInfo, getPhenotype, compareFunctions, growGenerator,
       fullGenerator, rampedHalfHalfGenerator, kPointRecombinationCross,
       getDefaultCrossoverOp, onePointRecombinationCross, geneMutation,
       copyGenotype, parseGPExperimentInfo, evalPhenotype, getRepresentation
end # module

module GE

import ..GP: parseGPExperimentInfo, getDefaultCrossoverOp, getDefaultMutationOp,
             growGenerator, fullGenerator, rampedHalfHalfGenerator, getPhenotype,
             compareFunctions, getRepresentation
using ..GP: GenJulia, GenJ, GPExperimentInfo, setGPExperimentInfo,
            GPGenotype, Random, evalPhenotype
using ....EvoLab.GA.IntegerGA

include("GrammaticalEvolution/includes.jl")

precompile(compareFunctions, tuple(GEGenotype, GEInfo, Vector{Float64}))

export printTree, GEGenotype, GEInfo, copyGenotype, proteinCross, proteinCrossGrow,
       getPhenotype, compareFunctions, growGenerator, fullGenerator, generateTree,
       rampedHalfHalfGenerator, proteinMutation, proteinMutationGrow,
       getDefaultCrossoverOp, setGEInfo, evalPhenotype, getRepresentation
end # module

end # module
