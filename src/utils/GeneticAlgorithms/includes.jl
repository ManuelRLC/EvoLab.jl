module GA

import ..EvoLab: getDefaultCrossoverOp, getDefaultMutationOp
using ..EvoLab: GAGenotype, Random

include("crossover.jl")

module BinaryGA

import ..GA: uniformCross, getDefaultCrossoverOp, getDefaultMutationOp
using ..GA: GAGenotype, Random

include("BinaryGenotype/includes.jl")

export BinaryGenotype, randomBinaryGenerator, uniformCross, kPointCross,
       singlePointCross, getDefaultCrossoverOp, standardMutation, exchangeMutation,
       scrambleMutation, inversionMutation, insertMutation, getDefaultMutationOp,
       copyGenotype
end # module

module IntegerGA

import ..GA: uniformCross, getDefaultCrossoverOp, getDefaultMutationOp
using ..GA: GAGenotype, Random
using ....EvoLab: randomIndexSelection

include("IntegerGenotype/includes.jl")

export IntegerGenotype, randomIntegerGenerator, uniformCross, kPointCross,
       singlePointCross, getDefaultCrossoverOp, uniformMutation, exchangeMutation,
       scrambleMutation, inversionMutation, insertMutation, getDefaultMutationOp,
       copyGenotype
end # module

end # module
