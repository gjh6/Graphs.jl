using Graphs
using Graphs.Russo: russo_ust
using Profile
using LinearAlgebra
using Random


"""
    mixing_data(
        g::AbstractGraph, distmx::AbstractMatrix, minsteps::Integer,maxsteps::Integer,interval::Integer
        filename::AbstractString)

Given g, run numtests tests to determine the error from the correct weighted distribution of the Markov chain
from the russo_ust algorithm given mixing times distributed evenly between minsteps and maxsteps.
output the result of each test in a line to filename, in the format:
steps error
"""
#WARNING: currently, this tests takes an untenable amount of time. I'm not sure what to do about it, honestly.
function mixing_data(
    g::AbstractGraph, distmx::AbstractMatrix, minsteps::Integer,maxsteps::Integer,numtests::Integer, 
    filename::AbstractString) 

    stream = open(filename, "a")

    stepInterval = floor(Integer,(maxsteps-minsteps)/(numtests-1))
    cursteps = minsteps
    for i in 0:numtests-1
        error = round(TConvergence(g,cursteps,distmx,numTrees=20,error=.05),digits=3)
        println(stream, cursteps, " ", error)
        cursteps += stepInterval
        println("finished test ", i+1, " of ", numtests)
    end

    close(stream)

end

s = ladder_graph(4)
c = cycle_graph(10)


#mixing_data(s,weights(s),100,400,10,"russo_data1.mkd")
"""
Profile.clear()
Profile.init(n = 10^8, delay = 0.1)
@profile mixing_data(c,weights(c),0,200,5,"russo_data1.mkd")
Profile.print(noisefloor=2.0,maxdepth=10)
"""

sparse0 = ladder_graph(10)
sparse1 = ladder_graph(15)
sparse2 = ladder_graph(20)
sparse3 = ladder_graph(25)
sparse4 = ladder_graph(30)
sparse5 = ladder_graph(35)
sparse6 = ladder_graph(40)

rng = MersenneTwister()

#mixing_data(sparse1,weights(sparse1),0,350,8,"russo_data_sparse.mkd")
wmatrix = zeros(Float64,size(weights(sparse6)))
        for edge in edges(sparse6)
            wmatrix[src(edge),dst(edge)] = rand(rng)*2
        end
        wmatrix = Symmetric(wmatrix)

mixing_data(sparse6,wmatrix,0,350,8,"russo_data_sparse_rdweights.mkd")