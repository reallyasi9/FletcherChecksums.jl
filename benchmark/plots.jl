using BenchmarkTools
using Checksums
using Random
using CairoMakie
import Libz

adler32_libz(data) = Libz.adler32(data)

function benchmark(f, n)
    data = rand(MersenneTwister(42), UInt8, n)
    return @belapsed ($f)($data)
end

function benchmark_plot(fs)
    with_theme(
        Theme(
            Lines = (cycle = Cycle([:color, :linestyle], covary=true),),
        )
    ) do
        ns = [1<<i for i in 0:20]
        fig = Figure(size=(800,600))
        ax = Axis(fig[1,1], xscale=log2, yscale=log10, xlabel="input size", ylabel="time (s)")
        for f in fs
            times = [benchmark(f, i) for i in ns]
            lines!(ax, ns, times, label=string(f))
        end
        fig[1,2] = Legend(fig, ax, "Checksum", framevisible = false)
        fig
    end
end

function write_benchmark_plot()
    functions = (additive16, additive32, additive64, adler32, bsd16, fletcher16, fletcher32, fletcher64, sysv16, adler32_libz)
    fig = benchmark_plot(functions)
    save("benchmarks.svg", fig)
    fig
end