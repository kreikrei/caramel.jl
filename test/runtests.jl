using Revise
using caramel
using Test

function inventory_feasibility(v_set::Dict)
    starting = sum(v_set[i].START for i in keys(v_set))
    demands = sum(sum(v_set[i].d) for i in keys(v_set))

    return starting >= demands
end

function EM_check(e::Vector,m::Dict)
    #unique md in edge list == all m in M
    from_e = unique([e[r].md for r in keys(e)])
    from_m = collect(keys(m))

    return sort(from_e) == sort(from_m)
end

function EV_check(e::Vector,v::Dict)
    #unique vtx in src and dst of edge_list == all in V
    from_e = unique(union(src.(values(e)),dst.(values(e))))
    from_v = collect(keys(v))

    return sort(from_e) == sort(from_v)
end

@testset "caramel.jl" begin
    #READ DATA FIRST
    read_vertex("khazanah.csv","permintaan.csv")
    read_edge("trayek.csv")
    read_mode("kendaraan.csv")

    #SAMPLE ACCESSORS 1
    v_test = rand(keys(V()))
    @test V(v_test) == V()[v_test]

    #SAMPLE ACCESORS 2
    m_test = rand(keys(M()))
    @test M(m_test) == M()[m_test]

    #INVENTORY FEASIBILITY
    @test inventory_feasibility(V())

    #exhaustiveness of edge list
    @test EM_check(E(),M())
    @test EV_check(E(),V())
end
