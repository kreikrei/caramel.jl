using Revise
using caramel
using Test
using JuMP

function inventory_feasibility(V_::Vector)
    starting = sum(V(i).START for i in V_)
    demands = sum(sum(V(i).d) for i in V_)
    minim = sum(V(i).MIN for i in V_)

    return starting - minim >= demands
end

function EM_check(E_::Vector, M_::Vector)
    #unique md in edge list == all m in M
    from_E = unique(md.(E.(E_)))
    from_M = M_

    return sort(from_E) == sort(from_M)
end

function EV_check(E_::Vector, V_::Vector)
    #unique vtx in ori and dst of edge_list == all in V
    from_E = unique(union(ori.(E.(E_)), dst.(E.(E_))))
    from_V = V_

    return sort(from_E) == sort(from_V)
end

@testset "caramel.jl" begin
    include("raw_test.jl")
end
