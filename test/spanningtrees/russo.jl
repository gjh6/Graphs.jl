using Graphs
using Graphs.SimpleGraphs
using Graphs.Russo
using Graphs.Russo: russo_ust
using Test
using SimpleTraits
using Random



Test.@testset "input and output" begin

    s = ladder_graph(4)
    #right now, this works, but i have to use Russo. before anything in the russo package.
    #this should be in the same scope in Graphs.Russo, but i think something about SimpleTraits
    #messes that up. For now, I'm just gonna move on because it works.
    russo_ust(s,steps=0)
    #note: still working on converting from parents vector to graph again.
    Test.@test dfs_tree(s,1) == dfs_tree(SimpleGraphFromIterator(russo_ust(s,steps=0)),1)
    russo_ust(s,steps=0)
    russo_ust(s,distmx=weights(s),steps=0)
    russo_ust(s,startingTree=bfs_tree(s,1),steps=0)

    seed = abs(rand(Int))
    #seed = 773582192696452834
    #println("seed is: ", seed)

    russo_ust(s,rng=MersenneTwister(seed),steps=0)

end

Test.@testset "one step" begin
    s = ladder_graph(4)

    seed = abs(rand(Int))
    #seed = 773582192696452834
    println("seed is: ", seed)

    russo_ust(s,rng=MersenneTwister(seed),steps=1)


end

#first unit test:
    #take a square graph with variable weights, 
    #calculate probability of each tree manually,
    #confirm they show up with the correct frequency
