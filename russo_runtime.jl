using Graphs
using Graphs.Russo: russo_ust
using Profile
using LinearAlgebra
using Random


sparseX = ladder_graph(4000)

rng = MersenneTwister()

wmatrix = zeros(Float64,size(weights(sparseX)))
        for edge in edges(sparseX)
            wmatrix[src(edge),dst(edge)] = rand(rng)*2
        end
        wmatrix = Symmetric(wmatrix)


@time @profview russo_ust(sparseX, wmatrix, steps=round(Int64,2*(nv(sparseX)^1.3 + ne(sparseX))))