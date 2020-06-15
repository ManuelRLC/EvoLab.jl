#args = [:(x::Float64), :y, :z];
#args = [:(x::Number)];
args = ["x"];
#exp = :(x+y*z+1)

#exp = :(+(x,+(*(y,z),1)))


args = [:x, :y]
exp3 = "(+(x, y, 1))"


cad = "("
for i in args
    cad = cad*String(i)*", "
end

cad = cad[1:length(cad)-2]
cad = cad*")"

eval(symbol)

valores = [1,2]#collect(-5:0.1:5)

p = cad*" -> "*exp3

h = Meta.parse(p)

println(h)
println(p)
f2 = eval(Meta.parse(p))



funcion = Meta.parse("function")
#println(hola)



#exp = Meta.parse(exp)

#funcion = eval(exp)




exp2 = "+(2,1)"
exp2 = Meta.parse(exp2)

funcion2 = eval(:(function f($(args...)) $exp2 end))

#symbol=:(($(args...)) $exp)

#codigo=:(function f($(args...)) $exp end)


#eval(:(function f($(args...)) $exp end))







valores = [1, 2]#collect(-5:0.1:5)


""""
funcion2(x)=x^2

println(f(2))

#funcion=eval(symbol)

acc = 0

for i=1:length(valores)
    global acc  += (funcion2(valores[i])-f(valores[i]))^2
end
acc /=length(valores)
"""
