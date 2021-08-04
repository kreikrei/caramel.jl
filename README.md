# caramel

[![Build Status](https://ci.appveyor.com/api/projects/status/github/kreikrei/caramel.jl?svg=true)](https://ci.appveyor.com/project/kreikrei/caramel-jl)
[![Coverage](https://codecov.io/gh/kreikrei/caramel.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/kreikrei/caramel.jl)

Model and algorithm for flexible and dynamic inventory routing with direct deliveries. The model is built on a rolling horizon. Given the initial inventories, inventory capacities, available transportation, and external demands the algorithm will generate the optimal distribution along the planning horizon.

```julia
distribute(khazanah, permintaan, trayek, moda, T)
```

using the command `distribute` will read the inputs and find the optimal distribution. There are test cases given in the test folder, feel free to add more tests and variations.

Note to self:
- math program deps => `JuMP`, `Cbc`, `Clp`
- data reading => `CSV`, `Distances`

buat transportasi ada 4 hal yang penting `f`, `g`, `Q`, `lim`. tiga pertama terikat sama moda apa yang digunakan -- di mana `f` dan `g` akan jadi fungsi buat komputasi biaya tetap dan biaya total. Terus `Q` kan ya gitu2 aja namanya juga kapasitas kendaraan. Terakhir, `lim` sifatnya terikat sama trayek masing-masing jd bukan bagian dr moda.

Bakal dipakai buat sidang semoga cepat selesai. wml!
