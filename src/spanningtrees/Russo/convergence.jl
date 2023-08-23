

"""
    HConvergence(g::AbstractGraph, dstmx=weights(g))

Return the convergence time (with Russo's algorithm, (https://www.mdpi.com/1999-4893/11/4/53) of g, 
an undirected graph with weights distmx. Will print the error and steps taken once every 100 steps. 

### Optional Arguments
- `distmx=weights(g)`: a symmetric matrix representing the weights of the graph g. Leave blank for unweighted graphs.
- `interval=1`: the number of steps taken on the chain before it is measured. Higher inteveral will 
                improve runtime, especially with large g, but the estimate of the distribution at each 
                100 steps will have essentially a lower resolution.
- `error=.05`: the maximum possible variation distance allowed between any two chains' distributions,
                when convergence is declared.
- `rng=MersenneTwister()`: the rng used throughout the function.
"""
function HConvergence(
    g::AbstractGraph, distmx=weights(g); interval::Int=1, error::Float64=.05,rng=MersenneTwister())

    refTrees = ref_trees(g,distmx,rng=rng)
    chains = refTrees[1:4]

    hists = zeros(4,20,nv(g))

    num_intervals = 0
    steps = 0

    cur_error = typemax(Float64)
    while cur_error > error
        #take 100 steps, updating the distributions every interval steps.
        for i in 1:100
            steps+=1
            if i % interval == 0
                num_intervals += 1
                for chain_ind in eachindex(chains)
                    chains[chain_ind] = SimpleDiGraphFromIterator(
                        russo_ust(g,distmx,steps=interval,startingTree=chains[chain_ind],rng=rng))
                    
                    for ref_tree_ind in 1:20
                        d = edge_distance(chains[chain_ind],refTrees[ref_tree_ind])
                        hists[chain_ind,ref_tree_ind,d+1]+=1
                    end
                end

            end
        end
        max_err = 0
        for tree_ind in 1:20
            for chain1 in 1:4
                for chain2 in chain1+1:4
                    err = 0
                    for i in 1:nv(g)
                        err += (abs(hists[chain1,tree_ind,i]-hists[chain2,tree_ind,i])/2)/num_intervals
                    end
                    max_err = max(max_err,err)
                end
            end
        end
        println(steps," steps taken, error is ",max_err)
        cur_error = max_err
    end
    return steps
end


function ref_trees(g,distmx=weights(g); rng=MersenneTwister())
    trees = SimpleDiGraph[]

    for i in 1:20
        weights = zeros(Float64,size(distmx))
        for edge in edges(g)
            weights[src(edge),dst(edge)] = rand(rng)*distmx[src(edge),dst(edge)]
        end
        weights = Symmetric(weights)

        tree = kruskal_mst(g,weights,minimize=false)

        append!(trees,[SimpleDiGraphFromIterator(tree)])

    end

    return trees
end

function edge_distance(s, ref)
    ne(difference(s,ref)) 
end