
function a(b::Expr, c::NamedTuple)
    eval(b)

end

precompile(a, tuple(Expr, NamedTuple))
