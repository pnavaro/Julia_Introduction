# Packages utiles

Comme vu dans l'introduction JULIA possède une bibliothèque de packages assez grande dont il n'est pas forcément aisé d'en faire le tri...

Je vous propose ici la description et utilisation de quelques classiques

En premier lieu un packages graphiques :
* **Plots**
* avec des backend **Gr**, **PyPlot**, **Plotly**

et deux packages plus "statistiques" : 

* **DataFrames**
* **RDatasets**

# Graphiques

La gestion graphique ne fait pas partie intégrante de JULIA il faut faire appel à des packages extérieurs et plusieurs choix sont possibles. En voici quelques uns

## Plots

Plots est basé sur une bibliothèque éprouvée MatPlotLib (en Python). Sa syntaxe est identique à celle de MATLAB 

<!-- #region -->
```julia
(v1.1) pkg> add Plots
(v1.1) pkg> add PlotlyJS
(v1.1) pkg> add PyPlot
```
<!-- #endregion -->

```julia
using Plots 
```

```julia
x= LinRange(0, 1, 100)
plot(x,sin.(10*x))
```

```julia
x= LinRange(0, 1, 100)
plot(x,sin.(10*x))
plot!(x,cos.(10*x))
```


```julia
p = plot(layout=(2,1))
plot!(p[1,1], x,sin.(x), lc= :green,linewidth=2.0)
plot!(p[2,1], x,x, lc= :red)
title!(p[2,1], "tracé 2")
```

```julia
import PyPlot
PyPlot.subplot(2,1,1)
PyPlot.plot(x,sin.(x),"g",linewidth=2.0)
PyPlot.subplot(2,1,2)
PyPlot.plot(x,x,"r")
PyPlot.grid(true)
PyPlot.title("tracé 2")
```

```julia
n = 1024
X = randn(n)
Y = randn(n)
scatter(X, Y, exp.(-(X.^2+Y.^2)))
```

```julia
X = rand(5)
Y =-rand(5)
bar(1:5,X,facecolor="#9999ff", edgecolor="white")
bar(1:5,Y,facecolor="#ff9999", edgecolor="white")
for i=1:5
    txt=string(X[i])
    text(i+0.1,X[i]+0.01,txt[1:7])
    txt=string(Y[i])
    text(i+0.1,Y[i]-0.08,txt[1:7])
end
ylims!(-1.2,1.2)
```

```julia
z=rand(20)
pie(z)
```

```julia
contour(rand(50,50), colobar = true, aspect_ratio = :equal, size = (300,300))
```

```julia
palette(:rainbow)
```

```julia
surface(rand(50,50), palette = :rainbow)
```

```julia
x = LinRange(-2, 2, 21)
y = x
z = exp.(-x.^2 .- y'.^2)
contour(x, y, z, aspect_ratio = :equal)

v(x, y) = 0.1 .* [-y, x]

xs = [px for px in x for py in y]
ys = [py for px in x for py in y]

quiver!(xs, ys, quiver=v)
```

D'autres packages sont disponibles :
- Gadfly 
- UnicodePlots 
- Makie
voir [JuliaPlots](https://github.com/JuliaPlots) et [JuliaGraphics](https://github.com/JuliaGraphics)


## Type DataFrames

But : travailler avec des tables de données.
Ce sont des tables dont les colonnes sont des DataArray. Voici deux façons de construire des DataFrames :

```julia
using DataFrames
```

```julia
df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
```

```julia
df = DataFrame()
df[!,:A] = 1:8
df[!,:B] = ["M", "F", "F", "M", "F", "M", "M", "F"]
df
```

```julia
nrows = size(df, 1) # nombre de ligne
ncols = size(df, 2) # nombre de colonne
```

```julia
first(df)#Voir le début du tableau
```

```julia
last(df) #Voir la fin du tableau
```

```julia
df[1:3, :] #Voir les lignes 1,2,3 du tableau
```

Nous avons l'analogie avec summarize du logiciel R :

```julia
describe(df)
```

Pour aller plus loin dans le travail statistique sur les Dataframes il nous faut le package RDatasets qui va fournir nombres exemples et on va y retrouver beaucoup de fonctionnalités communes au logiciel R.

## RDatasets

```julia
using RDatasets
```

```julia
iris = dataset("datasets", "iris")
```

```julia

```
