module caramel

using JuMP, Cbc, Clp
using CSV, Distances

include("./raw/IO.jl")
include("./raw/raw.jl")

#struct.jl
export satker, moda, lin
export haul

#reader.jl
export V, E, M, T
export read_vertex, read_edge, read_mode

#core.jl
export Q, w, md, dst, src
export IN, OUT
export f, g
export raw_model_IP, raw_model_LP, convert_raw
export period_view, lin_view
export cost

include("./fcnf/fcnf.jl")
include("./fcnf/IO.jl")

export Node, loc, per
export Arc, ori, dst, f, g, u
export Commodity, src, snk, d, δ

end
