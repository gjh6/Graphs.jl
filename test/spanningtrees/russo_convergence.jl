using Graphs
using Test
using Graphs.Russo: russo_ust, ref_trees, HConvergence, edge_distance, TConvergence
using Random
using LinearAlgebra


@testset "convergence test 1" begin

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

    #HConvergence(s,interval=5,rng=MersenneTwister(seed))


end

@testset "Convergence test 2" begin
    
    rng = MersenneTwister()
    seed = abs(rand(rng,Int))
    #seed = 5442317090176155753
    println("seed is: ", seed)

    s = ladder_graph(4)

    #@test TConvergence(s,1,rng=MersenneTwister(seed)) <= 1

    #println("TConvergence test with t=25 gave epsilon: ", TConvergence(s,25,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=100 gave epsilon: ", TConvergence(s,100,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=200 gave epsilon: ", TConvergence(s,200,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=1000 gave epsilon: ", TConvergence(s,1000,rng=MersenneTwister(seed)))

    c = cycle_graph(10)

    #println("TConvergence test with t=30 gave epsilon: ", TConvergence(c,30,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=100 gave epsilon: ", TConvergence(c,100,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=200 gave epsilon: ", TConvergence(c,200,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=1000 gave epsilon: ", TConvergence(c,1000,rng=MersenneTwister(seed)))

    complete = complete_graph(15)

    #println("TConvergence test with t=140 gave epsilon: ", TConvergence(complete,140,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=100 gave epsilon: ", TConvergence(complete,100,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=200 gave epsilon: ", TConvergence(complete,200,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=1000 gave epsilon: ", TConvergence(complete,1000,rng=MersenneTwister(seed)))

    rng = MersenneTwister(seed)

    randgraph = SimpleGraph(20,60)
    while !is_connected(randgraph)
        randgraph = SimpleGraph(20,60)
    end

    wmatrix = zeros(Float64,size(weights(randgraph)))
        for edge in edges(randgraph)
            wmatrix[src(edge),dst(edge)] = rand(rng)*2
        end
        wmatrix = Symmetric(wmatrix)
    
    #println("TConvergence test with t=109 gave epsilon: ", TConvergence(randgraph,109, error=.05,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=25 gave epsilon: ", TConvergence(randgraph,25,rng=MersenneTwister(seed)))
    #println("TConvergece test with t=200 and weights gave epsilon: ", TConvergence(randgraph,200,wmatrix,error=.05,rng=rng))
    #println("TConvergence test with t=200 gave epsilon: ", TConvergence(randgraph,200,error=.05,rng=MersenneTwister(seed)))
    #println("TConvergence test with t=1000 gave epsilon: ", TConvergence(complete,1000,rng=MersenneTwister(seed)))

end