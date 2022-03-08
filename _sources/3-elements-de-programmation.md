# Eléments de programmation

Pour mener à bien un calcul algorithmique le nombre d'éléments de langage n'est pas très important et peut se résumer aux 3 syntaxes suivantes

* Le choix conditionnel **if**-**elseif**-**else**-**end**.
* La boucle **for**-**end**.
* La boucle **while**-**end**


# if ... elseif ... else ... end

Un choix simple si le test est vrai (k==1) alors le bloc d'instruction est évalué
<!-- #endregion -->

```julia
k=1
if k==1
    println("k=1")
end
```

Le **else** permet de donner un résultat par défaut...

```julia
k=1
if k!=1
    println("k<>1")
else
    println("k=1")
end
```

Une succession de **elseif** permet de choisir parmi plusieurs critères, dans la succession des blocs de **if** et **elseif** le premier qui est "vrai" est évaluer et l'instruction s'arrète.

```julia
k=2
if k==1
    println("k=1")
elseif k>1
    println("k>1")
else 
    println("k<1")
end
```

# La boucle for

Elle peut se définir à l'aide d'itérateurs ou de tableaux de valeurs les syntaxes "=" , "in" ou "$\in$" sont équivalentes

```julia
for i=1:10
    println(i)
end
```

```julia
for i in ["un" 2 im]
    println(typeof(i))
end
```

La commande **break** permet de sortir d'une boucle à tout moment

```julia
for i = 1:1000
    println(i)
    if i >= 5
       break
    end
end
```

La commande **continue** permet elle de courtcircuiter la boucle en court et de passer à la valeur suivante

```julia
for i = 1:10
    if i % 3 != 0 # i modulo 3 different de 0
        continue
    end
    println(i)
end
```

# La boucle while

Tant que le test est "vrai" le bloc est évalué, le test se faisant en entrée de bloc

```julia
k=0
while k<10
    k+=1  # k=k+1
    println(k)
end
```

De même que la boucle **for** les commandes **break** et **continue** sont valables ...

```julia
k=0
while k<1000
    k+=1  # k=k+1
    if k % 5 != 0 # k modulo 5 diffèrent de 0
        continue # retour en début de boucle avec de nouveau un test sur k
    end
    println(k)
    if k>30
        break
    end
end
```

# Un peu d'optimisation

*Julia* est dit un langage performant, regardons rapidement quelques exemples à faire ou ne pas faire.

## Exemple de préallocation et utilisation de push!

```julia
n = 100000
@time begin
    A = zeros(0) # Tableau vide qui contiendra des Float64
    for i=1:n
        A=[A;i]   # a chaque itération on change la taille de A
    end
end
```

```julia
typeof(A)
```

```julia
A
```

```julia
@time begin
    A=zeros(0);
    for i=1:n
        push!(A,i)   # a chaque itération on change la taille de A
    end
end
```

```julia
A
```

```julia
@time begin
    A=zeros(Int64,n)
    for i=1:n
        A[i]=i
    end
end
```

```julia
@time begin
    A=[i for i=1:n]
end
```

```julia
typeof(A)
```

Cet exemple montre le coût prohibitif d'une réallocation dynamique qui impose une recopie totale de A à chaque itération.

## Exemple de vectorisation

Regardons la vectorisation sous *Julia* à l'aide de la construction d'une matrice de Vandermond


```julia
@elapsed begin
    n=3000;
    x=range(0,stop=1,length=n)
    V=zeros(n,n)
    for i=1:n
        V[:,i]=x.^(i-1) # calcul vectorisé
    end
end
```

```julia
A=rand(3,3)
A[:,1].=1
A
```

```julia
@elapsed begin
    n=3000
    x=range(0,stop=1,length=n)
    X=zeros(n,n)
    for i=1:n
        for j=1:n
            X[i,j]=x[i]^(j-1) # calcul dévectorisé
        end
    end
end
```

```julia
typeof(X)
```

```julia
@elapsed begin 
    n=3000;
    x=range(0,stop=1,length=n)
    W=[x[i]^(j-1) for i=1:n, j=1:n]
end
```

```julia
typeof(W)
```

```julia
function Vander(n)
    x=range(0,stop=1,length=n)
    V=zeros(n,n)
    for i=1:n
        #V[:,i]=x.^(i-1)
        for j=1:n
            V[i,j]=x[i]^(j-1) # calcul dévectorisé
        end
    end
    return V
end
@elapsed Z = Vander(3000)
```

```julia
@elapsed Z=Vander(3000)
```

```julia
@elapsed Z=Vander(3000) 
```

```julia
function Vander2(n)
    x=range(0,stop=1,length=n)
    [x[i]^(j-1) for i=1:n, j=1:n]
end
@elapsed Z2=Vander2(3000)
```

```julia
@elapsed Z2=Vander2(3000)
```

```julia
typeof(Z2)
```

La conclusion n'est pas toujours évidente a priori... Néanmoins on peut voir que le fait de mettre le code dans une fonction impose une optimisation à la compilation et une contextualisation du type et que l'écriture explicite des boucles donne un meilleur résultat.
