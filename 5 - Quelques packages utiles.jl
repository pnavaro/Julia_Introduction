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

# # Packages utiles
#
# Comme vu dans l'introduction JULIA possède une bibliothèque de package assez grande dont il n'est pas forcément aisé d'en faire le tri...
#
# Je vous propose ici la description et utilisation de quelques classiques
#
# En premier lieu un packages graphiques :
# * **Plots**
# * avec des backend **Gr**, **PyPlot**, **Plotly**
#
# et deux packages plus "statistiques" : 
#
# * **DataFrames**
# * **Rdatasets**
#
# # Graphiques
#
# La gestion graphique ne fait pas partie intégrante de JULIA il faut faire appel à des packages extérieurs et plusieurs choix sont possibles. En voici quelques uns
#
# ## Plots
#
# Plots est basé sur une bibliothèque éprouvée MatPlotLib (en Python). Sa syntaxe est identique à celle de MATLAB 

(v1.1) pkg> add Plots
(v1.1) pkg> add PlotlyJS
(v1.1) pkg> add PyPlot

using Plots 

x=range(0,stop=1,length=3000);
plot(x,sin.(10*x))

x=range(0,stop=1,length=3000);
plot(x,sin.(10*x))
plot!(x,cos.(10*x))


subplot(2,1,1)
plot(x,sin.(x),"g",linewidth=2.0)
subplot(2,1,2)
plot(x,x,"r")
grid(true)
title("tracé 2")

n=1024
X=randn(n)
Y=randn(n)
scatter(X,Y)

X=rand(5)
Y=-rand(5)
bar(1:5,X,facecolor="#9999ff", edgecolor="white")
bar(1:5,Y,facecolor="#ff9999", edgecolor="white")
for i=1:5
    txt=string(X[i])
    text(i+0.1,X[i]+0.01,txt[1:7])
    txt=string(Y[i])
    text(i+0.1,Y[i]-0.08,txt[1:7])
end
ylim(-1.2,1.2)

z=rand(20)
pie(z);

contour(rand(50,50))
colorbar()

surf(rand(50,50))

X=[x for x=-1:0.2:1, y=-1:0.2:1]
Y=[y for x=-1:0.2:1, y=-1:0.2:1]
quiver(-1:0.2:1,-1:0.2:1,X,Y)

# D'autres packages sont disponible Gadfly, Winston, AsciiPlot, GLVisualize...

# ## Type DataFrames
#
# But : travailler avec des tables de données.
# Ce sont des tables dont les colonnes sont des DataArray. Voici deux façons de construire des DataFrames :

using DataFrames

df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"])

df = DataFrame()
df[:A] = 1:8;
df[:B] = ["M", "F", "F", "M", "F", "M", "M", "F"];
df

nrows = size(df, 1) # nombre de ligne
ncols = size(df, 2) # nombre de colonne

first(df)#Voir le début du tableau

last(df) #Voir la fin du tableau

df[1:3, :] #Voir les lignes 1,2,3 du tableau

# Nous avons l'analogie avec summarize du logiciel R :

describe(df)

# Pour aller plus loin dans le travail statistique sur les Dataframes il nous faut le package RDatasets qui va fournir nombres exemples et on va y retrouver beaucoup de fonctionnalités communes au logiciel R.
#
# ## RDatasets

using RDatasets
