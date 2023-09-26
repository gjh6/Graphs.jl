"""
    AbstractNode

An abstract type with two subtypes: Node and DummyNode. DummyNode will be a singleton type,
and represents a node that isn't in the represented tree (like the children of a leaf node).
Node will represent a node of a splay tree. 
as the LCT will be used to represent a graph, each node must remember what vertex it represents.
as such, T is whatever type is used to keep track of the vertices.
"""
abstract type AbstractNode{T} end

mutable struct Node{T} <: AbstractNode{T}
    
    vertex::T
    parent::AbstractNode
    pathParent::AbstractNode
    children::Vector{AbstractNode}
    reversed::Bool

    function Node{T}(vertex, parent::AbstractNode, 
        leftchild::AbstractNode, rightchild::AbstractNode, pathParent::AbstractNode) where {T}
        n = new(vertex, parent, pathParent)
        n.reversed = false
        n.children = Vector{AbstractNode}(undef,2)
        setLeft!(n,leftchild)
        setRight!(n,rightchild)
        return n
    end

end
Node(vertex::T) where {T} = Node{T}(vertex, DummyNode{T}(),
DummyNode{T}(),DummyNode{T}(),DummyNode{T}())


#Getters and Setters:
function setParent!(n::AbstractNode, p::AbstractNode)
    if n isa DummyNode
        return nothing
    end
n.parent = p
end

function setChild!(n::Node, i::Int, c::AbstractNode)
    n.children[i] = c
    setParent!(c,n)
end

function setLeft!(n::Node, l::AbstractNode)
    setChild!(n,1,l)
end

function setRight!(n::Node, r::AbstractNode)
    setChild!(n,2,r)
end

function setPathParent!(n::Node, p::AbstractNode)
    n.pathParent = p
end

function setVertex!(n::Node{T}, v::T) where {T}
    n.vertex = v
end

function getParent(n::Node)
    return n.parent
end

function getChild(n::Node,i::Int)
    return n.children[i]
end

function getLeft(n::Node)
    return getChild(n,1)
end

function getRight(n::Node)
    return getChild(n,2)
end

function getPathParent(n::Node)
    return n.pathParent
end

function getVertex(n::Node)
    return n.vertex
end



#Finding information / utility functions:
function sameNode(n1::AbstractNode,n2::AbstractNode)
    if n1 isa Node && n2 isa Node 
        return getVertex(n1) == getVertex(n2)
    end

    return n1 == n2        
end

"Returns the index n has in its parent's vector of children. Requires a real parent."
function childIndex(n::Node)
    return findfirst(x->sameNode(n,x),getParent(n).children)
end

function findSplayRoot(n::Node)
    r = n
    while getParent(r) isa Node
        r = getParent(r)
    end
return r
end

"Finds the left- or right-most node in the splay tree of n."
function findExtreme(n::Node, largest::Bool)
    r = findSplayRoot(n)
    childIndex = 1
    largest && (childIndex+=1)==2

    while getChild(r,childIndex) isa Node
        r = getChild(r,childIndex)

    end

    return r
end


#don't export this, the other one is the wrapper that should be called.
function traverseSubtree!(A::Array, n::Node, order::Int, reverse::Bool)

    if order == 1
        append!(A,[n])
    end

    for i in 0:1
        if i == 1 && order == 2
            append!(A, [n])
        end

        c = getChild(n, (i⊻n.reversed⊻reverse)+1)
        if c isa Node
            traverseSubtree!(A,c,order,n.reversed⊻reverse)
        end

    end

    if order == 3
        append!(A,[n])
    end

end

"returns an array with the desired traversal of the subtree of n."
function traverseSubtree(n::Node, order::String="in-order")
    A = []

    pre_order, in_order, post_order = false,false,false

    (pre_order=(order=="pre-order"))||(in_order=(order=="in-order"))||(post_order=(order=="post-order"))

    order = pre_order + in_order*2 + post_order*3

    traverseSubtree!(A,n,order,false)

    return A
end




#splay tree modification:
"Rotates n upwards in the splay tree while maintaining BST rules. Requires a real parent."
function rotateUp(n::Node)
    i = childIndex(n)
    p = getParent(n)
    g = getParent(p)

    setParent!(n,g)
    if g isa Node
        j = childIndex(p)
        setChild!(g,j,n)
    else
        setPathParent!(n,getPathParent(p))
        t = typeof(getVertex(n))
        setPathParent!(p,DummyNode{t}())
    end

    #move n's correct child into the place where n used to be, beneath p.
    setChild!(p, i, getChild(n,3-i))
    #set p to be n's correct child.
    setChild!(n,3-i,p)

end

"Alters the tree until n is the root. Does not disrupt the ordering."
function splay!(n::Node)
    pushReversed!(n)
    while getParent(n) isa Node
        p = getParent(n)
        
        #just zig; n is a child of the root.
        if getParent(p) isa DummyNode
            rotateUp(n)

        # zig-zig: n<p<p.parent, or n>p>p.parent
        elseif childIndex(n) == childIndex(p)
            rotateUp(p)
            rotateUp(n)
        
        #zig-zag: p<n<p.parent, or p.parent<n<p
        else 
            rotateUp(n)
            rotateUp(n)
        end
    end
end

function pushReversed!(n::Node)
    if n.parent isa Node
        pushReversed!(n.parent)
    end

    if n.reversed 
        n.children = reverse(n.children)
        for c in n.children
            if c isa Node
             c.reversed = !c.reversed
            end
        end
        n.reversed = false
    end
end


struct DummyNode{T} <: AbstractNode{T} end


