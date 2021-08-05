const vertex_data = Ref{Any}(nothing)
const edge_data = Ref{Any}(nothing)
const mode_data = Ref{Any}(nothing)
const time_data = Ref{Any}(nothing)

E() = edge_data[] #define edge set caller
V() = vertex_data[] #define vertex set caller
M() = mode_data[] #define mode set caller
T() = time_data[] #define time set caller

"""
    read_vertex(vertex_file,demand_file)
accept strings of file names in .csv format to be processed into a dictionary of `satker` type. Also sets the `V()` constant.
"""
function read_vertex(vertex_file::String,demand_file::String)
    vertex = CSV.File(vertex_file)
    demand = CSV.File(demand_file)

    time_data[] = [1:1:length(demand);] #set time period
    vertex_dict = Dict{String,satker}()
    for r in vertex
        vertex_dict[r.name] = satker(
            r.x, r.y, r.MAX, r.MIN,
            r.START, getproperty(demand,Symbol(r.name))
        )
    end
    vertex_data[] = vertex_dict

    return vertex_dict
end

"""
    read_edge(edge_list)
accept edge list files in .csv to turn into vector of 'lin' type. Sets the `E` constant.
"""
function read_edge(edge_list::String)
    trayek = CSV.File(edge_list)

    edge_vec = Vector{lin}()
    for r in trayek
        push!(edge_vec,lin(
                r.src, r.dst, r.md, r.w
            )
        )
    end
    edge_data[] = edge_vec

    return edge_vec
end

"""
    read_mode(mode_file)
accept modes of transportation and its parameters in .csv and turns it into a dict of `mode` type. Also sets the `M` constant.
"""
function read_mode(mode_file::String)
    mode = CSV.File(mode_file)

    mode_dict = Dict{String,moda}()
    for r in mode
        mode_dict[r.name] = moda(
            r.Q, r.con, r.dis, r.var
        )
    end
    mode_data[] = mode_dict

    return mode_dict
end
