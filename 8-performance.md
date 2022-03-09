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

Voici un autre exemple ou on calcule la dérivée de la quantité $f$ suivant la coordonnée $y$ en passant par l'espace de Fourier

```julia
using FFTW

xmin, xmax, nx = 0, 4π, 1024
ymin, ymax, ny = 0, 4π, 1024
x = LinRange(xmin, xmax, nx+1)[1:end-1]
y = LinRange(ymin, ymax, ny+1)[1:end-1]
ky  = 2π ./ (ymax-ymin) .* [0:ny÷2-1;ny÷2-ny:-1]
exky = exp.( 1im .* ky' .* x)
function df_dy( f, exky )
    ifft(exky .* fft(f, 2), 2)
end
f = sin.(x) .* cos.(y') # f is a 2d array created by broadcasting
@btime df_dy($f, $exky);
```

En utilisant les "plans" de FFTW qui permettent de pré-allouer la mémoire nécessaire et le calcul "en place". On peut améliorer les performances. On réutilise le même tableau pour la valeur de $f$ et sa transformée de Fourier. On prend soin également de respecter l'alignement de la mémoire en transposant le tableau contenant $f$ pour calculer la FFT. On utilise plus de mémoire, on fait plus de calcul en ajoutant les transpositions mais finalement le calcul va 3 fois plus vite car on évite les allocations et on limite les accès mémoire.

```julia
f  = zeros(ComplexF64, (nx,ny))
fᵗ = zeros(ComplexF64, reverse(size(f)))
f̂ᵗ = zeros(ComplexF64, reverse(size(f)))
f .= sin.(x) .* cos.(y')
fft_plan = plan_fft(fᵗ, 1, flags=FFTW.PATIENT)
function df_dy!( f, fᵗ, f̂ᵗ, exky )
    transpose!(fᵗ,f)
    mul!(f̂ᵗ,  fft_plan, fᵗ)
    f̂ᵗ .= f̂ᵗ .* exky
    ldiv!(fᵗ, fft_plan, f̂ᵗ)
    transpose!(f, fᵗ)
end
@btime df_dy!($f, $fᵗ, $f̂ᵗ, $exky );
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

Pour comprendre pourquoi l'utilisation de variable global influence les performances, prenons un exemple simple d'une fonction additionnant deux nombres:

```julia
variable = 10

function addition_variable_globale(x)
    x + variable
end

@btime addition_variable_globale(10)
```

Comparons la performance avec cette fonction qui retourne la somme de ses deux arguments

```julia
function addition_deux_arguments(x, y)
    x + y
end

@btime addition_deux_arguments(10, 10)
```

On remarque que la deuxième fonction est 300 fois plus rapide que la première. Pour comprendre pourquoi elle est plus rapide, on peut regarder le code généré avant la compilation. On s'appercoit que le code est relativement simple avec une utilisation unique de l'instruction `add`.

```julia
@code_llvm addition_deux_arguments(10, 10)
```

Si on regarde le code généré utilisant la variable globale, on comprend rapidement pourquoi c'est plus long. Pourquoi le code est-il si compliqué ? Ici le langage ne connait pas le type de `variable`, il doit donc prendre en compte le fait que ce type puisse être modifié à tout moment. Comme tous les cas sont envisagés, cela provoque un surcoût important.

```julia
@code_llvm addition_variable_globale(10)
```

Il est donc possible d'améliorer la performance en fixant la valeur de la variable globale avec l'instruction `const`.

```julia
const constante = 10

function addition_variable_constante(x)
    x + constante
end

@btime addition_variable_constante(10)
```

On peut également fixer le type de cette variable. C'est mieux mais cela reste éloigné, en terme de performance, du résultat précedent.

```julia
function addition_variable_typee(x)
    x + variable::Int
end

@btime addition_variable_typee(10)
```

Pour régler notre problème de performance avec une variable globale, il faut la passer en argument dans la fonction.

```julia
function addition_variable_globale_en_argument(x, v)
    x + v
end
```

```julia
@btime addition_variable_globale_en_argument(10, $variable)
```


## Instabilité de type

Une fonction est de type stable lorsque vous pouvez déduire ce que doit être la sortie de la fonction. L'exemple ci-dessous rendra les choses plus claires. En règle générale, les fonctions de type stable sont plus rapides.


```julia
function carre_plus_un(v::T) where T <:Number
    g = v*v
    return g+1
end
```

```julia
v = rand()
```

```julia
@code_warntype carre_plus_un(v)
```

```julia
w = 5
```

```julia
@code_warntype carre_plus_un(w)
```

Sur les deux exemples précedents on peut déduire le type de sortie de la fonction.
```
function carre_plus_un(v::T) where T <:Number
    g = v*v         # Type(T * T) ==> T
    return g+1      # Type(T + Int)) ==> "max" (T,Int)
end

```
Le type de la valeur de retour peut être différent: `Float64` ou `Int64`. Mais la fonction est toujours stable.

Créons maintenant un nouveau type:

```julia
mutable struct Cube
    length
    width
    height
end
```

```julia
volume(c::Cube) = c.length*c.width*c.height
```

```julia
mutable struct Cube_typed
    length::Float64
    width::Float64
    height::Float64
end
volume(c::Cube_typed) = c.length*c.width*c.height
```

```julia
mutable struct Cube_parametric_typed{T <: Real}
    length::T
    width::T
    height::T
end
volume(c::Cube_parametric_typed) = c.length*c.width*c.height
```

```julia
c1 = Cube(1.1,1.2,1.3)
c2 = Cube_typed(1.1,1.2,1.3)
c3 = Cube_parametric_typed(1.1,1.2,1.3)
@show volume(c1) == volume(c2) == volume(c3)
```

```julia
using BenchmarkTools
@btime volume(c1) # not typed
@btime volume(c2) # typed float
@btime volume(c3) # typed parametric
```

The second and the third function calls are faster! Let's call `@code_warntype` and check type stability

```julia
@code_warntype volume(c1)
```

```julia
@code_warntype volume(c2)
```

```julia
@code_warntype volume(c3)
```

**Conclusion**: Les types en Julia sont importants donc si vous les connaissez, ajoutez-les, cela peut améliorer les performances.

```julia
function zero_or_val(x::Real)
    if x >= 0
        return x
    else
        return 0
    end
end
@code_warntype zero_or_val(0.2)
```

```julia
function zero_or_val_stable(x::Real)
    if x >= 0
        y = x
    else
        y = 0
    end
    T = promote_type(typeof(x),Int)
    return T(y)
end
@code_warntype zero_or_val_stable(0.2)
```

**Conclusion**: `promote_type` peut vous permettre de supprimer une instabilité de type en utilisant la réprésentation la plus haute dans l'abre des types.


Je vous propose le jeu suivant: Soit un vecteur de nombres. Calculons la somme comme suit. 
Pour chaque nombre du vecteur, on lance une pièce de monnaie (`rand()`), si c'est face (`>=0.5`), vous ajoutez `1`. Sinon, vous ajoutez le nombre lui-même.


```julia
function flipcoin_then_add(v::Vector{T}) where T <: Real
    s = 0
    for vi in v
        r = rand()
        if r >=0.5
            s += 1
        else
            s += vi
        end
    end
end

function flipcoin_then_add_typed(v::Vector{T}) where T <: Real
    s = zero(T)
    for vi in v
        r = rand()
        if r >=0.5
            s += one(T)
        else
            s += vi
        end
    end
end
myvec = rand(1000)
@show flipcoin_then_add(myvec) == flipcoin_then_add_typed(myvec)
```

```julia
@btime flipcoin_then_add(rand(1000))
@btime flipcoin_then_add_typed(rand(1000))
```

**Conclusion**: Think about the variables you are declaring. Do you know their types? If so, specify the type somehow.


### @code_XXX

Nous avons vu durant ce chapitre que regarder le code généré peut nous aider à améliorer les performances. Voici toutes les macros à votre disposition:

```julia
# @code_llvm 
# @code_lowered 
# @code_native 
# @code_typed 
# @code_warntype

function flipcoin(randval::Float64)
    if randval<0.5
        return "H"
    else
        return "T"
    end
end
```

```julia
@code_lowered flipcoin(rand()) # syntax tree
```

```julia
@code_warntype flipcoin(rand()) # try @code_typed
```

```julia
@code_llvm flipcoin(rand()) # this and code_warntype are probably the most relevant
```

```julia
@code_native flipcoin(rand())
```
