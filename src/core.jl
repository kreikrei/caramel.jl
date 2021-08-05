#Accessors
V(i::String) = vertex_data[][i]
M(m::String) = mode_data[][m]

src(e::lin) = e.src
dst(e::lin) = e.dst
md(e::lin) = e.md
w(e::lin) = e.w

Q(m::moda) = m.Q
Q(e::lin) = Q(M(e.md))
g(m::moda) = m.var
con(m::moda) = m.con
dis(m::moda) = m.dis

#filters
IN(i::String) = filter(p -> dst(p) == i, E())
OUT(i::String) = filter(p -> src(p) == i, E())

#cost functions
"""
    f(e)
function to compute fixed cost of a `lin`.
"""
function f(e::lin)
    constant = M(e.md).con
    tripdist = M(e.md).dis * haversine([V(e.src).x,V(e.src).y], [V(e.dst).x,V(e.dst).y])

    return fixed_cost = constant + tripdist
end

"""
    g(e)
map variable cost of a `lin` based on its `moda`
"""
g(e::lin) = g(M(e.md))

"""
    raw_model(V,E,M,T)
takes in the graph to build a direct mathematical model of the problem.
"""
function raw_model(V::Dict,E::Vector,M::Dict,T::Vector)
    m = Model()

    return m
end
