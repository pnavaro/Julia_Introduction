# Tableaux et matrices

La définition de tableaux i.e. vecteurs, matrices, hypermatrices est un élément essentiel de Julia.

Julia ne possède qu'un seul type de tableau : **Array** on peut définir son nombre d'entrées (1 entrée= 1 dimension ...) et son contenu de façon assez générale (Un tableau peut contenir des matrices à chaque élément...

Une particularité est que les indices de tableaux commencent à 1, et l'accès aux éléments se fera à l'aide de '[' ’]' et non '(' ')' qui est réservé aux fonctions.

Avant de rentrer dans la construction et manipulation de tableau regardons une autre classe 

# Iterateur

Julia possède un Type particulier fait à l'aide du ":"

```julia
a=1:5
```

```julia
a.+1
```

```julia
typeof(a)
```

```julia
b=0:0.5:2
```

```julia
typeof(b)
```

Ce type "formel" permet d'avoir une définition et une méthode associée sans stocker l'ensemble des valeurs. Attention celui-ci peut être vide :

```julia
d=1:0 # itérateur formel mais correspond à un ensemble vide de valeurs
```

```julia
d=collect(d)
```

# Tableau

On vient de voir que l'on peut transformer l'itérateur précédent en tableau à l'aide de la commande "collect"

```julia
a=1:5
aa=collect(a)
```

```julia
collect(a')
```

```julia
typeof(aa)
```

La réponse est de la forme **Array{Type,dim}** un tableau de **Type** à **dim** entrées (1 pour vecteur, 2 pour matrices ...)

A remarquer :
* l'indexation des tableaux commence à 1.
* un tableau à une entrée est vu comme un vecteur colonne par défaut.
* le crochet [ ] sert à extraire ou affecter une valeur ou un bloc de valeur. Attention le crochet [ ] sert également de "concatenateur" et constructeur de tableau (voir suite)
* Il est possible de faire des tableaux de n'importe quoi (fonction, tableau, ...).

```julia
aa[1]
```

```julia
aa[end] # pour accèder au dernier élément
```

```julia
aa[end-2:end].=1; println(aa)
```

Les crochets permettent la construction explicite de tableaux (ou leur concaténation)

```julia
A=[1 2 ; 3 4] # {espace} = séparateur de colonne
```

```julia
AA=[A  A] # concaténation par bloc
```

```julia
hcat(A,A) # commande équivalent à la précédente [A  A]
```

```julia
AA=[A ; A]
```

```julia
vcat(A,A) # commande équivalent à la précédente [A  ; A]
```

On peut accéder à tout ou partie d'un tableau à l'aide de 2 indices

```julia
A[2,1]
```

```julia
A[2,:]
```

```julia
A[:,2]
```

```julia
A[end,end]
```

```julia
B=[1 2 3 4]
```

```julia
B=[1;2;3;4]
```

A noter que l'on peut faire des tableaux de tout type voir de les mélanger (Any)

```julia
a=["un";"deux"]
```

```julia
b=[1>2,true,false]
```

```julia
c=["un"; 2 ; true]
```

Le crochet [ ] permet également la construction rapide de matrice ou tableau comme le montre l'exemple ci-dessous pour construire une matrice de VanderMonde

$$ V_{i,j}=x_i^{j-1}$$

```julia
x=0:0.2:1;
V=[ x[i]^(j-1) for i=1:6, j=1:6] # ligne et colonne
```

```julia
D=[ u*v for u=1:0.5:3, v=1:0.5:4]
```

On peux évidemment faire des tableaux à 3,4... entrèes.

## Manipulation de Tableau

### push!

Le fonction push permet d'ajouter à un tableau une valeur supplémentaire

```julia
a=[]
push!(a,1)     # => [1]
push!(a,2)     # => [1,2]
push!(a,4)     # => [1,2,4]
push!(a,6)     # => [1,2,4,6]
```

### append!

Cette fonction permet de mettre bout à bout 2 tableaux

```julia
append!(a,a)
```

A noté le  **Array{Any,1}** !

```julia
a=zeros(Int32,1)
push!(a,1)     # => [1]
push!(a,2)     # => [1,2]
push!(a,4)     # => [1,2,4]
push!(a,6)  
```

```julia
a=zeros(0)
```

```julia
a=zeros(Int32,1)
```

### Attention sur la conversion de type !

```julia
a=collect(1:5)
```

```julia
a=fill(0.,3,2)
```

```julia
a[2]=sqrt(2)
```

```julia
a=map(Float64,a)
```

```julia
a=Float64.(a)
```

## Algèbre linéaire

On retrouve beaucoup (toutes) de fonctions usuelles de l'algèbre linéaire

```julia
using LinearAlgebra
```

```julia
A=[1 2 ; 3 4]
size(A)
```

```julia
det(A)
```

```julia
tr(A)
```

```julia
eigvals(A)
```

```julia
A=[1 2;3 4];b=[2 ; 3]; #résolution du système Ax=b
x=A\b 
```

## Fonctions scientifiques et opérations

L'usage des fonction scientifiques se fait termes à termes pour l'ensemble des valeurs du tableau (sauf pour les fonctions matricielles comme <code>exp</code>, <code>log</code> ...). L'usage des opérations <code>+</code>,<code>-</code>,<code>\*</code>,<code>^</code>,<code>/</code> et `\`(résolution) est disponible à condition de respecter les contraintes de dimension (multiplication matricielle par exemple). Sont ajouté des opérations termes à termes <code>.\*</code>,<code>.^</code>,<code>./</code> et <code>.\</code> toujours avec une contrainte de dimensions compatibles.

```julia
A=[1 2;3 4]
exp(A)
```

```julia
exp.(A) # exponentielle matricielle
```

De plus les tableaux possèdes des opérations de multiplication, division, puissance termes à termes

```julia
A^2 #Multiplication Matricielle
```

```julia
A.^2 #Multiplication terme à terme
```

```julia
A./[2 3 ; 4 5] #Division terme à terme 
```

```julia
A./2
```

## Opérateurs booléens sur les tableaux

```julia
collect(1:5)>2
```

```julia
collect(1:5).>2
```

```julia
collect(1:5).>[0;2;3;4;5]
```

```julia
collect(1:5).>[0 2 3 4 5]
```

## Particularité max, maximum, min, minimum

```julia
max(2,3)
```

```julia
max(1,2,3)
```

```julia
max(1:5)
```

```julia
maximum(1:5)
```

```julia
max.(1:5,2:6)
```

## Constructeurs

Enfin il est possible de construire rapidement certaines matrices

```julia
a=fill(0.,2,3) 
```

```julia
a=fill(2,2)
```

```julia
b=range(0,stop=2*pi,length=10)
```

```julia
c = LinRange(0, 2π, 10)
```

```julia
collect(b)
```

```julia
A=ones(3)
```

```julia
A=zeros(3)
```

```julia
B=randn(5) # loi normale centrée de variance 1
```

```julia
B=[ones(3,2) zeros(3,2)] # concaténation de tableaux
```

```julia
B=[ones(3,2); zeros(3,2)] # , ou ; jouent le rôle de retour à la ligne
```

```julia
C=Diagonal(ones(3,3))
```

```julia
diag(C) # extraction d'une diagonale
```

```julia
diagm(ones(3))
```

```julia
Matrix(I, 3, 3)
```

## type sparse

Julia possède un type sparse i.e. des matrices creuses, ces dernières ayant un comportement identique aux matrices elles ne diffèrent que dans leur définition (et leur stockage).

```julia
using SparseArrays
```

```julia
A=spzeros(3,3)
```

```julia
A=spdiagm(0 => 1:3)
```

```julia
A=A+spdiagm(1 => 1:2)
```

```julia
sparse([0 1 2; 2 0 0]) # pour rendre sparse une matrice "full"
```

```julia
det(A)
```

## Affectation et copie

Attention julia à un mode de passage de valeur qui fonctionne différemment suivant une variable type ou un tableau.

Pour une variable scalaire

```julia
a=1
b=a
b+=1
```

```julia
a
```

```julia
b
```

Par contre maintenant si la variable est un tableau

```julia
A=collect(1:5)
B=A
B.+=1
```

```julia
A
```

```julia
B
```

Pour avoir un comportement il faut copier le tableau A 

```julia
A=collect(1:5)
B=copy(A)
B.+=1
```

```julia
A
```

```julia
B
```
