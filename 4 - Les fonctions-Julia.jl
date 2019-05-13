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

# # Les fonctions
#
# Il est possible de définir une fonction de trois façons différentes :
#
# ## Définition en ligne

f(x)=x+1

f(2)

g(x,y)=[x*y+1, x-y]

g(1,2)

# Il est possible d'utiliser **begin**-**end** ou **( ; )** pour délimiter la fonction la dernière valeur calculée est retournée

h(x)=begin
    y=2
    x+y
end

h(3)

h(x)=(y=2;x+y) # equivallent à la première écriture

h(3)

# ## Structurée
#
# JULIA possède une structure plus classique à l'aide de **function**-**end** comme précédemment la dernière valeur calculée est par défaut la variable de retour autrement l'utilisation de **return** spécifie la ou les variables de sortie. 

function H(x,y)
    z=x+y;
    z^2/(abs(x)+1)
end

H(1,2)

# L'usage de **return** pour fixer la sortie 

function Choix(x)
    if x>0
        return "Positif"
    else
        return "Négatif"
    end
end

txt=Choix(3)

# ## Anonyme
#
# Le concept peut paraître abstrait mais on peut définir une fonction sans la nommer puis l'affecter à une variable...

x->x^2

G=x->sqrt(x)

G(1)

typeof(G)

# ## Arguments de sortie
#
# Pour avoir plusieurs arguments de sortie il faut utiliser un "tuple" autrement dit une collection d'éléments

function multi_output(x,y)
    return x+y, x-y
end

a=multi_output(1,2) # un seul argument de sortie qui contient un tuple

typeof(a)

a[1]

a[2]

a , b =multi_output(1,2) # assignation aux 2 arguments de sortie

a

b

# ## Portée des variables 
#
# Quelle est la portée des variables autrement dit une variable définie peut elle être accessible, modifiable dans une fonction sans la passer en paramètre ?

a=1
f(x)=a+x
f(1)

a=1
function ff(x)
    x+a
end
ff(1)

a=1
function ff(x)
    x+a # on utilise a défini en dehors de la fonction
    a=2 # on tente de changer la valeur de a... error !
end
ff(1)

a=1
function ff(x)
    a=2
    x+a
end
ff(1)

a

# Donc par défaut une variable définie est connue et utilisable par toute fonction appelée (de même à l'intérieure d'une fonction).
#
# Si on redéfinie localement dans la fonction la variable alors "elle écrase localement" la dite variable et en sortie de fonction rien n'est modifié.
#
# Attention à l'utilisation dans la fonction d'une variable extérieure puis d'affecter une valeur à cette variable...
#
#

# ## Le mapping
#
# Souvent on écrit une fonction sous une forme scalaire sans chercher à utiliser les opérations vectorielles pour appliquer cette fonction à un tableau

f(x)=x^2 +1
f(1:5)  # il aurait fallu définir f(x)=x.^2.+1

# La fonction <code>map</code> permet de palier à ce manquement

map(f,1:5)

f.(1:5)

map(f,[1 2; 3 4])

f.([1 2; 3 4])

g(x,y)=x+y
map(g,0:3,1:4)

map(g,[1 2;3 4],[2 3;4 5])

g(f,x)=f(x)+1

g(sin,1)


