include("../base.jl")
include("../utils/nodeSetsParser.jl")


function myrandom()
    return rand(["arriba", "abajo", "izquierda", "derecha"])
end

functionset, terminalset = createNodes()
