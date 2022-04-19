# GPU

Le calcul sur GPU permet de calculer plus rapidement certaines opérations mathématiques.
Il est particulièrement bien adapté pour les opérations simples entre tableaux de grandes
dimensions. Il consiste à déporter les calculs sur la carte graphique puis récupérer les résultats.
Ces transferts de données ont un coût qu'il faudra prendre en compte lors de l'utilisation
de ces co-processeurs.

On importe quelques packages pour nos exemples

```julia
using BenchmarkTools
using Random
using Test
using LinearAlgebra
using ForwardDiff
using ProgressMeter
using Plots
```

Le package principal qui permet d'utiliser est `CUDA.jl`, il permet d'utiliser les cartes 
graphiques de la marque NVIDIA.

```julia
using CUDA

CUDA.version()
```

Lorsque vous installez `CUDA.jl`, une version du compilateur de NVIDIA sera également téléchargé
sur votre poste. Il est possible d'utiliser une installation existante, c'est expliqué dans la 
documentation.

Cette première fonction permet de vérifier que le package est correctement installé et que vous disposez
de la carte graphique adéquate.

```julia
CUDA.functional()
```

Vous pouvez également lister les matériels à votre disposition.

```julia
for device in CUDA.devices()
    @show capability(device)
    @show name(device)
end
```

Pour tester votre installation vous pouvez également regarder le package [GPUInspector.jl](https://pc2.github.io/GPUInspector.jl/dev/)

## Création de tableaux pour le GPU


### Allocations sur la carte graphique

```julia
a = CuArray{Float32,2}(undef, 2, 2)
```

```julia
similar(a)
```

```julia
a = CuArray([1,2,3])
```

## Transfert vers le CPU

`b` est alloué sur le CPU, et un transfert de données est effectué.

```julia
b = Array(a)
```

```julia
collect(a)
```

### Compatibilité avec les tableaux Julia

```julia
CUDA.ones(2)
```

```julia
a = CUDA.zeros(Float32, 2)
```

```julia
a isa AbstractArray
```

```julia
CUDA.fill(42, (3,4))
```

## Tirages aléatoires

```julia
CUDA.rand(2, 2)
```

```julia
CUDA.randn(2, 1)
```

```julia
x = CUDA.CuArray(0:0.01:1.0)
nt = length(x)
y = 0.2 .+ 0.5 .* x + 0.1 .* CUDA.randn(nt);
scatter( Array(x), Array(y))
plot!( x -> 0.2 + 0.5x)
xlims!(0,1)
ylims!(0,1)
```

```julia
X = hcat(CUDA.ones(nt), x);
```

```julia
β = X'X \ X'y
```

```julia
sum( ( β[1] .+ β[2] .* x .- y).^2 )
```

```julia
a = CuArray([1 2 3])
```

```julia
view(a, 2:3)
```

```julia
a = CuArray{Float64}([1 2 3])
b = CuArray{Float64}([4 5 6])

map(a) do x
    x + 1
end
```


```julia
reduce(+, a)
```


```julia
accumulate(+, b; dims=2)
```


```julia
findfirst(isequal(2), a)
```


```julia
a = CuArray([1 2 3])
b = CuArray([4 5 6])

map(a) do x
    x + 1
end

a .+ 2b

reduce(+, a)

accumulate(+, b; dims=2)

findfirst(isequal(2), a)
```


# CURAND

```julia
CUDA.rand!(a)
```

# CUBLAS

Les opérations entre tableaux alloués sur le GPU sont effectués sur le co-processeur.

```julia
a * b'
```

# CUSOLVER

Certaines fonctions d'algèbre linéaire de LAPACK sont disponibles:

```julia
L, ipiv = CUDA.CUSOLVER.getrf!(a'b)
CUDA.CUSOLVER.getrs!('N', L, ipiv, CUDA.ones(Float64, 3))
```

# CUFFT

Pour faire des FFTs sur le GPU, il est nécessaire d'utiliser les `plans` pour allouer l'espace nécessaire sur la carte graphique.

```julia
fft = CUFFT.plan_fft(a) 
fft * a
```

```julia
ifft = CUFFT.plan_ifft(a)
real(ifft * (fft * a))
```

# CUDDN

Vous avez également accès à la bibliothèque NVIDIA pour les réseaux de neurones.

```julia
CUDA.CUDNN.softmax(real(ans))
```

# CUSPARSE

Les formats destinés aux matrices creuses sont aussi disponibles.

```julia
CUDA.CUSPARSE.CuSparseMatrixCSR(a)
```

## Workflow

Les étapes pour porter votre code sur GPU

1. Développez votre application sur votre CPU avec les tabeaux de type `Array`
2. port your application to the GPU by switching to the CuArray type
3. disallow the CPU fallback ("scalar indexing") to find operations that are not implemented for or incompatible with GPU execution
4. (optional) use lower-level, CUDA-specific interfaces to implement missing functionality or optimize performance


## Exemple avec une regression linéaire

```julia
# squared error loss function
loss(w, b, x, y) = sum(abs2, y - (w*x .+ b)) / size(y, 2)
# get gradient w.r.t to `w`
loss∇w(w, b, x, y) = ForwardDiff.gradient(w -> loss(w, b, x, y), w)
# get derivative w.r.t to `b` (`ForwardDiff.derivative` is
# used instead of `ForwardDiff.gradient` because `b` is
# a scalar instead of an array)
lossdb(w, b, x, y) = ForwardDiff.derivative(b -> loss(w, b, x, y), b)
```

```julia
# proximal gradient descent function
function train(w, b, x, y; lr=0.1)
    w -= lmul!(lr, loss∇w(w, b, x, y))
    b -= lr * lossdb(w, b, x, y)
    return w, b
end
```

Version CPU

```julia
function cpu_test(n = 1000, p = 100, iter = 100)
    x = randn(n, p)'
    y = sum(x[1:5,:]; dims=1) .+ randn(n)' * 0.1
    w = 0.0001 * randn(1, p)
    b = 0.0
    for i = 1:iter
       w, b = train(w, b, x, y)
    end
    return loss(w,b,x,y)
end
```

```julia
@time cpu_test()
```

### Version GPU

```julia
function gpu_test( n = 1000, p = 100, iter = 100)
    x = randn(n, p)'
    y = sum(x[1:5,:]; dims=1) .+ randn(n)' * 0.1
    w = 0.0001 * randn(1, p)
    b = 0.0
    x = CuArray(x)
    y = CuArray(y)
    w = CuArray(w)
    
    for i = 1:iter
       w, b = train(w, b, x, y)
       
    end
    return loss(w,b,x,y)
end
```

```julia
@time gpu_test()
```

```julia
@btime cpu_test( 10000, 100, 100)
```

```julia
@btime gpu_test( 10000, 100, 100);
```

# Noyaux CUDA

L'écriture directe de noyaux CUDA est possible, cependant:
- les allocations sont interdites,
- pas d'entrées-sorties donc pas d'affichage,
- si votre code n'est pas typé correctement, le code compilé sera peu performant.

Programmer vos noyaux de manière incrémentale, en les gardant le plus simple possible et en vérifiant
soigneusement que le résultat escompté est correct.

```julia
a = CUDA.zeros(1024)

function kernel(a)
    i = threadIdx().x
    a[i] += 1
    return
end

@cuda threads=length(a) kernel(a)
```

```julia
a = CUDA.rand(Int, 1000)
```

```julia
norm(a)
```

```julia
@btime norm($a)
```


```julia
@btime norm($(Array(a)))
```

La fonction `norm` est bine plus rapide exécutée sur le CPU

```julia
CUDA.allowscalar(false)
```

```julia
a = CuArray(1:9_999_999);
```

```julia
@time a .+ reverse(a);
```

Pour effectuer cette dernière instruction, vous avez besoin de programmer deux noyaux.
La macro `@time` n'est pas adéquate pour évaluer la performance car on a affaire à une opération de type "lazy". C'est à dire que l'expression est programmée sur le GPU mais pas exécutée. Elle le sera lorsque vous transférerez le résultat vers le CPU. Vous pouvez utiliser `@sync` ou
`@time` du package `CUDA`.

```julia
@time CUDA.@sync a .+ reverse(a);
```

```julia
CUDA.@time a .+ reverse(a);
```

```julia
@btime CUDA.@sync $a .+ reverse($a);
```

```julia
@btime CUDA.@sync $(Array(a)) .+ reverse($(Array(a)));
```

## Aide au développement

Vous avez quelques macros disponibles pour vous aidez à implémenter vos noyaux:

```julia
kernel() = (@cuprintln("foo"); return)
```

```julia
@cuda kernel()
```

```julia
kernel() = (@cuprintln("bar"); return)
```

```julia
@cuda kernel()
```

Attention, exécuter plusieurs noyaux CUDA à la suite prend du temps car il y a un temps de lattence
plus important que sur CPU.

```julia
a = CuArray(1:9_999_999)
c = similar(a)
c .= a .+ reverse(a);
```

```julia
function vadd_reverse(c, a, b)
    i = threadIdx().x
    if i <= length(c)
        @inbounds c[i] = a[i] + reverse(b)[i]
    end
    return
end
```

Essayons de remplacer la fonction `reverse`

```julia
function vadd_reverse(c, a, b)
    
    i = threadIdx().x
    if i <= length(c)
        @inbounds c[i] = a[i] + b[end - i + 1]
    end
    return
end
```

Cela ne fonctionne pas car on n'itère pas sur un tableau alloué sur un GPU de la même manière qu'un tableau alloué sur CPU.


```julia
@cuda threads = length(a) vadd_reverse(c, a, a)
```

Les fonctions `blockIdx` et `threadIdx` sont disponibkes pour vous aider:

```julia
attribute(device(), CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK)
```

```julia
function vadd_reverse(c, a, b)
    i = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if i <= length(c)
        @inbounds c[i] = a[i] + b[end - i + 1]
    end
    return
end
```

Le noyau construit est plus rapide que la fonction `reverse` initialement utilisée:

```julia
@btime CUDA.@sync @cuda threads=1024 blocks=length($a)÷1024+1 vadd_reverse($c, $a, $a)
```

```julia
@btime CUDA.@sync $a .+ reverse($a);
```

Vous pouvez automatiser la configuration du noyau aux caractéristiques de votre carte.

```julia
function configurator(kernel)
    config = launch_configuration(kernel.fun)
    threads = min(length(a), config.threads)
    blocks = cld(length(a), threads)
    return (threads=threads, blocks=blocks)
end
```

```julia
@cuda config=configurator vadd_reverse(c, a, a)
```

