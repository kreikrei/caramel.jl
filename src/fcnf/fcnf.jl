struct Node
    loc::Integer
    per::Integer
end

struct Mode
    Q::Integer
    con::Real
    dis::Real
    var::Real
end

struct Arc
    ori::Node #origin
    dst::Node #destination
    md::Mode #mode
end

#Accessors for AbstractArc and its sub
ori(a::Arc) = a.ori
dst(a::Arc) = a.dst
md(a::Arc) = a.md

struct Commodity
    src::Node #source
    snk::Node #sink
    ld::Integer #load
end

#Accessors for Commodities
src(k::Commodity) = k.src
snk(k::Commodity) = k.snk
ld(k::Commodity) = k.d

"""
    δ(n, k)
maps if n is 0 (intermediate node), 1 (source node), or -1 (sink node)
"""
function δ(n::Node, k::Commodity)
    a = (src(k) == n)
    b = -(snk(k) == n)

    return a + b
end

"""
    arc_fcnf(N,A,K)
builds the arc formulation of the fixed charge network flow (FCNF). The inputs are dictionaries and contains its iterators and all the information.
"""
function arc_fcnf(N::Vector{Node}, A::Vector{Arc}, K::Vector{Commodity})
    m = Model()

    @variable(m, 0 <= x[a = eachindex(A), k = eachindex(K)] <= 1)
    @variable(m, y[a = eachindex(A)], binary = true)

    @objective(m, Min,
        sum(f(A[a]) * y[a] for a in eachindex(A)) +
        sum(g(A[a]) * d(K[k]) * x[a, k] for a in eachindex(A), k in eachindex(K))
    )

    @constraint(m, flow[n = eachindex(N), k = eachindex(K)],
        sum(x[a, k] for a in eachindex(A) if ori(A[a]) == n) -
        sum(x[a, k] for a in eachindex(A) if dst(A[a]) == n) == δ(n, K[k])
    )

    @constraint(m, caps[a = eachindex(A)],
        sum(d(K[k]) * x[a, k] for k in eachindex(K)) <= u(A[a]) * y[a]
    )

    return m
end
