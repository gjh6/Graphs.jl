using Graphs.Russo:
AbstractNode, Node, DummyNode, setParent!, setLeft!, 
setRight!, getParent, getLeft, getRight, sameNode, childIndex, 
findSplayRoot, findExtreme, traverseSubtree, rotateUp, splay!, getVertex, linkCutForest, parents,
replaceRightSubtree!, expose!

using SimpleTraits
using Test

Test.@testset "Link-Cut tree tests" begin 

    function makeNodes(n::Int)
        A = []
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

    function sameSubtree(u::Node, v::Node)
        uArray = [traverseSubtree(u, "in-order");traverseSubtree(u, "pre-order");traverseSubtree(u,"post-order")]
        vArray = [traverseSubtree(v, "in-order");traverseSubtree(v, "pre-order");traverseSubtree(v,"post-order")]

        r = true
        if length(uArray) != length(vArray)
            return false
        end
        for i in eachrow([uArray;;vArray])
            r = r && sameNode(i[1],i[2])
        end

        return r
    end

    function sameLinkCutTree(n::Node, v::Node)
        

    end

    x = linkCutForest{Int}(zigZagAfter())
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

    

end