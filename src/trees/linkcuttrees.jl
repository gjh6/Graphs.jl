"""
    link_cut_tree(g)

Returns a link_cut_tree data structure from a graph that is a tree or forest of trees https://dl.acm.org/doi/10.1145/3828.3835

This function does not apply to directed graphs. Directed trees are sometimes called [polytrees](https://en.wikipedia.org/wiki/Polytree)). 

"""
function link_cut_tree end

@traitfn function link_cut_tree(g::::(!IsDirected))
    @assert ne(g) == nv(g) - 1 && is_connected(g)

    return 
end


#Link Cut Functions:
struct linkCutForest{T<:Integer}
    #nodes should be ordered- the first node is vertex 1, etc.
    nodes::AbstractArray{AbstractNode}




end


"Returns a vector of integers, each entry i indicating the index of the parent of the node at index i."
function parents(f::linkCutForest{T}) where {T<:Integer}
    nodes = copy(f.nodes)
    p = Vector{T}(undef,length(f.nodes))

    while length(nodes) > 0
        r = findSplayRoot(nodes[1])
        s = traverseSubtree(r)
        if getPathParent(r) isa Node
            p[getVertex(s[1])] = getVertex(getPathParent(r))
        else
            p[getVertex(s[1])] = getVertex(s[1])
        end
        
        for i in 2:lastindex(s)
            p[getVertex(s[i])] = getVertex(s[i-1])
        end

        setdiff!(nodes,s)        

    end

    return p

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
