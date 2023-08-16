"""
    russo_ust(g, distmx=weights(g))

Return a vector of edges representing a uniform spanning tree (potentially weighted)
of an undirected graph `g` with optional distance matrix (or weights) `distmx` using [Russo's algorithm](https://www.mdpi.com/1999-4893/11/4/53).

### Optional Arguments
- `steps=nothing`: gives the heuristic presented in the reference above otherwise specify with an int
- `distmx=weights(g)`: matrix of weights of g
- `startingTree=dfs_tree(g)`: any tree (can be directed), which will be modified as in Russo's algorithm.
- `rng=MersenneTwister()`: An AbstractRNG object used for all random choices.
"""

function russo_ust end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function russo_ust(
    g::AG::(!IsDirected); steps::Union{Nothing, Int}=nothing, distmx::AbstractMatrix{T}=weights(g),
    startingTree=dfs_tree(g,1), rng::AbstractRNG=MersenneTwister()
) where {T<:Real,U,AG<:AbstractGraph{U}}

    if is_cyclic(startingTree)
        throw(ArgumentError("startingTree must be a tree"))
    end

    if !is_directed(startingTree)
        startingTree = dfs_tree(startingTree, 1)
    end

    if steps === nothing
        steps = round(nv(g)^1.3 + ne(g))
    end

    ust = link_cut_tree(startingTree)

    #choosing randomly from a set is more efficient
    g_edges = Set(edges(g))

    #in each step:
    for i in 1:steps
        #choose an edge e=(u,v) in g uniformly at random
        e = rand(rng,g_edges)
        u = ust.nodes[src(e)]
        v = ust.nodes[dst(e)]
        # get a path from u to v
        Russo.evert!(u)
        Russo.expose!(v)
        D = Russo.findPath(v)
        #if e is in ust already, move on.
        if length(D) == 2
            continue
        end
        # from v, find parents [v to parent, + parent to next parent, cum + next weight, ..., sum of the weights]
        pathWeights = Float64[0]
        cumWeight = 0
        for n in 2:lastindex(D)
            w = distmx[Russo.getVertex(D[n])]
            cumWeight += (1/w)
            append!(pathWeights,[cumWeight])
        end
        # randSamp = rand()*sum of the weights
        randSamp = rand(rng)*pathWeights[lastindex(pathWeights)]
        for i in 1:lastindex(pathWeights)
            if (randSamp > pathWeights[i]) && (randSamp <= pathWeights[i+1])
                Russo.cut!(D[i+1])
                Russo.evert!(v)
                Russo.link!(v,u)
                break
            end
        end
    end

    #convert the link-cut tree back into a vector of edges for output
    edgeVector = edgetype(g)[]
    parents = Russo.parents(ust)
    for edge in edges(g)
        if parents[dst(edge)] == src(edge) || parents[src(edge)] == dst(edge)
            append!(edgeVector,[edge])
        end
    end
    return edgeVector
end