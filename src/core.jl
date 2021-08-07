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
IN(i::String) = filter(p -> dst(E(p)) == i, E())
OUT(i::String) = filter(p -> src(E(p)) == i, E())

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
function raw_model_IP(V_::Vector, E_::Vector, M_::Vector, T_::Vector)
    m = Model(Cbc.Optimizer)

    @variable(m, o[e = E_, t = T_] >= 0, Int) #load variable
    @variable(m, p[e = E_, t = T_] >= 0, Int) #trip variable
    @variable(m, I[i = V_, t = vcat(0, T_)]) #inventory level

    @constraint(m, [i = V_, t = T_],
        I[i, t - 1] + sum(o[e, t] for e in IN(i)) ==
        V(i).d[t] + sum(o[e, t] for e in OUT(i)) + I[i, t]
    ) #konservasi aliran persediaan

    @constraint(m, [i = V_, t = T_],
        V(i).MIN <= I[i, t] <= V(i).MAX
    ) #max min limit of inventory

    @constraint(m, [i = V_],
        I[i, 0] == V(i).START
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
function raw_model_LP(V_::Vector, E_::Vector, M_::Vector, T_::Vector)
    m = Model(Clp.Optimizer)

    @variable(m, o[e = E_, t = T_] >= 0) #load variable
    @variable(m, p[e = E_, t = T_] >= 0) #trip variable
    @variable(m, I[i = V_, t = vcat(0, T_)]) #inventory level

    @constraint(m, [i = V_, t = T_],
        I[i, t - 1] + sum(o[e, t] for e in IN(i)) ==
        V(i).d[t] + sum(o[e, t] for e in OUT(i)) + I[i, t]
    ) #konservasi aliran persediaan

    @constraint(m, [i = V_, t = T_],
        V(i).MIN <= I[i, t] <= V(i).MAX
    ) #max min limit of inventory

    @constraint(m, [i = V_],
        I[i, 0] == V(i).START
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
    convert_raw(o, p)
takes `raw_model` solution and turn it into a vector of haul for easy processing in other functions
"""
function convert_raw(o::JuMP.Containers.DenseAxisArray, p::JuMP.Containers.DenseAxisArray)
    res = Vector{haul}()
    for e in E(), t in T()
        if value(o[e,t]) > 0
            push!(res, haul(
                    e, t, value(o[e,t]), value(p[e,t])
                )
            )
        end
    end

    return res
end

"""
    period_view(sol)
takes a vector of haul which is the universal form of solution and turns them into a dictionary of edge loads and trips indexed by periods.
"""
function period_view(sol::Vector{haul})
    res = Dict{Int64,Vector{NamedTuple}}()
    idx = unique([s.t for s in sol])
    for i in idx
        res[i] = Vector{NamedTuple}()
        to_push = filter(p -> p.t == i, sol)
        for r in to_push
            push!(res[i], (e = r.e, o = r.o, p = r.p))
        end
    end

    return res
end

"""
    edge_view(sol)
takes a vector of haul which is the universal form of solution and turns them into a dictionary of edge loads and trips indexed by lins.
"""
function lin_view(sol::Vector{haul})
    res = Dict{Int64,Vector{NamedTuple}}()
    idx = unique([s.e for s in sol])
    for i in idx
        res[i] = Vector{NamedTuple}()
        to_push = filter(p -> p.e == i, sol)
        for r in to_push
            push!(res[i], (t = r.t, o = r.o, p = r.p))
        end
    end

    return res
end
