module caramel

using JuMP, Cbc, Clp
using CSV, Distances

include("struct.jl")
include("reader.jl")
include("core.jl")

#struct.jl
export satker, moda, lin

#reader.jl
export V, E, M, T
export read_vertex, read_edge, read_mode

#core.jl
export Q, w, md, dst, src
export IN, OUT
export f, g
export raw_model_IP, raw_model_LP

end
