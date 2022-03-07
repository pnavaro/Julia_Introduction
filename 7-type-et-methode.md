---
jupyter:
  jupytext:
    cell_metadata_json: true
    encoding: '# -*- coding: utf-8 -*-'
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.13.7
  kernelspec:
    display_name: Julia 1.1.0
    language: julia
    name: julia-1.1
---

# Type et méthodes

JULIA possède un système de type et de méthode qui lui confère une approche objet.
La fonction typeof() renvoie le type d'une variable de base Int32, Float64... JULIA est conçu pour permettre facilement d'étendre l'environnement à de nouveaux type de variable.

Le types sont organisés suivant un hiérarchie comme on peut le voir sur l'arborescence partielle ci-dessous

(arborescence générée à l'aide de https://github.com/tanmaykm/julia_types/blob/master/julia_types.jl)

<!-- #raw -->

<!-- #endraw -->
```julia title="- Any << abstract immutable size:0 >>"
# .  +- Number << abstract immutable size:0 >>
# .  .  +- Complex128 = Complex{Float64} << concrete immutable pointerfree size:16 >>
# .  .  +- Complex = Complex{Float32} << concrete immutable pointerfree size:8 >>
# .  .  +- Complex64 = Complex{Float32} << concrete immutable pointerfree size:8 >>
# .  .  +- Complex32 = Complex{Float16} << concrete immutable pointerfree size:4 >>
# .  .  +- Real << abstract immutable size:0 >>
# .  .  .  +- Rational = Rational{T<:Integer} << concrete immutable size:16 >>
# .  .  .  +- FloatingPoint << abstract immutable size:0 >>
# .  .  .  .  +- Float32 << concrete immutable pointerfree size:4 >>
# .  .  .  .  +- BigFloat << concrete mutable pointerfree size:32 >>
# .  .  .  .  +- Float64 << concrete immutable pointerfree size:8 >>
# .  .  .  .  +- Float16 << concrete immutable pointerfree size:2 >>
# .  .  .  +- Integer << abstract immutable size:0 >>
# .  .  .  .  +- Signed << abstract immutable size:0 >>
# .  .  .  .  .  +- Int8 << concrete immutable pointerfree size:1 >>
# .  .  .  .  .  +- Int16 << concrete immutable pointerfree size:2 >>
# .  .  .  .  .  +- Int128 << concrete immutable pointerfree size:16 >>
# .  .  .  .  .  +- Int64 << concrete immutable pointerfree size:8 >>
# .  .  .  .  .  +- Int = Int64 << concrete immutable pointerfree size:8 >>
# .  .  .  .  .  +- Int32 << concrete immutable pointerfree size:4 >>
# .  .  .  .  +- BigInt << concrete mutable pointerfree size:16 >>
# .  .  .  .  +- Unsigned << abstract immutable size:0 >>
# .  .  .  .  .  +- Uint = Uint64 << concrete immutable pointerfree size:8 >>
# .  .  .  .  .  +- Uint8 << concrete immutable pointerfree size:1 >>
# .  .  .  .  .  +- Uint32 << concrete immutable pointerfree size:4 >>
# .  .  .  .  .  +- Uint16 << concrete immutable pointerfree size:2 >>
# .  .  .  .  .  +- Uint128 << concrete immutable pointerfree size:16 >>
# .  .  .  .  .  +- Uint64 << concrete immutable pointerfree size:8 >>
#
```

Remarquez "abstract" et "concrete" dans cette arborescence.

# Méthodes

A chaque fonction est associée une méthode dépendante du type d'entrée comme dans ce qui suit suivant que l'entrée soit un entier ou pas.

```julia
function f(x::Any)
    sin(x+1)
end
```

```julia
function f(n::Integer)
    n
end
```

```julia
f(3.0)
```

```julia
f(3)
```

```julia
f(im)
```

```julia
f(-2)
```

```julia
+
```

```julia
+(1,2)
```

```julia
f(sqrt(2))
```

# Construction d'un nouveau Type de variable

En premier lieu il faut définir un type abstrait puis une instance sous-hiérarchiquement concrète :

```julia
abstract type Grid end # juste en dessous de Any
mutable struct Grid1d <: Grid
    debut::Float64
    fin::Float64
    n::Int32
end
```

```julia
a=Grid1d(0,1,2)
```

```julia
a.debut
```

```julia
a.fin
```

```julia
a.n
```

# Surcharge des opérateurs

La surcharge des opérations usuelles se fait en définissant une nouvelle méthode associé au nouveau type pour chaque opérateur, commençons par surcharger l'affichage à l'écran de notre nouveau type. Pour cela on va ajouter une méthode à la fonction "show"

```julia
function Base.show(io::IO,g::Grid1d)
    print(io, "Grid 1d : début $(g.debut) , fin $(g.fin) , $(g.n) éléments\n")
end
```

```julia
Base.show(a)
```

```julia
println(a)
```

```julia
a
```

## Addition, soustraction ...

Ces fonctions sont de la forme +(), -() c'est à dire

```julia
import Base:+
function +(g::Grid1d,n::Integer)
    g.n +=n
    return g
end
```

```julia
a=Grid1d(0,1,2)
```

```julia
a+2
```

```julia
a+=1
```

Attention l'addition n'est pas forcément commutative !

```julia
2+a
```

ni unaire !

```julia
-a
```

Notez le message d'erreur qui est très claire !

```julia
a+[1,2]
```

## Autres surcharges

Toutes les fonctions usuelles sont surchargeable sans limite : size(); det() ...

```julia
function Base.size(g::Grid)
    return g.n
end
```

```julia
size(a)
```

```julia
function Base.det(g::Grid1d)
    g.fin-g.debut
end 
```

```julia
det(a)
```

# Type et constructeurs

Chaque langage "objet" définit un constructeur pour ces objets. Nous avons déjà utiliser un constructeur générique qui rempli chaque champ du nouveau type. Il est possible de faire une variante suivant le nombre d'arguments d'entrée et de leur type 

```julia
abstract Grid # juste en dessous de Any
type Grid1d <: Grid
    debut::Float64
    fin::Float64
    n::Int32
    
    # constructeurs par défaut sans argument
    function Grid1d()
        new(0,0,0)
    end
    
    # constructeurs par défaut avec argument
    function Grid1d(a,b,c)
        if c<=0
            error("pas possible")
        else
            new(a,b,c)
        end
    end
end
```

```julia
b=Grid1d(0,1,-1)
```

Il devient possible de déterminer un constructeurs pour différentes entrées.

Il faut au préalable bien penser sa hiérarchie de type et écrire autant de fonctions constructeurs que de cas d'initialisation du nouveau type.


# Les Itérateurs

Il est possible sur un type nouveau de définir un itérateur, comme ici de parcourrir les points de la grille, définissons (surchargeons) de nouvelles fonctions ou plutôt méthodes : 

```julia
Base.start(a::Grid1d) = 1

function Base.next(a::Grid1d, state)
    if state == 1
        return (a.debut,2)
    else
        return (a.debut+(a.fin-a.debut)*(state-1)/a.n , state+1)
    end
end

Base.done(a::Grid1d, state) = state > a.n +1


```

```julia
a=Grid1d(0,1,10)
```

```julia
start(a)
```

```julia
next(a,0)
```

```julia
for i in a
    println(i)
end
```

Il devient possible de construire des itérateurs sur une grille 2d, 3d renvoyant les coordonnées des points de la grille... Mais on peut imaginer sur une triangulation etc... 
