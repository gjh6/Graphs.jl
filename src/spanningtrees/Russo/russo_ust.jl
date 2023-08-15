"""
    russo_ust(g, distmx=weights(g))

Return a vector of edges representing a uniform spanning tree (potentially weighted)
of an undirected graph `g` with optional distance matrix (or weights) `distmx` using [Russo's algorithm](https://www.mdpi.com/1999-4893/11/4/53).

### Optional Arguments
- `steps=nothing`: gives the heuristic presented in the reference above otherwise specify with an int
- `distmx=weights(g)`: matrix of weights of g
- `startingTree=dfs_tree(g)`: any tree (can be directed), which will be modified as in Russo's algorithm.
"""

function russo_ust end
@traitfn function russo_ust(
    g::AG; steps::Union{Nothing, Int}=nothing, distmx::Union{AbstractMatrix{T}, Graphs.DefaultDistance}=weights(g),
    startingTree::AbstractGraph{U}=dfs_tree(g,1)
) where {T,U,AG<:AbstractGraph{U}; !IsDirected{AG}}


    if is_cyclic(startingTree)
        throw(ArgumentError("startingTree must be a tree"))
    end

    if !is_directed(startingTree)
        startingTree = dfs_tree(startingTree, 1)
    end

    if steps === nothing
        steps = nv(g)^1.3 + ne(g)
    end

    b = distmx

    ust = link_cut_tree(startingTree)

    # get a path from u to v
    # from v, find parents [v to parent, + parent to next paretn, cum + next weight, ..., sum of the weights]
    # randSamp = rand()*sum of the weights
    # binary search to find interval

    edgeVector = edgetype(g)[]
    parents = Russo.parents(ust)
    for edge in edges(g)
        if parents[dst(edge)] == src(edge)
            append!(edgeVector,[edge])
        end
    end
    return edgeVector
end