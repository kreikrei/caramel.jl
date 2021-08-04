using Revise
using caramel
using Test

function inventory_feasibility(v_set::Dict)
    starting = sum(v_set[i].START for i in keys(v_set))
    demands = sum(sum(v_set[i].d) for i in keys(v_set))

    if starting < demands
        return false
    else
        return true
    end
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
end
