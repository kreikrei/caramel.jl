#Accessors
V(i::String) = vertex_data[][i]
M(m::String) = mode_data[][m]
E(e::Int64) = edge_data[][e]

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
    tripd = M(e.md).dis * haversine(
        [V(e.src).x,V(e.src).y],
        [V(e.dst).x,V(e.dst).y]
    ) / 1000 # dalam km

    return constant + tripd
end

"""
    g(e)
map variable cost of a `lin` based on its `moda`
"""
g(e::lin) = g(M(e.md))

"""
    raw_model_IP(V,E,M,T)
takes in the graph to build a direct mathematical model of the problem.
"""
function raw_model_IP(V_::Dict, E_::Vector, M_::Dict, T_::Vector)
    m = Model(Cbc.Optimizer)

    @variable(m, o[e = E_, t = T_] >= 0, Int) #load variable
    @variable(m, p[e = E_, t = T_] >= 0, Int) #trip variable
    @variable(m, I[i = keys(V_), t = vcat(0, T_)]) #inventory level

    @constraint(m, [i = keys(V_), t = T_],
        I[i, t - 1] + sum(o[e, t] for e in IN(i)) ==
        V_[i].d[t] + sum(o[e, t] for e in OUT(i)) + I[i, t]
    ) #konservasi aliran persediaan

    @constraint(m, [i = keys(V_), t = T_],
        V_[i].MIN <= I[i, t] <= V_[i].MAX
    ) #max min limit of inventory

    @constraint(m, [i = keys(V_)],
        I[i, 0] == V_[i].START
    ) #starting inventory

    @constraint(m, [e = E_, t = T_],
        o[e, t] <= Q(e) * p[e, t]
    ) #muatan trip relation

    @constraint(m, [e = E_, t = T_],
        p[e, t] <= w(e)
    ) #usage limit

    @objective(m, Min,
        sum(f(e) * p[e, t] + g(e) * o[e, t] for e in E_, t in T_)
    )

    return m
end

"""
    raw_model_LP(V,E,M,T)
takes in the graph to build a direct mathematical model of the problem.
"""
function raw_model_LP(V_::Dict, E_::Vector, M_::Dict, T_::Vector)
    m = Model(Clp.Optimizer)

    @variable(m, o[e = E_, t = T_] >= 0) #load variable
    @variable(m, p[e = E_, t = T_] >= 0) #trip variable
    @variable(m, I[i = keys(V_), t = vcat(0, T_)]) #inventory level

    @constraint(m, [i = keys(V_), t = T_],
        I[i, t - 1] + sum(o[e, t] for e in IN(i)) ==
        V_[i].d[t] + sum(o[e, t] for e in OUT(i)) + I[i, t]
    ) #konservasi aliran persediaan

    @constraint(m, [i = keys(V_), t = T_],
        V_[i].MIN <= I[i, t] <= V_[i].MAX
    ) #max min limit of inventory

    @constraint(m, [i = keys(V_)],
        I[i, 0] == V_[i].START
    ) #starting inventory

    @constraint(m, [e = E_, t = T_],
        o[e, t] <= Q(e) * p[e, t]
    ) #muatan trip relation

    @constraint(m, [e = E_, t = T_],
        p[e, t] <= w(e)
    ) #usage limit

    @objective(m, Min,
        sum(f(e) * p[e, t] + g(e) * o[e, t] for e in E_, t in T_)
    )

    return m
end
