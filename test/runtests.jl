using Revise
using caramel
using Test
using JuMP

function inventory_feasibility(V_::Dict)
    starting = sum(V_[i].START for i in keys(V_))
    demands = sum(sum(V_[i].d) for i in keys(V_))
    minim = sum(V_[i].MIN for i in keys(V_))

    return starting - minim >= demands
end

function EM_check(E_::Dict, M_::Dict)
    #unique md in edge list == all m in M
    from_E = unique(md.(values(E_)))
    from_M = collect(keys(M_))

    return sort(from_E) == sort(from_M)
end

function EV_check(E_::Dict, V_::Dict)
    #unique vtx in src and dst of edge_list == all in V
    from_E = unique(union(src.(values(E_)), dst.(values(E_))))
    from_V = collect(keys(V_))

    return sort(from_E) == sort(from_V)
end

@testset "caramel.jl" begin
    #READ DATA FIRST
    read_vertex("khazanah.csv", "permintaan.csv")
    read_edge("trayek.csv")
    read_mode("kendaraan.csv")

    #SAMPLE ACCESSORS V
    v_test = rand(keys(V()))
    @test V(v_test) == V()[v_test]

    #SAMPLE ACCESORS M
    m_test = rand(keys(M()))
    @test M(m_test) == M()[m_test]

    #SAMPLE ACCESSORS E
    e_test = rand(keys(E()))
    @test E(e_test) == E()[e_test]

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
