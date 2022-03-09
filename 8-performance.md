# Performance

*Julia* avec la compilation *Just-In-Time* est un langage naturellement performant. Il n'est pas allergique aux boucles comme le sont les langages Python et R. Les opérations vectorisées fonctionnent également très bien à condition d'être attentifs aux allocations mémoire et aux vues explicites.


## Allocations

```julia
using Random, LinearAlgebra, BenchmarkTools

function test(A, B, C)
    C = C - A * B
    return C
end

A = rand(1024, 256); B = rand(256, 1024); C = rand(1024, 1024)

@btime test($A, $B, $C);
```

Dans l'appel de la macro `@benchmark` on interpole les arguments avec le signe `$` pour être sur que les fonctions
    `rand` aient déjà été evaluées avant l'appel de la fonction `test`. La matrice `C` est modifiée dans la fonction suivante donc par convention on ajoute un `!` au nom de la fonction. Par convention également, l'argument modifié se placera en premier. Comme dans la fonction `push!` par exemple.

```julia
function test!(C, A, B)
    C .-= A * B
    return C
end

@btime test!( $C, $A, $B);
```

En effectuant une opération "en place", on supprime une allocation mais celle pour effectuer l'opération `A * B` est toujours nécessaire. On peut supprimer cette allocation en utilisant la bibliothèque `BLAS`, cependant le code perd en lisibilité ce qu'il a gagné en performance.

```julia
function test_opt!(C, A, B)
    BLAS.gemm!('N','N', -1., A, B, 1., C)
    return C
end

@btime test_opt!($C, $A, $B);
```

## Alignement de la mémoire

Les opérations le long des premiers indices seront plus rapides que l'inverse.

```julia
using FFTW

T = randn(1024, 1024)

@btime fft(T, 1);
```

```julia
@btime fft(T, 2);
```

## Vues explicites

```julia
@btime sum(T[:,1]) # Somme de la première colonne
```

```julia
@btime sum(view(T,:,1))  
```

## Eviter les calculs dans l'environnement global.

```julia
v = rand(1000)

function somme()
    acc = 0
    for i in eachindex(v) 
        acc += v[i]
    end
    acc
end

@btime somme()

```

Il faut écrire des fonctions

```julia
function somme( x )
    acc = 0
    for i in eachindex(x) 
        acc += x[i]
    end
    acc
end

@btime somme( v )
    
```

```julia

```
