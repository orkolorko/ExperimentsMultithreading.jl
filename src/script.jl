using FastBroadcast, ThreadsX, BenchmarkTools

@inline f(x) = 3.43 * x * (1-x)

function athreads!(f::F, y, x) where {F}
    Threads.@threads for i in eachindex(y, x)
        @inbounds y[i] = f(x[i])
    end
end

x = rand(10^6);
y = similar(x);

@benchmark $y = f.($x)
@benchmark athreads!(f, $y, $x)
@benchmark ThreadsX.map!(f, $y, $x)
@benchmark @.. thread=true $y=f($x)

@benchmark sum($y)
@benchmark ThreadsX.sum($y)


using LoopVectorization

@benchmark @tturbo @. $y = f($x)
#@benchmark @tturbo @. $y = exp($x)

function sum_single(a)
    s = 0
    for i in a
        s += i
    end
    s
end

function sum_multi_good(a)
    chunks = Iterators.partition(a, length(a) ÷ Threads.nthreads())
    tasks = map(chunks) do chunk
        Threads.@spawn sum_single(chunk)
    end
    chunk_sums = fetch.(tasks)
    return sum_single(chunk_sums)
end

function iterate!(y, x, temp; ϵ = 0.01 )
    N = length(x)
    map!(f, temp, x)
    #@info "test"
    h = sum(temp)/N
    map!(a -> (1-ϵ) * a + ϵ * h, y, temp)
end


g(a, h, ϵ) = (1-ϵ) * a + ϵ * h

function iterate!(y, x, temp; ϵ = 0.01 )
    N = length(x)
    map!(f, temp, x)
    #@info "test"
    h = sum(temp)/N
    map!(a -> (1-ϵ) * a + ϵ * h, y, temp)
end

function iterate_threads!(y, x, temp; ϵ = 0.01 )
    N = length(x)
    ThreadsX.map!(f, temp, x)
    h = ThreadsX.sum(temp)/N
    ThreadsX.map!(a -> (1-ϵ) * a + ϵ * h, y, temp)
end


function iterate_threads_2!(y, x, temp; ϵ = 0.01 )
    N = length(x)
    #ThreadsX.map!(f, temp, x)
    @.. thread=true temp=f(x)
    #h = sum_multi_good(temp)/N
    g_loc(a) = g(a, h, ϵ)
    @.. thread=true y=g_loc(temp)
end
