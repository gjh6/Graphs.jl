"""
    linked_cut_tree(g)

Returns a linked_cut_tree data structure from a graph that is a tree https://dl.acm.org/doi/10.1145/3828.3835

This function does not apply to directed graphs. Directed trees are sometimes called [polytrees](https://en.wikipedia.org/wiki/Polytree)). 

"""
function linked_cut_tree end

@traitfn function linked_cut_tree(g::::(!IsDirected))
    @assert ne(g) == nv(g) - 1 && is_connected(g)

    return 
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
