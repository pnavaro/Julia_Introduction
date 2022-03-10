# Type et méthodes

*Julia* possède un système de type et de méthode qui lui confère une approche objet.
La fonction `typeof()` renvoie le type d'une variable de base `Int32`, `Float64`... *Julia* est conçu pour permettre facilement d'étendre l'environnement à de nouveaux type de variable.

Le types sont organisés suivant un hiérarchie comme on peut le voir sur l'arborescence partielle ci-dessous


```julia title="- Any << abstract immutable size:0 >>"
using AbstractTrees

AbstractTrees.children(x::Type) = subtypes(x)

print_tree(Number)
```

Dans cette arborescence, certains types sont "abstraits" et d'autres "concrets".

```julia
isconcretetype(Real), isconcretetype(Float64)
```

Un réel sera forcemment de type concret `Float64` ou `Float32` par exemple, et pourra être utilisé comme argument par toutes les fonctions acceptant le type abstrait `AbstractFloat`

```julia
Float64 <: AbstractFloat
```

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
abstract type AbstractGrid end # juste en dessous de Any
mutable struct Grid1d <: AbstractGrid
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

```julia
@show a
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
try 
    2+a
catch e
    showerror(stdout, e)
end
```

ni unaire !

```julia
try 
    -a
catch e
    showerror(stdout, e)
end 
```

Notez le message d'erreur qui est très claire !

```julia
try
    a+[1,2]
catch e
    showerror(stdout, e)
end 
```

## Autres surcharges

Toutes les fonctions usuelles sont surchargeable sans limite : size(); det() ...

```julia
function Base.size(g::AbstractGrid)
    return g.n
end
```

```julia
size(a)
```

```julia
using LinearAlgebra

function LinearAlgebra.det(g::Grid1d)
    g.fin-g.debut
end 
```

```julia
det(a)
```

# Type et constructeurs

Chaque langage "objet" définit un constructeur pour ces objets. Nous avons déjà utiliser un constructeur générique qui rempli chaque champ du nouveau type. Il est possible de faire une variante suivant le nombre d'arguments d'entrée et de leur type 

```julia
abstract type AbstractGrid end # juste en dessous de Any
struct Grid1D <: AbstractGrid
    debut::Float64
    fin::Float64
    n::Int32
    
    # constructeurs par défaut sans argument
    function Grid1D()
        new(0,0,0)
    end
    
    # constructeurs par défaut avec argument
    function Grid1D(a,b,c)
        c <= 0 && @error("pas possible")
        new(a,b,c)
    end
end
```

```julia
b = Grid1D(0, 1, -1)
```

Il devient possible de déterminer un constructeurs pour différentes entrées.

Il faut au préalable bien penser sa hiérarchie de type et écrire autant de fonctions constructeurs que de cas d'initialisation du nouveau type.


# Les Itérateurs

Il est possible sur un type nouveau de définir un itérateur, comme ici de parcourrir les points de la grille, définissons (surchargeons) de nouvelles fonctions ou plutôt méthodes : 

```julia
Base.iterate(g::Grid1D, state=g.debut) = state > g.fin ? nothing : (state, state+(g.fin-g.debut)/g.n)
```

```julia
grid = Grid1D(0,2,10)
```

```julia
for x in grid
    println(x)
end
```

Il devient possible de construire des itérateurs sur une grille 2d, 3d renvoyant les coordonnées des points de la grille... Mais on peut imaginer sur une triangulation etc... 
