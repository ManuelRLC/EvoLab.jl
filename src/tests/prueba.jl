

#using .GeneticJulia
import Random
rng = Random.MersenneTwister(1234)
include("../utils/miscFunctions.jl")

a="hola"
module A

    func() = println("modulo A")

@noinline function sergioFunction()
    for i=1:1000
        5+3^2012/231*123
    end
end


"""
    sergioFunction2(a::Array{Float64})

!!! warning
    For testing, don't use.

!!! danger
    Don't use
!!! tip
    Pista

!!! dang
    dont
"""
@noinline function sergioFunction2(a::Array{Float64})
    for i=1:1000
        5+3^2012/231*123
    end
end

a=precompile(sergioFunction2,tuple(Vector{<:Number}))


"""
function modify(array)
    array[1]=20
    5
end

a = [1,2,3,4,5]
"""

"""
mutable struct myStruct
    a
end
function prueba(a)
    a.a=5
end

b = myStruct(9)
prueba(b)

println(b)
"""




"""

function argum(p=3;varargs...)
    return varargs
end


a = argum(x=5, y=6, b=10, c=15, j=20, l=16, p=10)

println(a[:c])
"""


function probar1(iteraciones)

    for i=1:iteraciones

        sergioFunction()
        #randomIndexSelection2(829,243,rng)
    end

end




function probar2(iteraciones)

    for i=1:iteraciones
        sergioFunction2()
    end

end


@timev probar1(10000)

@timev probar2(10000)




"""
a = randn(10000)

@noinline function probar1(iteraciones)

    for i = 1:iteraciones
        len = length(a)
        b = Array{Float64}(undef, len)
        for i=1:len
            i^253+3451/12312.23251+ 953.2235*sqrt(exp(i))
            b[i] = a[i]
        end
        #randomIndexSelection2(829,243,rng)
    end

end

@noinline function probar2(iteraciones)

    for i = 1:iteraciones
        b = similar(Array{Float64}, axes(a))
        for i in eachindex(b)
            i^253+3451/12312.23251+ 953.2235*sqrt(exp(i))
            b[i] = a[i]
        end
        #randomIndexSelection2(829,243,rng)
    end

end


@time probar1(10000)
@time probar2(10000)

"""

"""
rng = Random.MersenneTwister(2)
rng2 = Random.MersenneTwister(2)

function prueba(rng::Random.MersenneTwister)
    rand(rng)
end

function prueba1(iteraciones)
    for i=1:iteraciones
        rng3=copy(rng)
    end
end

function prueba2(iteraciones)
    for i=1:iteraciones
        a=Random.MersenneTwister(5)
    end
end


@time prueba1(10000)
@time prueba2(10000)

rng = Random.MersenneTwister(2)
rng2 = Random.MersenneTwister(2)


rng2 = copy(rng)

println(rand(rng))
rng3 = copy(rng)
"""


"""
println("===================")

for i=1:15
    println(rand(rng2))
end

ncores = 4


println()

rngs=Array{Random.MersenneTwister}(undef, 4)

for i=1:4
    rngs[i] = copy(rng)
end


randoms = Threads.@threads for i=1:ncores
    println(prueba(rngs[i]))
end

#println(randoms)


Threads.@threads for N in 1:5:20
    println("The number of this iteration is N")
end


job = Distributed.@spawn prueba(rng)

println(job)
println(fetch(job))
"""
