using Graphs
using Test
using Graphs.Russo: russo_ust, ref_trees, HConvergence, edge_distance
using Random

Test.@testset "convergence test 1" begin

    rng = MersenneTwister()
    seed = abs(rand(rng,Int))
    #seed = 5442317090176155753
    println("seed is: ", seed)

    s = ladder_graph(4)
    strees = ref_trees(s,rng=MersenneTwister(seed))

    @test size(strees)[1] == 20
    @test ne(strees[1]) == 7
    @test nv(strees[1]) == 8

    @test edge_distance(strees[1],strees[2]) < 8
    @test edge_distance(strees[1],strees[2]) >= 0

    g=russo_ust(s,startingTree=ref_trees(s)[1])

    @test HConvergence(s,interval=100,error=1.0,rng=MersenneTwister(seed)) == 100

    HConvergence(s,interval=5)


end