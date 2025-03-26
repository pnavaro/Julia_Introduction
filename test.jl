using Random, LinearAlgebra, BenchmarkTools

function test(A, B, C)
    return C - A * B
end

A = rand(1024, 256); B = rand(256, 1024); C = rand(1024, 1024)

@btime test($A, $B, $C)
