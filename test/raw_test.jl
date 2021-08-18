#READ DATA FIRST
read_vertex("./smallest/khazanah.csv", "./smallest/permintaan.csv")
read_edge("./smallest/trayek.csv")
read_mode("./smallest/kendaraan.csv")

#test f
f(1) == f(E(1))

#INVENTORY FEASIBILITY
@test inventory_feasibility(V())

#exhaustiveness of edge list
@test EM_check(E(),M())
@test EV_check(E(),V())

#optimality of test pack
tes_model_IP = raw_model_IP(V(),E(),M(),T())
optimize!(tes_model_IP)
@test termination_status(tes_model_IP) == MOI.OPTIMAL

ip_sol = convert_raw(tes_model_IP.obj_dict[:o], tes_model_IP.obj_dict[:p])
@test typeof(collect(keys(period_view(ip_sol)))) == Vector{Int64}
@test typeof(collect(keys(lin_view(ip_sol)))) == Vector{Int64}

#optimality of relaxation of test pack
tes_model_LP = raw_model_LP(V(),E(),M(),T())
optimize!(tes_model_LP)
@test termination_status(tes_model_LP) == MOI.OPTIMAL

lp_sol = convert_raw(tes_model_LP.obj_dict[:o], tes_model_LP.obj_dict[:p])
@test typeof(collect(keys(period_view(lp_sol)))) == Vector{Int64}
@test typeof(collect(keys(lin_view(lp_sol)))) == Vector{Int64}
