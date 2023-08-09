"""
    russo_ust(g, distmx=weights(g))

Return a vector of edges representing a uniform spanning tree (potentially weighted)
of an undirected graph `g` with optional distance matrix (or weights) `distmx` using [Russo's algorithm](https://www.mdpi.com/1999-4893/11/4/53).

### Optional Arguments
- `steps=nothing`: gives the heuristic presented in the reference above otherwise specify with an int
"""
function russo_ust end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function russo_ust(
    g::AG::(!IsDirected), distmx::AbstractMatrix{T}=weights(g); steps::Union{Nothing, Int}
) where {T<:Real,U,AG<:AbstractGraph{U}}
    if steps !== nothing
        steps = nv(g)^1.3 + ne(g)
    end

    ust = dfs_tree(g, 1)
    ust = linked_cut_tree(ust)

    # get a path from u to v
    # from v, find parents [v to parent, + parent to next paretn, cum + next weight, ..., sum of the weights]
    # randSamp = rand()*sum of the weights
    # binary search to find interval
    ust = Vector{edgetype(g)}()
    return ust
end
