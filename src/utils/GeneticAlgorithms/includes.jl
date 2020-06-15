module GA

import ..EvoLab: getDefaultCrossoverOp, getDefaultMutationOp
using ..EvoLab: GAGenotype, Random

include("crossover.jl")

###############
###BinaryGA
###############
module BinaryGA

import ..GA: uniformCross, getDefaultCrossoverOp, getDefaultMutationOp
using ..GA: GAGenotype, Random

include("BinaryGenotype/includes.jl")

println("uniformBinary:", precompile(uniformCross, tuple(BinaryGenotype, BinaryGenotype, Random.MersenneTwister)))
println("uniformBinary:", precompile(uniformCross, tuple(BinaryGenotype, BinaryGenotype, Random._GLOBAL_RNG)))

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
import ..GA: uniformCross, getDefaultCrossoverOp, getDefaultMutationOp
using ..GA: GAGenotype, Random
using ....EvoLab: randomIndexSelection

###Code
include("IntegerGenotype/includes.jl")

println("uniformInt:", precompile(uniformCross, tuple(IntegerGenotype, IntegerGenotype, Random.MersenneTwister)))
println("uniformInt:", precompile(uniformCross, tuple(IntegerGenotype, IntegerGenotype, Random._GLOBAL_RNG)))
###Export
export IntegerGenotype, randomIntegerGenerator, uniformCross, kPointCross,
       singlePointCross, getDefaultCrossoverOp, uniformMutation, exchangeMutation,
       scrambleMutation, inversionMutation, insertMutation, getDefaultMutationOp,
       copyGenotype
end # module

end # module
