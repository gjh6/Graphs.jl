using Graphs
using Graphs.SimpleGraphs
using Graphs.Russo
using Graphs.Russo: russo_ust
using Test



Test.@testset "replace later" begin

    s = ladder_graph(4)
    #right now, this works, but i have to use Russo. before anything in the russo package.
    #this should be in the same scope in Graphs.Russo, but i think something about SimpleTraits
    #messes that up. For now, I'm just gonna move on because it works.
    russo_ust(s)
    #note: still working on converting from parents vector to graph again.
    #Test.@test dfs_tree(s,1) == dfs_tree(SimpleGraphFromIterator(russo_ust(s)),1)
    russo_ust(s,steps=3)
    russo_ust(s,distmx=weights(s))
    russo_ust(s,startingTree=bfs_tree(s,1))





end

#first unit test:
    #take a square graph with variable weights, 
    #calculate probability of each tree manually,
    #confirm they show up with the correct frequency
