# Calcul parallèle

JULIA dans sa grande force permet nativement le calcul parallel plus précisément calcul parallel à mémoire partagée ou distribuée.

Le document référence officiel : https://docs.julialang.org/en/v1/manual/parallel-computing/

- http://www.csd.uwo.ca/~moreno/cs2101a_moreno/Parallel_computing_with_Julia.pdf Très transparants très bien fait la notion de Task est abordée...
- http://www.admin-magazine.com/HPC/Articles/Julia-Distributed-Arrays
- http://www.admin-magazine.com/HPC/Articles/Parallel-Julia-Jumping-Right-In
- http://www.blog.juliaferraioli.com/2014/02/julia-on-google-compute-engine-parallel.html
- http://www.alshum.com/parallel-julia/

```julia
using Plots
```

En tout premier lieu on peut lancer une instance de JULIA avec plusieurs processeurs (ou plusieurs instances de JULIA) à l'aide de la commande shell

julia -p 4

Avec cette option le package `Distributed` est automatiquement importé.

Autrement on peut à la volée ajouter/enlever des processeurs ou plutôt workers à l'aide des commandes <code>addproc()</code> <code>rmproc()</code> et <code>worker()</code> ainsi que les commandes <code>nprocs</code> et <code>nworker</code> 

```julia
using Distributed
workers() # par défaut un worker le "maitre"
```

```julia
addprocs(2) #ajout de 2 workers
```

```julia
workers() # le processeur 1 n'est plus worker il est devenu master
```

# Parallélisation avec Distributed

JULIA offre une façon simple de programmer des processus asynchrones à l'aide de fonction `pmap` et la macro @spawnat

```julia
@everywhere begin  # la fonction slow_add est définit sur tous les processus
    function slow_add( x )
        sleep(1)
        x + 1
     end
end

@elapsed results = [slow_add(x) for x in 1:8]
```

```julia
results
```

```julia
@elapsed results = pmap(slow_add, 1:8 )
```

```julia
futures = []
for x in 1:8
    f = @spawnat :any slow_add(x)  # remplacez :any par un id pour exécuter 
    push!(futures, f)              # sur un processus particulier
end
```

```julia
@elapsed results = [fetch(f) for f in futures] # les futures ont déjà été exécuté
```

```julia
@elapsed begin
    futures = []
    for x in 1:8
        proc = mod1(x, nworkers())
        push!(futures, remotecall(slow_add, proc,  x))  # il faut donner le numero du proc 
    end
    results = [fetch(f) for f in futures]
end
```

```julia
results
```

Regardons plus exactement la répartition du calcul pour cela utilisons un tableau partagé <code>SharedArray</code> (voir également <code>SharedMatrix</code>, <code>SharedVector</code>). Autrement dit un tableau qui sera accessible en lecture et en écriture pour chaque worker (et le master).

```julia
using SharedArrays
```

```julia
taille=7
a = SharedArray{Int}(1,taille) # Tableau partagé
@distributed for i=1:taille
    a[i]=myid() # renvoie le numéro du worker stocké dans a
end
```

```julia
a
```

La boucle à été partagée et envoyée pour $i=1:4$ sur le worker 2 et pour $i=5:7$ sur le worker 3.

Regardons si nous n'avions pas utilisé de tableau partagé

```julia
taille=7
a = zeros(taille) # Tableau non partagé il est ici en local myid()==1
@sync @distributed for i=1:taille
    a[i]=myid() # renvoie le numéro du worker
    println(a)
end
```

On peut voire que localement les workers ont accès à une copie de <code>a</code> dont ils peuvent modifier les valeurs "localement". 

Par contre

```julia
println(a)
```

la valeur sur master n'a pas été modifiée. Autrement dit chaque worker a utilisé une copie locale de a, localement modifiable mais une fois l'exécution terminée cette copie est effacée.

```julia
a = ones(taille)
@sync begin
    @distributed for i=1:2
        println(a) # nouvelle copie locale
    end
end
```

# Application Bassin d'attraction de Newton :

Plaçons nous sur un exemple de calcul de bassin d'attraction de Newton

## premier calcul mono-processeur (temps de référence)

```julia
using LinearAlgebra    # Pour la fonction `norm`
" Algorithme de Newton "
function newton(x0,f,df,epsi)
    k=0
    x=x0
    xnew=x-df(x)\f(x)
    while (norm(x-xnew)>epsi)&(k<1000)
        x=xnew
        xnew=x-df(x)\f(x)
    end
    return xnew
end
```

```julia
# fonction f(x)=0 à résoudre ici z=x+iy et f(z)=z^3-1
f(x)=[x[1]^3-3*x[1]*x[2]^2-1,3*x[1]^2*x[2]-x[2]^3]
# le jacobien de f
df(x)=[3*x[1]^2-3*x[2]^2 -6*x[1]*x[2];6*x[1]*x[2] 3*x[1]^2-3*x[2]^2]

"""
Calcul du bassin si on converge vers la Ieme racine suivant le point de départ
"""
function calc_bassin(f,df,n)
    x=LinRange(-1,1,n);
    y=LinRange(-1,1,n);
    Imag=zeros(n,n);
    for i=1:n
        for j=1:n
            r=newton([x[i],y[n-j+1]],f,df,1e-10)
            Imag[j,i]=(round(atan(r[2],r[1])*3/pi)+3)%3;
        end
    end
    return Imag
end
```

```julia
n=512 # un deuxième appel est plus rapide
@time Imag = calc_bassin(f,df,n); 
```

```julia
contourf(LinRange(-1,1,n),LinRange(-1,1,n),Imag, 
    aspect_ratio = :equal)
```

## Newton en parallèle

```julia
rmprocs()   # on supprime les processus précedents
addprocs(2) # on ajoute 2 processeurs
```

Dans un premier temps on redéfinit les fonctions `newton`, `f` et `df` pour tous les workers à l'aide de la macro @everywhere

```julia
@everywhere using LinearAlgebra

# algorithme de Newton
@everywhere function newton(x0,f,df,epsi)
    k=0;
    x=x0;
    xnew=x-df(x)\f(x);
    while (norm(x-xnew)>epsi)&(k<1000)
        x=xnew
        xnew=x-df(x)\f(x);
    end
    return xnew
end
# fonction f(x)=0 à résoudre ici z=x+iy et f(z)=z^3-1
@everywhere f(x)=[x[1]^3-3*x[1]*x[2]^2-1,3*x[1]^2*x[2]-x[2]^3]
# le jacobien de f
@everywhere df(x)=[3*x[1]^2-3*x[2]^2 -6*x[1]*x[2];6*x[1]*x[2] 3*x[1]^2-3*x[2]^2]
# Calcul du bassin si on converge vers la Ieme racine suivant le point de départ
```

Puis on uitlise <code>@parallel</code> dans la boucle extérieure ainsi que <code>@sync</code> pour resynchroniser les process autrement attendre que tous les workers aient fini leurs calculs 

```julia
function calc_bassin(f,df,n)
    x = LinRange(-1,1,n);
    y = LinRange(-1,1,n);
    Imag = SharedArray{Int}(n,n);
    @sync begin
        @distributed for i=1:n
             for j=1:n
                r=newton([x[i],y[n-j+1]],f,df,1e-10)
                Imag[j,i]=(round(atan(r[2],r[1])*3/pi)+3)%3;
            end
        end
    end
    return Imag
end
```

```julia
n = 512 # pour efficacité il faut relancer 2 fois
@time Imag = calc_bassin(f,df,n); 
```

```julia
4/1.33/nworkers()
```

```julia
contourf(LinRange(-1,1,n),LinRange(-1,1,n),Imag,
    aspect_ratio = :equal)

```

# Encore plus de //

On a utilisé les macros <code>@everywhere</code> <code>@distributed</code> <code>@sync</code>
regardons 

* <code>remotecall</code> appel asynchrone (n'attends pas le résultat dit appel non bloquant)
* <code>fetch</code> récupère le résultat (synchronise)
* <code>remotecall_fetch</code> les 2 commandes précédentes réunies ou appel bloquant (tant que le résultat n'est pas calculé la fonction ne rend pas la main.
* <code>remotecall_wait</code> appel bloquant attend la fin de l'éxacution.
* <code>@async</code> exécute le bloc en mode asynchrone.
* <code>@spawn</code> et <code>@spawnat</code> macros pour <code>remotecall</code>

```julia
for proc=workers()
    println(remotecall_fetch(myid, proc)) # demande l'exécution de myid() sur chaque proc
end
```

```julia
a=zeros(nworkers())
for i=1:nworkers()
    a[i]=remotecall_fetch(myid, i+1)
end
println(a) # a contient les numéros des workers  
```

```julia
for i=1:10
    r = @spawn myid() 
    println("process: $(r.where) int: $(fetch(r))")  
end  
```

## Newton parallel 2

Reprenons notre algorithme de calcul de bassin

```julia
# Calcul du bassin si on converge vers la Ieme racine suivant le point de départ
function calc_bassin_async(f,df,n)
    x=LinRange(-1,1,n);
    y=LinRange(-1,1,n);
    Imag=zeros(n,n);
    k=0
    wo=workers()
    nw=nworkers()
    @sync begin
        for i=1:n
            for j=1:n
                @async begin    # lancement asynchrone      
                    k=k+1
                    wk=wo[k%nw+1] # worker suivant
                    r = @spawnat :any newton([x[i],y[n-j+1]],f,df,1e-10)
                    Imag[j,i]=(round(atan(r[2],r[1])*3/pi)+3)%3;
            end # ens @async
            end
        end     
    end # end @sync
    return Imag
end
```

```julia
n=32 # efficacité pas très grande voir catastrophique !
@time Imag=calc_bassin_async(f,df,n); 
```

On peut voir que le code n'est pas très efficace on perd beaucoup de temps en communication on fait trop d'appels aux workers ($n^2$).

Changeons de principe et divisons la tache en nombre de workers :

```julia
# résoltion d'un block du probleme du bassin de Newtown
@everywhere function calc_block(f,df,x,y)
    n=length(x)
    m=length(y)
    Imag=zeros(m,n)
    for i=1:n
        for j=1:m
            r=newton([x[i],y[m-j+1]],f,df,1e-10)
            Imag[j,i]=(round(atan(r[2],r[1])*3/pi)+3)%3;
        end
    end
    return Imag
end
```

```julia
function calc_bassin_parallel(f,df,n)
    x=LinRange(-1,1,n)
    y=LinRange(1,-1,n)
    Imag=zeros(n,n)
    
    # permet la répartition du travail
    wo=workers()
    nw=nworkers()
    parts = Iterators.partition(1:n, n ÷ nw)
    
    @sync for (i,part) in enumerate(parts) # répartition sur tous les workers
        @async begin  
            Imag[:,part]=
                remotecall_fetch(calc_block, wo[i], f,df,x[part],y)
            end # end @async
    end     
    return Imag
end
```

```julia
n=512 # efficacité correcte 
@time Imag=calc_bassin_parallel(f,df,n); 
```

```julia
contourf(LinRange(-1,1,n),LinRange(-1,1,n),Imag, aspect_ration = :equal)
```

En diminuant le nombre d'appels on à retrouver une efficacité de l'ordre de 88% $\left(\dfrac{T_{ref}}{T_{multiproc} * nbproc}\right)$ comme avec la macro <code>@parallel</code> précédente.

```julia
rmprocs(workers())
nworkers()
```

# Threads

Lisez ce [billet de blog](https://julialang.org/blog/2019/07/multithreading/) pour une présentation des fonctionnalités multi-threading de Julia.

<!-- #region -->
Par défaut Julia n'utilise qu'un seul thread. Pour le démarrer avec plusieurs threads nous devons le lui dire explicitement :

```julia
using IJulia
installkernel("Julia (4 threads)", "--project=@.", env=Dict("JULIA_NUM_THREADS"=>"4"))
```

Note : Changer manuellement dans le menu "Kernel" pour chaque nouvelle version de Julia et vous devez recharger votre navigateur pour voir un effet.

Pour vérifier que cela a fonctionné :
<!-- #endregion -->

```julia
import Base.Threads

Threads.nthreads()
```

```julia
# algorithme de Newton séquentiel
function newton(x0,f,df,epsi)
    k=0
    x=x0
    xnew=x-df(x)\f(x)
    while (norm(x-xnew)>epsi)&(k<1000)
        x=xnew
        xnew=x-df(x)\f(x)
    end
    return xnew
end

# fonction f(x)=0 à résoudre ici z=x+iy et f(z)=z^3-1
f(x)=[x[1]^3-3*x[1]*x[2]^2-1,3*x[1]^2*x[2]-x[2]^3]
# le jacobien de f
df(x)=[3*x[1]^2-3*x[2]^2 -6*x[1]*x[2];6*x[1]*x[2] 3*x[1]^2-3*x[2]^2]

# Calcul du bassin si on converge vers la Ieme racine suivant le point de départ
function calc_bassin_threads_1(f,df,n)
    x=LinRange(-1,1,n)
    y=LinRange(-1,1,n)
    Imag=zeros(n,n)
    Threads.@sync for i=1:n
        Threads.@spawn for j=1:n
            @inbounds r = newton([x[i],y[n-j+1]],f,df,1e-10)
            @inbounds Imag[j,i]=(round(atan(r[2],r[1])*3/pi)+3)%3;
        end
    end
    return Imag
end
```

```julia
n=512 # un deuxième appel est plus rapide
@time Imag=calc_bassin_threads_1(f,df,n); 
```

```julia

# Calcul du bassin si on converge vers la Ieme racine suivant le point de départ
function calc_bassin_threads_2(f,df,n)
    x=LinRange(-1,1,n)
    y=LinRange(-1,1,n)
    Imag=zeros(n,n)
    nt = Threads.nthreads()
    parts = Iterators.partition( 1:n, n ÷ nt)
    Threads.@sync for part in parts
        Threads.@spawn begin
            for i=part, j=1:n
                @inbounds r = newton([x[i],y[n-j+1]],f,df,1e-10)
                @inbounds Imag[j,i]=(round(atan(r[2],r[1])*3/pi)+3)%3
            end
        end
    end
    return Imag
end
```

```julia
n=512 # un deuxième appel est plus rapide
@time Imag=calc_bassin_threads_2(f,df,n); 
```
