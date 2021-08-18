const vertex_data = Ref{Any}(nothing)
const edge_data = Ref{Any}(nothing)
const mode_data = Ref{Any}(nothing)
const time_data = Ref{Any}(nothing)

E() = sort!(collect(keys(edge_data[]))) #define edge set caller
V() = sort!(collect(keys(vertex_data[]))) #define vertex set caller
M() = sort!(collect(keys(mode_data[]))) #define mode set caller
T() = time_data[] #define time set caller

"""
    read_vertex(vertex_file)
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

    return nothing
end

"""
    read_edge(edge_list)
accept edge list files in .csv to turn into vector of 'lin' type. Sets the `E` constant.
"""
function read_edge(edge_list::String)
    trayek = CSV.File(edge_list)

    edge_dict = Dict{Int64,lin}()
    idx = 1
    for r in trayek
        edge_dict[idx] = lin(
            r.ori, r.dst,
            r.md, r.w
        )
        idx += 1
    end
    edge_data[] = edge_dict

    return nothing
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

    return nothing
end
