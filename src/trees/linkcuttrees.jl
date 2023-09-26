"""
    link_cut_tree(g)

 Returns a link_cut_tree data structure from a graph that is a rooted, directed tree or forest of trees https://dl.acm.org/doi/10.1145/3828.3835

 Directed trees are sometimes called [polytrees](https://en.wikipedia.org/wiki/Polytree)). 

"""
function link_cut_tree end
@traitfn function link_cut_tree(g::AG::IsDirected) where {U,AG<:AbstractGraph{U}}
    tree = linkCutTree{U}(nv(g))

    for n in vertices(g)
        for c in neighbors(g,n)
            link!(tree.nodes[c],tree.nodes[n])
        end
    end

    return tree
end

#Link Cut Functions:
struct linkCutTree{T<:Integer}
    #nodes should be ordered- the first node is vertex 1, etc.
    nodes::AbstractArray{AbstractNode}


    function linkCutTree{T}(s::Integer) where {T<:Integer} 
        f = new(Vector{AbstractNode}(undef,s))
        for n in 1:length(f.nodes)
            f.nodes[n] = Node(convert(T,n))
        end
        return f
    end

    function linkCutTree{T}(n::AbstractArray{AbstractNode}) where {T<:Integer}
        t = new(n)
        return t
    end

end
#linkCutForest{T}() where {T<:Integer} = linkCutFoest{T}(Vector{AbstractNode}[])

"Returns a vector of integers, each entry i indicating the index of the parent of the node at index i."
function parents(f::linkCutTree{T}) where {T<:Integer}
    nodes = copy(f.nodes)
    p = Vector{T}(undef,length(f.nodes))
    visited = Vector{Bool}([false for _ = 1:length(nodes)])

    pos = 1
    while pos <= length(nodes)
        while pos <= length(nodes) && visited[pos] 
            pos += 1
        end
        if pos > length(nodes)
            break
        end
        r = findSplayRoot(nodes[pos])
        s = traverseSubtree(r)
        if r.pathParent isa Node
            p[s[1].vertex] = r.pathParent.vertex
        else
            p[s[1].vertex] = s[1].vertex
        end
        for i in 2:lastindex(s)
            p[s[i].vertex] = s[i-1].vertex
        end
        for n in s
            visited[n.vertex] = true
        end
    end

    return p
end

"Returns a vector of the current subtree that n is in, in order of depth on the represented tree."
function findPath(n::Node)
    return traverseSubtree(findSplayRoot(n))
end

"returns a vector of the integer labels for the current subtree that the node indexed by i is in,
 in the tree t, in order of depth on the represented tree."
function findPath(i::Integer, t::linkCutTree)
    A = traverseSubtree(findSplayRoot(t.nodes[i]))
    B = Vector{Integer}(undef,length(A))
    for i in eachindex(A)
        B[i] = getVertex(A[i])
    end
    return B
end

"Replaces the right subtree of n with r, or with nothing if r is unspecified.
the old right subtree of n is moved to a separate auxillary tree and tracked with a path-parent pointer."
function replaceRightSubtree!(n::Node, r::AbstractNode=DummyNode{typeof(getVertex(n))}())
    c = getRight(n)
    if c isa Node
        setPathParent!(c, n)
        setParent!(c, DummyNode{typeof(getVertex(c))}())
    end

    setRight!(n,r)
    if r isa Node
        setPathParent!(r,DummyNode{typeof(getVertex(r))}())
    end

end


"Moves n to the tree at the root of the link-cut tree using splay tree operations.
Preserves the represented tree, and n will be the deepest node on the preferred path."
function expose!(n::Node)

    splay!(n)
    replaceRightSubtree!(n)

    while getPathParent(n) isa Node
        p = getPathParent(n)
        splay!(p)
        replaceRightSubtree!(p,n)
        splay!(n)
    end
end

"Links two represented trees, where u is the root of one represented tree and becomes a child of v."
function link!(u::Node, v::Node)

    expose!(u)
    if getLeft(u) isa Node
        throw(ArgumentError("u must be the root of its represented tree to link."))
    end

    expose!(v)
    if getParent(u) isa Node || getPathParent(u) isa Node
        throw(ArgumentError("Can't link two nodes in the same represented tree"))
    end

    setPathParent!(u,v)
end

"Cuts the node u away from its parent in the represented tree.
u cannot be the root of the represented tree."
function cut!(u::Node)
    expose!(u)

    if !(getLeft(u) isa Node)
        throw(ArgumentError("can't cut the root of the represented tree."))
    end

    v = getLeft(u)

    setParent!(v,DummyNode{typeof(getVertex(u))}())
    setLeft!(u,DummyNode{typeof(getVertex(u))}())

end

"Changes the root of the represented tree to u."
function evert!(u::Node)
    expose!(u)

    u.reversed = true
end

# function undirected_tree(parents::AbstractVector{T}) where {T<:Integer}
#     n = T(length(parents))
#     t = Graph{T}(n)
#     for (v, u) in enumerate(parents)
#         if u > zero(T) && u != v
#             add_edge!(t, u, v)
#         end
#     end
#     return t
# end
