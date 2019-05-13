# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.4'
#       jupytext_version: 1.1.1
#   kernelspec:
#     display_name: Julia 1.1.0
#     language: julia
#     name: julia-1.1
# ---

# # Tableaux et matrices
#
# La définition de tableaux i.e. vecteurs, matrices, hypermatrices est un élément essentiel du Julia.
#
# Julia ne possède qu'un seul type de tableau : **Array** on peut définir sont nombre d'entrées (1 entrée= 1 dimension ...) et sont contenu de façon assez générale (Un tableau peut contenir des matrices à chaque élément...
#
# Une particularité est que les indices de tableaux commencent à 1, et l'accès aux éléments se fera à l'aide de '[' ’]' et non '(' ')' qui est réservé aux fonctions.
#
# Avant de rentrer dans la construction et manipulation de tableau regardons une autre classe 
#
# # Iterateur
#
# Julia possède un Type particulier fait à l'aide du ":"

a=1:5

a.+1

typeof(a)

b=0:0.5:2

typeof(b)

# Ce type "formel" permet d'avoir une définition et une méthode associée sans stocker l'ensemble des valeurs. Attention celui-ci peut être vide :

d=1:0 # itérateur formel mais correspond à un ensemble vide de valeurs

d=collect(d)

# # Tableau
#
# On vient de voir que l'on peut transformer l'itérateur précédent en tableau à l'aide de la commande "collect"

a=1:5
aa=collect(a)

collect(a')

typeof(aa)

# La réponse est de la forme **Array{Type,dim}** un tableau de **Type** à **dim** entrées (1 pour vecteur, 2 pour matrices ...)
#
# A remarquer :
# * l'indexation des tableaux commence à 1.
# * un tableau à une entrée est vu comme un vecteur colonne par défaut.
# * le crochet [ ] sert à extraire ou affecter une valeur ou un bloc de valeur. Attention le crochet [ ] sert également de "concatenateur" et constructeur de tableau (voir suite)
# * Il est possible de faire des tableaux de n'importe quoi (fonction, tableau, ...).

aa[1]

aa[end] # pour accèder au dernier élément

aa[end-2:end].=1; println(aa)

# Les crochets permettent la construction explicite de tableaux (ou leur concaténation)

A=[1 2 ; 3 4] # {espace} = séparateur de colonne

AA=[A  A] # concaténation par bloc

hcat(A,A) # commande équivalent à la précédente [A  A]

AA=[A ; A]

vcat(A,A) # commande équivalent à la précédente [A  ; A]

# On peut accéder à tout ou partie d'un tableau à l'aide de 2 indices

A[2,1]

A[2,:]

A[:,2]

A[end,end]

B=[1 2 3 4]

B=[1;2;3;4]

# A noter que l'on peut faire des tableaux de tout type voir de les mélanger (Any)

a=["un";"deux"]

b=[1>2,true,false]

c=["un"; 2 ; true]

# Le crochet [ ] permet également la construction rapide de matrice ou tableau comme le montre l'exemple si dessous pour construire une matrice de VanderMonde
#
# $$ V_{i,j}=x_i^{j-1}$$

x=0:0.2:1;
V=[ x[i]^(j-1) for i=1:6, j=1:6] # ligne et colonne

D=[ u*v for u=1:0.5:3, v=1:0.5:4]

# On peux évidemment faire des tableaux à 3,4... entrèes.
#
# ## Manipulation de Tableau
#
# ### push!
#
# Le fonction push permet d'ajouter à un tableau une valeur supplémentaire

a=[]
push!(a,1)     # => [1]
push!(a,2)     # => [1,2]
push!(a,4)     # => [1,2,4]
push!(a,6)     # => [1,2,4,6]

# ### append!
#
# Cette fonction permet de mettre bout à bout 2 tableaux

append!(a,a)

# A noté le  **Array{Any,1}** !

a=zeros(Int32,1)
push!(a,1)     # => [1]
push!(a,2)     # => [1,2]
push!(a,4)     # => [1,2,4]
push!(a,6)  

a=zeros(0)

a=zeros(Int32,1)

# ### Attention sur la conversion de type !

a=collect(1:5)

a=fill(0.,3,2)

a[2]=sqrt(2)

a=map(Float64,a)

a=Float64.(a)

# ## Algèbre linéaire
#
# On retrouve beaucoup (toutes) de fonctions usuelles de l'algèbre linéaire

using LinearAlgebra

A=[1 2 ; 3 4]
size(A)

det(A)

tr(A)

eigvals(A)

A=[1 2;3 4];b=[2 ; 3]; #résolution du système Ax=b
x=A\b 

# ## Fonctions scientifiques et opérations
#
# L'usage des fonction scientifiques se fait termes à termes pour l'ensemble des valeurs du tableau (sauf pour les fonctions matricielles comme <code>exp</code>, <code>log</code> ...). L'usage des opérations <code>+</code>,<code>-</code>,\*</code>,<code>^</code>,<code>/</code> et <code>\</code>(résolution) est disponible à condition de respecter les contraintes de dimension (multiplication matricielle par exemple). Sont ajouté des opérations termes à termes <code>.\*</code>,<code>.^</code>,<code>./</code> et <code>.\</code> toujours avec une contrainte de dimensions compatibles.

A=[1 2;3 4]
exp(A)

exp.(A) # exponentielle matricielle

# De plus les tableaux possèdes des opérations de multiplication, division, puissance termes à termes

A^2 #Multiplication Matricielle

A.^2 #Multiplication terme à terme

A./[2 3 ; 4 5] #Division terme à terme 

A./2

# ## Opérateurs booléens sur les tableaux

collect(1:5)>2

collect(1:5).>2

collect(1:5).>[0;2;3;4;5]

collect(1:5).>[0 2 3 4 5]

# ## Particularité max, maximum, min, minimum

max(2,3)

max(1,2,3)

max(1:5)

maximum(1:5)

max.(1:5,2:6)

# ## Constructeurs
#
# Enfin il est possible de construire rapidement certaines matrices

a=fill(0.,2,3) 

a=fill(2,2)

b=range(0,stop=2*pi,length=10)

collect(b)

A=ones(3)

A=zeros(3)

B=randn(5) # loi normale centrée de variance 1

B=[ones(3,2) zeros(3,2)] # concaténation de tableaux

B=[ones(3,2); zeros(3,2)] # , ou ; jouent le rôle de retour à la ligne

C=Diagonal(ones(3,3))

diag(C) # extraction d'une diagonale

# ## type sparse
#
# Julia possède un type sparse i.e. des matrices creuses, ces dernières ayant un comportement identique aux matrices elles ne diffèrent que dans leur définition (et leur stockage).

using SparseArrays

A=spzeros(3,3)



A=spdiagm(0 => 1:3)

A=A+spdiagm(1 => 1:2)

sparse([0 1 2; 2 0 0]) # pour rendre sparse une matrice "full"

det(A)

# ## Affectation et copie
#
# Attention julia à un mode de passage de valeur qui fonctionne différemment suivant une variable type ou un tableau.
#
# Pour une varibla scalire

a=1
b=a
b+=1

a

b

# Par contre maintenant si la variable est un tableau

A=collect(1:5)
B=A
B.+=1

A

B

# Pour avoir un comportement il faut copier le tableau A 

A=collect(1:5)
B=copy(A)
B.+=1

A

B
