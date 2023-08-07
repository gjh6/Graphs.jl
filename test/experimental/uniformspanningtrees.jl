using Graphs.Experimental.UniformSpanningTrees
using Graphs.Experimental.UniformSpanningTrees: 
AbstractNode, Node, DummyNode, setParent!, setLeft!, 
setRight!, getParent, getLeft, getRight, sameNode, childIndex, 
findSplayRoot, findExtreme, traverseSubtree, rotateUp, splay!, getVertex, linkCutForest, parents

using SimpleTraits
using Test

Test.@testset "Splay Tree tests" begin

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

    function samePath(u::Node, v::Node)
        uArray = traverseSubtree(u, "in-order")
        vArray = traverseSubtree(v, "in-order")
        r = true
        if length(uArray) != length(vArray)
            return false
        end
        for i in eachrow([uArray;;vArray])
            r = r && sameNode(i[1],i[2])
        end

        return r
    end

    #example cases:
    function makeNodes(n::Int)
        A = []
        for i in 1:n
            append!(A, [Node(i)])
        end
        return A
    end
    #zig:
    function zigBefore()
        A = makeNodes(5)
            
            setRight!(A[4],A[5])
        #A[4]
                setRight!(A[2],A[3])
            setLeft!(A[4],A[2])
                setLeft!(A[2],A[1])

        return A
    end

    function zigAfter()
        A = makeNodes(5)

                setRight!(A[4],A[5])
            setRight!(A[2],A[4])
                setLeft!(A[4],A[3])
        #A[2]
            setLeft!(A[2],A[1])

        return A
    end

    #zig-zig:
    function zigZigBefore()
        A = makeNodes(9)

                    setRight!(A[8],A[9])
                setRight!(A[6],A[8])
                    setLeft!(A[8],A[7])
            setRight!(A[2],A[6])
                    setRight!(A[4],A[5])
                setLeft!(A[6],A[4])
                    setLeft!(A[4],A[3])
        #A[2]
            setLeft!(A[2],A[1])


        return A
    end
    function zigZigAfter()
        A = makeNodes(9)

            setRight!(A[8],A[9])
        #A[8]
                setRight!(A[6],A[7])
            setLeft!(A[8],A[6])
                        setRight!(A[4],A[5])
                    setRight!(A[2],A[4])
                        setLeft!(A[4],A[3])
                setLeft!(A[6],A[2])
                    setLeft!(A[2],A[1])

        return A
    end

    #zig-zag:
    function zigZagBefore()
        A = makeNodes(7)

                setRight!(A[6],A[7])
            setRight!(A[2],A[6])
                    setRight!(A[4],A[5])
                setLeft!(A[6],A[4])
                    setLeft!(A[4],A[3])
        #A[2]
            setLeft!(A[2],A[1])

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




    #basic tests:
    x = Node(1)
    y = Node(1)
    Test.@test sameNode(x,y)
    Test.@test sameNode(getLeft(x),getRight(y))
    Test.@test !sameNode(x,getRight(x))

    z = Node(2)
    setParent!(z,x)
    w = Node(0)
    setParent!(w,x)
    setLeft!(x,w)
    Test.@test childIndex(w) == 1
    setRight!(x,z)
    Test.@test childIndex(z) == 2

    #tree traversal tests:
    v = Node(-1)
    setLeft!(w,v)
    Test.@test sameNode(findSplayRoot(v),x)
    Test.@test sameNode(findExtreme(x,false),v)

    Test.@test sameSubtree(x,x)
    Test.@test !sameSubtree(x,v)
    Test.@test samePath(x,x)
    Test.@test !samePath(x,v)

    orderX = traverseSubtree(x,"in-order")
    rotateUp(v)
    Test.@test orderX == traverseSubtree(x,"in-order")

    A = reverse(traverseSubtree(x))
    x.reversed = true
    Test.@test traverseSubtree(x) == A
    x.reversed = false
    A = reverse(A)
    Test.@test traverseSubtree(x) == A

    v.reversed = true
    A = reverse(A,1,2)
    Test.@test traverseSubtree(x) == A

    splay!(w)
    Test.@test traverseSubtree(w) == A

    w.reversed = true

    splay!(x)

    Test.@test traverseSubtree(x) == reverse(A)
    Test.@test traverseSubtree(x) != A

    #splay() tests:
    #zig
    A = zigBefore()
    splay!(A[2])
    Test.@test sameSubtree(A[2],zigAfter()[2])
    A = zigBefore()
    Test.@test !sameSubtree(A[2],zigAfter()[2])
    #zig-zig
    A = zigZigBefore()
    splay!(A[8])
    Test.@test sameSubtree(A[8],zigZigAfter()[8])
    #zig-zag
    A = zigZagBefore()
    splay!(A[4])
    Test.@test sameSubtree(A[4],zigZagAfter()[4])

    #reversal
    """
    TODO: if Q is named A here, following the names I've used before, it doesn't 
    reverse when it should. I have no. idea. why. Even when ALL of the other tests
    are commented out, it still does this. I have to assume the A's used for arrays 
    inside the example tree maker functions are doing it somehow? I can't figure out how.
    """
    Q = zigZagBefore()
    Q[2].reversed = true
    splay!(Q[4])
    B = zigZagAfter()
    B[4].reversed = true
    Test.@test sameSubtree(Q[4],B[4])
    B[4].reversed = false
    
    C = traverseSubtree(Q[4])


    Test.@test C != traverseSubtree(B[4])






end



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
    
    x.nodes[4].reversed = true
    Test.@test parents(x) == [2,3,4,5,6,7,7]



end