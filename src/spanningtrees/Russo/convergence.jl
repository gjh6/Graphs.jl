

"""
    HConvergence(g::AbstractGraph, dstmx=weights(g))

Return the convergence time (with Russo's algorithm, (https://www.mdpi.com/1999-4893/11/4/53) of g, 
an undirected connected graph with weights distmx. Will print the error and steps taken once every 100 steps. 

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
                    #err = 0
                    #for i in 1:nv(g)
                        err = simple_variance(hists[chain1,tree_ind,:],num_intervals,
                                hists[chain2,tree_ind,:],num_intervals)
                        #err += (abs(hists[chain1,tree_ind,i]-hists[chain2,tree_ind,i])/2)/num_intervals
                    #end
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

function simple_variance(x::AbstractArray{U},entriesX::Int,y::AbstractArray{U},entriesY::Int) where {U}
    err = 0
    for i in eachindex(x)
        err += abs(((x[i]/entriesX) - (y[i]/entriesY))/2)
    end
    return err
end

function simple_variance(x::AbstractArray{U},y::AbstractArray{U}) where {U}
    entriesX = accumulate(+,x)
    entriesX = entriesX[lastindex(entriesX)]

    entriesY = accumulate(+,y)
    entriesY = entriesY[lastindex(entriesY)]

    err = 0
    for i in eachindex(x)
        err += abs(((x[i]/entriesX) - (y[i]/entriesY))/2)
    end
    return err
end

"""
    TConvergence(g::AbstractGraph, t::Int, distmx=weights(g)

Return the maximum error between any two distributions of spanning trees generated 
on undirected connected graph g. Trees are generated with Russo's algorithm 
(https://www.mdpi.com/1999-4893/11/4/53), run for t steps. 

###Optional Arguments
-`distmx=weights(g)`:  a symmetric matrix representing the weights of the graph g. Leave blank for unweighted graphs.
-`error=.01`: the maximum error allowed between two distributions from the same starting tree before the distribution
                is considered to be a good enough estimate.
- `rng=MersenneTwister()`: the rng used throughout the function.
-`numTrees=20`: a number between 2 and 20 (inclusive), the number of different distributions that will be estimated
-`avgE=false`: if true, take the average of errors between all distributions, instead of the maxiumum.
"""
function TConvergence(g::AbstractGraph, t::Int, distmx=weights(g); 
    error::Float64=.01,rng=MersenneTwister(),numTrees::Int=20, avgE::Bool=false)

    refTrees = ref_trees(g,distmx,rng=rng)
    startTrees = refTrees[1:numTrees]
    R = refTrees[20]

    hists = zeros(numTrees,3,nv(g))

    for tree_ind in 1:numTrees
        sampled = 0
        cur_err = typemax(Float64)
        while cur_err > error
            for i in 1:2
                x = russo_ust(g,distmx,steps=t,startingTree=startTrees[tree_ind],rng=rng)
                x = SimpleDiGraphFromIterator(x)
                hists[tree_ind,i,edge_distance(x,R)+1] += 1
            end
            sampled += 1
            min_sample = nv(g)*100
            if sampled > min_sample
                cur_err = simple_variance(hists[tree_ind,1,:], sampled,
                                hists[tree_ind,2,:], sampled)
            end
        end
        println(tree_ind,": ",sampled, " ", cur_err)
        hists[tree_ind,3,:] = hists[tree_ind,1,:] + hists[tree_ind,2,:]
    end

    max_err = 0
    for dist1 in 1:numTrees
        for dist2 in dist1+1:numTrees
            err = simple_variance(hists[dist1,3,:],hists[dist2,3,:])
            if avgE
                #treats max_err as total error
                max_err+= err
            else
                max_err = max(max_err,err)
            end
        end
    end
    if avgE
        max_err = max_err/numTrees
    end
    return max_err
end