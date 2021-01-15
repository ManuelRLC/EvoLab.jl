module GA

import ..EvoLab: getDefaultCrossoverOp, getDefaultMutationOp
using ..EvoLab: GAGenotype, Random

include("../miscFunctions.jl")
include("crossover.jl")
include("mutation.jl")

###############
###BinaryGA
###############
module BinaryGA

import ..GA: uniformCross, kPointCross, singlePointCross, getDefaultCrossoverOp, getDefaultMutationOp,
             scrambleMutation, inversionMutation, insertMutation, exchangeMutation, randomIndexSelection
using ..GA: GAGenotype, Random

include("BinaryGenotype/includes.jl")

precompile(uniformCross, tuple(BinaryGenotype, BinaryGenotype, Random.MersenneTwister))
precompile(uniformCross, tuple(BinaryGenotype, BinaryGenotype, Random._GLOBAL_RNG))

export BinaryGenotype, randomBinaryGenerator, uniformCross, kPointCross,
       singlePointCross, getDefaultCrossoverOp, standardMutation, exchangeMutation,
       scrambleMutation, inversionMutation, insertMutation, getDefaultMutationOp,
       copyGenotype
end # module

###############
###IntegerGA
###############
module IntegerGA

###Import section
import ..GA: uniformCross, kPointCross, singlePointCross, getDefaultCrossoverOp, getDefaultMutationOp,
             scrambleMutation, inversionMutation, insertMutation, exchangeMutation
using ..GA: GAGenotype, Random
using ....EvoLab: randomIndexSelection

###Code
include("IntegerGenotype/includes.jl")

###Export
export IntegerGenotype, randomIntegerGenerator, uniformCross, kPointCross,
       singlePointCross, getDefaultCrossoverOp, uniformMutation, exchangeMutation,
       scrambleMutation, inversionMutation, insertMutation, getDefaultMutationOp,
       copyGenotype
end # module


###############
###RealGA
###############
module RealGA

###Import section
import ..GA: uniformCross, kPointCross, singlePointCross, getDefaultCrossoverOp, getDefaultMutationOp,
             scrambleMutation, inversionMutation, insertMutation, exchangeMutation
using ..GA: GAGenotype, Random
using ....EvoLab: randomIndexSelection

###Code
include("RealGenotype/includes.jl")

###Export
export RealGenotype, randomRealGenerator, BLXAlpha, uniformCross, kPointCross,
       singlePointCross, getDefaultCrossoverOp, uniformMutation, exchangeMutation,
       scrambleMutation, inversionMutation, insertMutation, getDefaultMutationOp,
       copyGenotype
end # module

end # module
