#Accessors
V(i::String) = vertex_data[][i]
M(m::String) = mode_data[][m]
E(e::Int64) = edge_data[][e]

src(e::lin) = e.src
src(e::Int64) = E(e).src

dst(e::lin) = e.dst
dst(e::Int64) = E(e).dst

md(e::lin) = e.md
md(e::Int64) = E(e).md

w(e::lin) = e.w
w(e::Int64) = E(e).w

Q(m::moda) = m.Q
Q(e::lin) = Q(M(e.md))
Q(e::Int64) = Q(E(e))

g(m::moda) = m.var
g(e::lin) = g(M(e.md))
g(e::Int64) = g(E(e))

con(m::moda) = m.con
con(e::lin) = con(M(e.md))
con(e::Int64) = con(E(e))

dis(m::moda) = m.dis
dis(e::lin) = dis(M(e.md))
dis(e::Int64) = dis(E(e))

#filters
IN(i::String) = filter(p -> dst(last(p)) == i, keys(E()))
OUT(i::String) = filter(p -> src(last(p)) == i, keys(E()))

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
f(e::Int64) = f(E(e))

"""
    raw_model_IP(V,E,M,T)
takes in the graph to build a direct mathematical model of the problem.
"""
function raw_model_IP(V_::Dict, E_::Dict, M_::Dict, T_::Vector)
    m = Model(Cbc.Optimizer)

    @variable(m, o[e = keys(E_), t = T_] >= 0, Int) #load variable
    @variable(m, p[e = keys(E_), t = T_] >= 0, Int) #trip variable
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

    @constraint(m, [e = keys(E_), t = T_],
        o[e, t] <= Q(e) * p[e, t]
    ) #muatan trip relation

    @constraint(m, [e = keys(E_), t = T_],
        p[e, t] <= w(e)
    ) #usage limit

    @objective(m, Min,
        sum(f(e) * p[e, t] + g(e) * o[e, t] for e in keys(E_), t in T_)
    )

    return m
end

"""
    raw_model_LP(V,E,M,T)
takes in the graph to build a direct mathematical model of the problem.
"""
function raw_model_LP(V_::Dict, E_::Dict, M_::Dict, T_::Vector)
    m = Model(Clp.Optimizer)

    @variable(m, o[e = keys(E_), t = T_] >= 0) #load variable
    @variable(m, p[e = keys(E_), t = T_] >= 0) #trip variable
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

    @constraint(m, [e = keys(E_), t = T_],
        o[e, t] <= Q(e) * p[e, t]
    ) #muatan trip relation

    @constraint(m, [e = keys(E_), t = T_],
        p[e, t] <= w(e)
    ) #usage limit

    @objective(m, Min,
        sum(f(e) * p[e, t] + g(e) * o[e, t] for e in keys(E_), t in T_)
    )

    return m
end
