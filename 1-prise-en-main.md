# Prise en main

Pour un apprentissage rapide je recommande cette lecture (tout est dans le titre) http://learnxinyminutes.com/docs/julia/

## Fonctions scientifiques

Regardons les possibilités de calcul offert par cet environnement ! 

On est devant une superbe calculatrice comme dans la console de Matlab/Scilab ou R. On a donc l'utilisation des opérateurs classique <code>+-*/\^</code> ainsi que toutes les fonctions scientifiques <code>sin</code>, <code>cos</code> <code>exp</code> <code>log</code> (attention ici logarithme népérien)....

voir https://docs.julialang.org/en/v1/manual/mathematical-operations/

A remarquer l'utilisation de la fonction <code>log</code> comme le logarithme naturel (Népérien).

```julia
log(100)
```

```julia
log10(100)
```

<!-- #region -->
| **Fonctions usuelles**|
|-|
|exp, log, log10, abs, sqrt, cbrt, sign|

| **Fonctions trigonométriques usuelles**|
|-|
| sin, cos, tan, cot, sec, csc, sinh, cosh, tanh, coth, sech, csch, asin, acos, atan  |
| acot, asec, acsc, asinh, acosh, atanh, acoth, asech, acsch, sinc, cosc, atan2|


Il est possible d'utiliser les notations scientifiques <code>1e2</code> pour 100, ainsi que quelques nombre prédéfinis <code>pi</code>, <code>e</code>, <code>im</code> ...
<!-- #endregion -->

```julia
1e-2
```

```julia
2*pi
```

```julia
im^2
```

Certaines fonctions sont possèdent un domaine de définition comme <code>sqrt</code>, <code>log</code>... sur $I\!\!R$ extensible aux nombres complexes :

```julia
sqrt(-1)
```

```julia
sqrt(complex(-1))
```

L'ensemble des fonctions scientifique est étendu au calcul complexe !

```julia
sin(1+im)
```

| **Fonctions d'arrondi**|
|-|
|round, floor, ceil, trunc|

JULIA possède une algèbre étendue avec la possibilité de divisé par 0

```julia
1/0
```

```julia
1/Inf
```

```julia
Inf+1
```

```julia
Inf/Inf
```

```julia
Inf-Inf
```

```julia
0*Inf
```

```julia
NaN+1
```

<code>Inf</code> et <code>NaN</code> représentant l'infini et Not A Number. Toutes les formes indéterminées donnant <code>NaN</code> et toute combinaison avec <code>NaN</code> renvoie également <code>NaN</code>.


## Variables 

L'utilisation de variable est très intuitive sans déclaration préalable de type (entier, réel, imaginaire, fraction rationnelle...). Le nom de la variable doit commencer par une lettre entre a-z ou A-Z mais aussi par un underscore ('_') ou encore un caractère Unicode (voir dernier exemple pour comprendre)

```julia
a=1
```

```julia
typeof(a)
```

```julia
b=sqrt(2)
```

```julia
typeof(b)
```

```julia
c=9//12
```

```julia
typeof(c)
```

```julia
c=a+b;
typeof(c)
```

On voit dans ce qui précède que les variables sont typées, mais un mécanisme automatique de changement de type (comme <code>Int64</code> $ \rightarrow$ <code>Float64</code>) permet la somme d'un entier et d'un réel. On peut demander à JULIA d'identifier un entier comme un réel (Float) avec l'ajout d'un <code>.</code> exemple <code>a=1.</code>.

Une particularité est de ne pas avoir la possibilité de supprimer une variable ! Il est juste possible de récupérer l'espace mémoire en faisant <code>a=[]</code>.

```julia
a=[]
```

Toujours dans la rubrique particularité on verra que les fonctions sont aussi des variables, il sera donc possible de les passer en argument, de les affecter etc...

```julia
ρ¹=1
```

L'utilisation de caractères spétiaux comme les lettres grecques se font par utilisation d'une syntaxe de type LaTex. Dans la Plupart des éditeurs il faut commencer par <code>\rho</code> puis la touche TAB fait afficher le charactère 


### Convention et style

Julia impose quelques restriction de nom de variable, de plus les conventions suivantes sont d'usage :

* Les noms des variables sont en minuscule.
* La séparation des mots dans une variable se fait à l'aide d'un underscore ('_') mais cette pratique n'est pas recommandé pour une question de lisibilité des noms de variable.
* Les noms de Type ou de Modules commencent par une lettre majuscule, les majuscules séparant les différents mots du nom de la variable (exemple "MonModule")
* Les noms des fonctions et macros sont en minuscule sans underscores.
* Les fonctions qui modifient en sortie leurs arguments d'entrée s'écrivent avec ! en fin.


## Types de variable

Julia n'est pas à proprement parler un "langage objet" néanmoins c'est ce que l'on peut appeler un "langage typé". En effet ce langage possède un certain nombre de types prédéfinis et permet d'en ajouter à volonter. Les nouveaux types faisant office de structure tel un objet (C++/Java...) permettant la surcharge des opérateurs standarts *, /, + ....

### Les nombres scalaires
On a vu précédemment que JULIA est assez flexible sur l'utilisation et affectation des variable et est capable de rendre compatible l'addition d'entier, réel (float)...

De manière naturel on trouve les types :
* <code>int8</code>, <code>uint8</code>, <code>int16</code>, <code>uint16</code>,<code>int32</code>, <code>uint32</code>, <code>int64</code>, <code>uint64</code>,<code>int128</code>, <code>uint128</code>.
* <code>float16</code> (simple précision i.e 8 chiffres significatifs), <code>float32</code> (double précision, 16 chiffres significatifs), <code>float64</code> (32 chiffres significatifs)
* <code>complex32</code>, <code>complex64</code>, <code>complex128</code>.

```julia
a=1000000000000; typeof(a)
```

```julia
a=10000000000000000000; typeof(a)
```

```julia
b=10;
println(typeof(b))
b=Int32(b)
println(typeof(b))
```

```julia
convert(Float64,b)
Float64(b)
```

```julia
c=1.0;
println(typeof(c))
```

Il est possible de forcer le type d'une variable à l'aide des commandes <code>Int8()</code>, <code>Int16()</code>...<code>Float32()</code>...


Remarque : Opérations type unaire sur une variable 

| opération | += | -= | *= | /= | \= | 
|------|------|------|------|------|

```julia
a=1
a+=1
```

```julia
a*=3
```

### Les booléens

Les variables booléennes (1bit) sont naturellement définies dans JULIA à l'aide des opérateurs de comparaison 

| opération |égalité|différent| supérieur | supérieur ou égal | inférieur | inférieur ou égal|
|------|------||------|------|------|------|
| syntaxe | a==b | a!=b| a>b | a>=b | a<b | a<=b |

```julia
a = 1>0  ;println(a)  ;typeof(a)
```

Avec les opérateurs de conjonctions

| et | ou | not |
|-|-|-|
| & | &#124; | !|

```julia
!((a&true) & (a|false)) 
```

```julia
2>1 & 0>-1  
```

### Les chaines de caractère

JULIA possède un type **Char** (Charactere) il s'agit d'une lettre délimité par '' à ne pas confondre avec la chaine de caractère.

```julia
z='a'
```

```julia
z=z+1 # en ajoutant 1 on passe aux charactère suivant dans la table 
```

La chaine de caractère est délimitée par "" et définit unt type **ASCIIString** ou **UTF8String**

```julia
a="Une chaine de caractère \n"  # \n est le retour à la ligne
```

```julia
typeof(a)
```

La concaténation de chaîne se fait par l'utilisation de * (multiplication)

```julia
b= a * "puis une autre..." 
```

```julia
println(b)  # \n renvoie à la ligne
```

On peut extraire ou affecter une partie de cette chaîne considérée comme un tableau

```julia
a[1:10]
```

#### ATTENTION 

```julia
a[1] # le résultat est de type Char
```

```julia
a[1:1]
```

```julia
println(string(typeof(a[1]))*"\n")
println(string(typeof(a[1:1])))
```

L'usage de $ permet comme en php de convertir et d'inclure une variable dans une chaîne de caractère (interpolation)

```julia
m=11;
a="le mois de novembre est le $m ième mois "
```

```julia
b="racine de 2 : $(sqrt(2))"
```

Pour encore plus de possibilités avec les chaînes de caractère : https://docs.julialang.org/en/v1/manual/strings/#man-strings-1
