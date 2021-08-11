"""
`satker` is "satuan kerja" and contains its position to compute distances, its max and min capacity, and inventory flows at the begining and throughout the planning horizon.
"""
struct satker
    #coordinates
    x::Float64
    y::Float64

    #capacities
    MAX::Int64
    MIN::Int64

    #inventory flows
    START::Int64
    d::Vector{Int64}
end

"""
`moda` is the type of transportation. this will be called by lins. The struct contains building blocks for cost functions and load-trip multiples.
"""
struct moda
    #capacity
    Q::Int64

    #fixed cost
    con::Float64
    dis::Float64

    #variable cost
    var::Float64
end

"""
`lin` is the edge of the multigraph it shows the triplet source, destination, and mode of an edge and it also contains the availability of that segment.
"""
struct lin
    #triplet (i,j,k)
    src::String
    dst::String
    md::String

    #limit of use
    w::Int64
end

"""
'haul' is a shipment which consist of its track, period, load, and trip. it is used to build columns and do other stuff.
"""
struct haul
    e::Int64
    t::Int64
    o::Real
    p::Real
end