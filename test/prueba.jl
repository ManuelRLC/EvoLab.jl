module A

    hola() = println("hola")

    module GenJulia
        holaB() = D.eval(:holaD)()
        f(m) = m.eval(:(5+2))
        export holaB, f

        module C

            holaC() = Main.eval(:B)
        end
    end

end

module D
    using ..A.GenJulia

    holaD() = println("holaD")

    println(f(D))
end






using .A.B
A.B.C.holaC()
