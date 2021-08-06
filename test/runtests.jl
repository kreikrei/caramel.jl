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
    #unique vtx in src and dst of edge_list == all in V
    from_E = unique(union(src.(E.(E_)), dst.(E.(E_))))
    from_V = V_

    return sort(from_E) == sort(from_V)
end

@testset "caramel.jl" begin
    #READ DATA FIRST
    read_vertex("khazanah.csv", "permintaan.csv")
    read_edge("trayek.csv")
    read_mode("kendaraan.csv")

    #INVENTORY FEASIBILITY
    @test inventory_feasibility(V())

    #exhaustiveness of edge list
    @test EM_check(E(),M())
    @test EV_check(E(),V())

    #optimality of test pack
    tes_model_IP = raw_model_IP(V(),E(),M(),T())
    optimize!(tes_model_IP)
    @test termination_status(tes_model_IP) == MOI.OPTIMAL

    #optimality of relaxation of test pack
    tes_model_LP = raw_model_LP(V(),E(),M(),T())
    optimize!(tes_model_LP)
    @test termination_status(tes_model_LP) == MOI.OPTIMAL
end
