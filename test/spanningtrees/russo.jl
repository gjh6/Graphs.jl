using Graphs
using Graphs.SimpleGraphs
using Graphs.Russo
using Graphs.Russo: russo_ust
using Test
using SimpleTraits
using Random
using DataStructures



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

Test.@testset "one step" for i in 1:5
    rng = MersenneTwister()
    s = ladder_graph(4)

    seed = abs(rand(rng,Int))
    #seed = 773582192696452834
    #println("seed is: ", seed)

    x = SimpleGraphFromIterator(russo_ust(s,rng=MersenneTwister(seed),steps=0))
    y = SimpleGraphFromIterator(russo_ust(s,rng=MersenneTwister(seed),steps=1))

    Test.@test ne(x) == ne(y)
    Test.@test nv(x) == nv(y)
    
    Test.@test ne(x) == nv(x)-1

    weights = Array{Float64}(undef,8,8)
    for e in edges(s)
        b = rand(rng)
        weights[src(e),dst(e)] = b
        weights[dst(e),src(e)] = b
    end


    w = SimpleGraphFromIterator(russo_ust(s,distmx=weights,rng=MersenneTwister(seed),steps=0))
    z = SimpleGraphFromIterator(russo_ust(s,distmx=weights,rng=MersenneTwister(seed),steps=1))

end

Test.@testset "distribution" begin

    #first unit test:
    #take a square graph with variable weights, 
    #calculate probability of each tree manually,
    #confirm they show up with the correct frequency

    #g:
    # 1--2
    # |  |
    # 3--4
    #
    #weights:
    #(1,2) = .7
    #(1,3) = .6
    #(2,4) = .5
    #(3,4) = .4
    #
    #the probability of the spanning trees are then:
    # A = (1,3),(2,4),(3,4) = .12 =(normalized, approx.) .1881
    # B = (1,2),(2,4),(3,4) = .14 =(normalized, approx.) .2194
    # C = (1,2),(1,3),(3,4) = .168=(normalized, approx.) .2633
    # D = (1,2),(1,3),(2,4) = .21 =(normalized, approx.) .3292


    g = SimpleGraph(4,0)
    add_edge!(g,1,2)
    add_edge!(g,2,4)
    add_edge!(g,3,4)
    add_edge!(g,1,3)

    g_edges = collect(edges(g))

    weights = Array{Float64}(undef,4,4)
    weights[1,2] = .7
    weights[2,1] = .7
    weights[1,3] = .6
    weights[3,1] = .6
    weights[2,4] = .5
    weights[4,2] = .5
    weights[3,4] = .4
    weights[4,3] = .4

    treeCounter = Accumulator{Char,Int64}()

    for i in 1:10000
        #calculate random spanning tree, catching and returning seeds that cause errors.
        rng = MersenneTwister()
        seed = abs(rand(rng,Int))
        local x
        try
            x = russo_ust(g,distmx=weights,rng=rng)
            #assure that all x are spanning trees
            y = SimpleGraphFromIterator(x)
            @assert nv(y) == 4 "not four vertices"
            @assert ne(y) == 3 "not three edges"
            @assert is_connected(y) "not connected"
            @assert !is_cyclic(y) "not cyclic"
        catch err 
            println(err)
            println("seed is: ", seed)
        end
        #sort the spanning trees 
        if !(g_edges[1] in x)
            inc!(treeCounter,'A')

        elseif !(g_edges[2] in x)
            inc!(treeCounter,'B')

        elseif !(g_edges[3] in x)
            inc!(treeCounter,'C')

        elseif !(g_edges[4] in x)
            inc!(treeCounter,'D')
        end
    end

    #assure that all of the x were actually one of A,B,C, or D.
    Test.@test treeCounter['A'] + treeCounter['B'] + treeCounter['C'] + treeCounter['D'] == 10000
    
    #calculate chi-squared
    chi_squared = 0
    chi_squared += ((treeCounter['A']-1881)/1881)
    chi_squared += ((treeCounter['B']-2194)/2194)
    chi_squared += ((treeCounter['C']-2633)/2633)
    chi_squared += ((treeCounter['D']-3292)/3292)

    #for now, test for significant deviation with 3 degrees of freedom, with significance .05
    Test.@test chi_squared < 3.182

end