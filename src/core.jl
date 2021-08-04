#Accessors
V(i::String) = vertex_data[][i]
M(m::String) = mode_data[][m]

src(e::lin) = e.src
dst(e::lin) = e.dst
md(e::lin) = e.md
w(e::lin) = e.w

Q(m::moda) = m.Q
Q(e::lin) = Q(M(e.md))

#filters
in(i::String) = filter(p -> dst(p) == i, E())
out(i::String) = filter(p -> src(p) == i, E())
