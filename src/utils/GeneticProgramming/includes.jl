module GP

using ..EvoLab: GPGenotype, Random, JSON, GenJulia, GenJ, GPExperimentInfo, setGPExperimentInfo
import ..EvoLab: parseGPExperimentInfo, getDefaultCrossoverOp, getDefaultMutationOp

include("nodes.jl")
include("nodeSetsParser.jl")
include("evaluation.jl")

export evalPhenotype

module CGP

import ..GP: parseGPExperimentInfo, getDefaultCrossoverOp, getDefaultMutationOp
using ..GP: GenJulia, GenJ, GPExperimentInfo, setGPExperimentInfo,
            GPGenotype, Random, Node, FunctionNode, TerminalNode, VariableNode, ConstantNode,
            NoArgsFunctionNode, getName, getType, getArity, createNodes,
            evalPhenotype

include("miscTreeFunctions.jl")
include("Canonical/includes.jl")

export CGPGenotype, CGPInfo, getPhenotype, compareFunctions, onePointCross,
       oneChildSubtreeCross, subtreeCross, getDefaultCrossoverOp, growGenerator,
       fullGenerator, rampedHalfHalfGenerator, onePointMutation, pointMutation,
       subtreeMutation, getDefaultMutationOp, copyGenotype, parseGPExperimentInfo,
       evalPhenotype
end # module

module STGP

import ..GP: parseGPExperimentInfo, getDefaultCrossoverOp, getDefaultMutationOp
using ..GP: GenJulia, GenJ, GPExperimentInfo, setGPExperimentInfo,
            GPGenotype, Random, Node, FunctionNode, TerminalNode, VariableNode, ConstantNode,
            NoArgsFunctionNode, getName, getType, getArity, createNodes,
            evalPhenotype

include("miscTreeFunctions.jl")
include("StronglyTyped/includes.jl")

export STGPGenotype, STGPInfo, getPhenotype, compareFunctions, onePointCross,
       oneChildSubtreeCross, subtreeCross, getDefaultCrossoverOp, growGenerator,
       fullGenerator, rampedHalfHalfGenerator, onePointMutation, pointMutation,
       subtreeMutation, copyGenotype, parseGPExperimentInfo, evalPhenotype
end # module

module GEP

import ..GP: parseGPExperimentInfo, getDefaultCrossoverOp, getDefaultMutationOp
using ..GP: GenJulia, GenJ, GPExperimentInfo, setGPExperimentInfo,
            GPGenotype, Random, Node, FunctionNode, TerminalNode, VariableNode, ConstantNode,
            NoArgsFunctionNode, getName, getType, getArity, createNodes,
            evalPhenotype
using ....EvoLab: findprevIndexes, findnextIndexes

include("miscTreeFunctions.jl")
include("GeneExpressionProgramming/includes.jl")

export GEPGenotype, GEPInfo, getPhenotype, compareFunctions, growGenerator,
       fullGenerator, rampedHalfHalfGenerator, kPointRecombinationCross,
       getDefaultCrossoverOp, onePointRecombinationCross, geneMutation,
       copyGenotype, parseGPExperimentInfo, evalPhenotype
end # module

module GE

import ..GP: parseGPExperimentInfo, getDefaultCrossoverOp, getDefaultMutationOp
using ..GP: GenJulia, GenJ, GPExperimentInfo, setGPExperimentInfo,
            GPGenotype, Random, evalPhenotype
using ....EvoLab.GA.IntegerGA

include("GrammaticalEvolution/includes.jl")

export printTree, GEGenotype, GEInfo, copyGenotype, proteinCross, proteinCrossGrow,
       getPhenotype, compareFunctions, growGenerator, fullGenerator, generateTree,
       rampedHalfHalfGenerator, proteinMutation, proteinMutationGrow,
       getDefaultCrossoverOp, setGEInfo, evalPhenotype
end # module

end # module
