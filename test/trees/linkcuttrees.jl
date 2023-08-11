using Graphs.SimpleGraphs
using Graphs.Russo:
AbstractNode, Node, DummyNode, setParent!, setLeft!, 
setRight!, getParent, getLeft, getRight, sameNode, childIndex, 
findSplayRoot, findExtreme, traverseSubtree, rotateUp, splay!, getVertex, linkCutTree, parents,
replaceRightSubtree!, expose!, setVertex!, link!, link_cut_tree, findPath, cut!, evert!

using SimpleTraits
using Test

Test.@testset "Link-Cut expose and reversal" begin 

    function makeNodes(n::Int)
        A = AbstractNode[]
        for i in 1:n
            append!(A, [Node(i)])
        end
        return A
    end

    function zigZagAfter()
        A = makeNodes(7)

                setRight!(A[6],A[7])
            setRight!(A[4],A[6])
                setLeft!(A[6],A[5])
        #A[4]
                setRight!(A[2],A[3])
            setLeft!(A[4],A[2])
                setLeft!(A[2],A[1])

        return A
    end

    x = linkCutTree{Int}(zigZagAfter())
    Test.@test parents(x) == [1,1,2,3,4,5,6]
    
    #outside of this testing context, altering the reversed value directly
    #violates the invariants required for the link-cut tree
    x.nodes[4].reversed = true
    Test.@test parents(x) == [2,3,4,5,6,7,7]
    x.nodes[4].reversed = false

    replaceRightSubtree!(x.nodes[4])
    Test.@test parents(x) == [1,1,2,3,4,5,6]
    a = Node(8)
    replaceRightSubtree!(x.nodes[4],a)
    append!(x.nodes,[a])
    Test.@test parents(x) == [1,1,2,3,4,5,6,4]

    expose!(x.nodes[6])
    Test.@test findSplayRoot(x.nodes[1]) == x.nodes[6]
    Test.@test findSplayRoot(x.nodes[4]) == x.nodes[6]
    Test.@test findSplayRoot(x.nodes[7]) == x.nodes[7]
    Test.@test findSplayRoot(x.nodes[8]) == x.nodes[8]
    Test.@test parents(x) == [1,1,2,3,4,5,6,4]

    #testing evert 
    expose!(x.nodes[7])
    evert!(x.nodes[8])

    Test.@test parents(x) == [2,3,4,8,4,5,6,8]

    Test.@test findPath(x.nodes[1])[1] == x.nodes[8]
    B = findPath(x.nodes[7])
    Test.@test findPath(x.nodes[7])[1] == x.nodes[5]



end

Test.@testset "Link-Cut link, constructors, and cut" begin
    
    #build two trees in the same forest
    function makeNodes(n::Int)
        A = AbstractNode[]
        for i in 1:n
            append!(A, [Node(i)])
        end
        return A
    end

    function zigZagAfter()
        A = makeNodes(7)

                setRight!(A[6],A[7])
            setRight!(A[4],A[6])
                setLeft!(A[6],A[5])
        #A[4]
                setRight!(A[2],A[3])
            setLeft!(A[4],A[2])
                setLeft!(A[2],A[1])

        return A
    end

    tree1 = zigZagAfter()
    tree2 = zigZagAfter()

    for n in tree2
        setVertex!(n, getVertex(n) + 7)
    end

    A = AbstractNode[tree1;tree2]
    x = linkCutTree{Int}(A)

    Test.@test_throws ArgumentError link!(x.nodes[11],x.nodes[3])
    Test.@test_throws ArgumentError link!(x.nodes[3],x.nodes[4])
    link!(x.nodes[8],x.nodes[5])
    Test.@test parents(x) == [1,1,2,3,4,5,6,5,8,9,10,11,12,13]
    splay!(x.nodes[10])
    Test.@test parents(x) == [1,1,2,3,4,5,6,5,8,9,10,11,12,13]


    #constructors
    starTree = link_cut_tree(star_digraph(5))
    Test.@test parents(starTree) == [1,1,1,1,1]
    
    #testing with example splay tree shown in https://en.wikipedia.org/wiki/File:Linkcuttree1.png
    #each node in that image (which has letters indexing nodes) is indexed by its letter's place
    #in the alphabet.
    wikiGraph = SimpleDiGraph(15)
    add_edge!(wikiGraph,1,2)
    add_edge!(wikiGraph,2,5)
    add_edge!(wikiGraph,1,3)
    add_edge!(wikiGraph,3,6)
    add_edge!(wikiGraph,6,10)
    add_edge!(wikiGraph,10,12)
    add_edge!(wikiGraph,12,14)
    add_edge!(wikiGraph,12,15)
    add_edge!(wikiGraph,6,11)
    add_edge!(wikiGraph,11,13)
    add_edge!(wikiGraph,1,4)
    add_edge!(wikiGraph,4,7)
    add_edge!(wikiGraph,4,8)
    add_edge!(wikiGraph,4,9)

    wikiTree = link_cut_tree(wikiGraph)

    Test.@test parents(wikiTree) == [1,1,1,1,2,3,4,4,4,6,6,10,11,12,12]

    #use expose to mimic the preferred paths shown in the leftmost tree of the wikipedia image.
    expose!(wikiTree.nodes[8])
    expose!(wikiTree.nodes[14])
    expose!(wikiTree.nodes[13])
    expose!(wikiTree.nodes[5])


    Test.@test findPath(wikiTree.nodes[5])[1] == wikiTree.nodes[1]
    Test.@test findPath(wikiTree.nodes[14])[1] == wikiTree.nodes[10]
    Test.@test findPath(wikiTree.nodes[15])[1] == wikiTree.nodes[15]
    Test.@test findPath(wikiTree.nodes[13])[1] == wikiTree.nodes[3]
    Test.@test findPath(wikiTree.nodes[7])[1] == wikiTree.nodes[7]
    Test.@test findPath(wikiTree.nodes[8])[1] == wikiTree.nodes[4]
    Test.@test findPath(wikiTree.nodes[9])[1] == wikiTree.nodes[9]

    Test.@test parents(wikiTree) == [1,1,1,1,2,3,4,4,4,6,6,10,11,12,12]

    Test.@test findPath(wikiTree.nodes[6]) == [wikiTree.nodes[3],wikiTree.nodes[6],wikiTree.nodes[11],wikiTree.nodes[13]]
    Test.@test findPath(6,wikiTree) == [3,6,11,13]


    #now, to test cut, individually cut every edge in the tree-- every node will be its own parent.
    for i in 2:15
        cut!(wikiTree.nodes[i])
    end

    Test.@test parents(wikiTree) == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]

    #and rebuild the tree to confirm it works.
    
    link!(wikiTree.nodes[2],wikiTree.nodes[1])
    link!(wikiTree.nodes[3],wikiTree.nodes[1])
    link!(wikiTree.nodes[4],wikiTree.nodes[1])
    link!(wikiTree.nodes[5],wikiTree.nodes[2])
    link!(wikiTree.nodes[6],wikiTree.nodes[3])
    link!(wikiTree.nodes[7],wikiTree.nodes[4])
    link!(wikiTree.nodes[8],wikiTree.nodes[4])
    link!(wikiTree.nodes[9],wikiTree.nodes[4])
    link!(wikiTree.nodes[10],wikiTree.nodes[6])
    link!(wikiTree.nodes[11],wikiTree.nodes[6])
    link!(wikiTree.nodes[12],wikiTree.nodes[10])
    link!(wikiTree.nodes[13],wikiTree.nodes[11])
    link!(wikiTree.nodes[14],wikiTree.nodes[12])
    link!(wikiTree.nodes[15],wikiTree.nodes[12])

    Test.@test parents(wikiTree) == [1,1,1,1,2,3,4,4,4,6,6,10,11,12,12]


end