# caramel.jl

[![Build Status](https://ci.appveyor.com/api/projects/status/github/kreikrei/caramel.jl?svg=true)](https://ci.appveyor.com/project/kreikrei/caramel-jl)
[![Coverage](https://codecov.io/gh/kreikrei/caramel.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/kreikrei/caramel.jl)

Model and algorithm for flexible and dynamic inventory routing with direct deliveries. The model is built on a rolling horizon. Given the initial inventories, inventory capacities, available transportation, and external demands the algorithm will generate the optimal distribution along the planning horizon.

```julia
distribute(khazanah, permintaan, trayek, moda, T)
```

using the command `distribute` will read the inputs and find the optimal distribution. There are test cases given in the test folder, feel free to add more tests and variations.

Note to self:
- math program deps => `JuMP`, `Cbc`, `Clp`
- data reading deps => `CSV`
- computations => `Distances`

buat transportasi ada 4 hal yang penting `f`, `g`, `Q`, `lim`. tiga pertama terikat sama moda apa yang digunakan -- di mana `f` dan `g` akan jadi fungsi buat komputasi biaya tetap dan biaya total. Terus `Q` kan ya gitu2 aja namanya juga kapasitas kendaraan. Terakhir, `lim` sifatnya terikat sama trayek masing-masing jd bukan bagian dr moda.

## parameter biaya dalam satuan `juta Rupiah` - JANGAN LUPA OKEE?! Bakal dipakai buat sidang semoga cepat selesai. wish me luck!

KYKNYA KITA AKAN FOKUS KE Large Neighborhood Search!!

Log:
11/8/2021 => structure buat arc sama commodity selesai.
penting buat diinget set bentuknya dictionary yg numbered. nnti diiterate pake keys masing2 dan klo ada accessor ya panggil dlu Dict-nya. `A = Dict{Integer, arc}` brarti klo mau access jdi `ori(A[a]) for a in syalalala`. MODEL ARC-FCNF SUDAH JADI -- brarti otw benchmark pake solver komersial.

Todos:
- bikin *fungsi konversi* data Bank Indonesia di 4 CSV jdi struktur data yg ready
- bikin *data generator* buat instance dengan ukuran di atas 50. coba bikin semirip mungkin sama data Bank Indonesia, tp jgn smp ngebatesin banget juga. Bbrp yg penting: ada komoditas representasi *demand negatif*, ada *beberapa jenis edge* dengan harga dan kapasitas yang berbeda, *konektivitas antar satker* harus terjamin, dan *fisibilitas problem instance* juga harus diusahain terjamin -- kalo gabisa coba bikin fungsi buat ngecek fisibilitas dan ngebenerinnya.
- running data-data berukuran besar di solver komersil => benchmark waktu algoritma. harapannya dg data yang jumlah node-nya di atas 80 runtimenya menitan itungannya.
