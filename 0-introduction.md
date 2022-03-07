# Présentation de JULIA

Hello tout le monde !

*JULIA* est un langage de programmation de haut niveau dédié au calcul scientifique et calcul haute performance. C'est un logiciel libre sous [licence MIT](https://github.com/JuliaLang/julia/blob/master/LICENSE.md).

*JULIA* se veut la combinaison de :
* la facilité de développement des environnements interprétés comme *R*, *MATLAB*, *OCTAVE*, *SCILAB*, *PYTHON* … 
* la performance d'un langage compilé, permettant une exécution parallèle et/ou distribuée *C*, *C++*, *Fortran*...

*JULIA* est jeune à l'échelle de l'âge des langages. On peut voir son activité de développement [sous GITHUB](https://github.com/JuliaLang/julia), naissance en *aôut 2009*!

Ce langage possède déjà un grand nombre d'atouts :
* des fonctions mathématiques de précision numérique étendue (<code>Int128</code>, <code>Float64</code>...).
* de nombreuses bibliothèques  (ou package) dont beaucoup écrites en Julia http://pkg.julialang.org/.
* l'intégration naturel de très nombreuses bibliothèques en C, fortran, Python... 
* Mais surtout l'usage d'un compilateur à la volée (Just In Time) !

Les quelques pages qui suivent vont - nous l'espérons- vous guider dans l'usage de *JULIA* il est possible également de consulter :
* Le site officiel http://julialang.org/ avec une documentation très complète.
* http://en.wikibooks.org/wiki/Introducing_Julia excellent et très complet guide de Julia.
* https://zestedesavoir.com/articles/141/a-la-decouverte-de-julia/ très bon article à lire absolument !
* http://bioinfo-fr.net/julia-le-successeur-de-r un exemple en bioinfo.


# Installation et accessibilité

## Le terminal 

Julia est disponible sous tout OS (Mac-linux et Windows) voici la page de téléchargement officielle http://julialang.org/downloads/
A voir également cette page pour des installation plus spécifiques comme sous linux http://julialang.org/downloads/platform.html.

Une fois installé une interface _brut de pomme_ apparait, en fait, une simple console ou REPL pour Read/Evaluate/Print/Loop :

![julia shell](shell.png)

Le prompt <code>julia></code> invitant la commande... 

Dans la console de JULIA on retrouve l'usage classique d'un terminal avec 
* "flèche vers le haut" pour rappeler une commande précédente.
* "Tab" la tabulation qui complète ou propose la fin d'un mot.
* Des commandes <code>pwd()</code> (affiche le répertoire courant) <code>cd()</code> (Change directory), <code>homedir()</code> (pointe sur le home directory)...
* l'usage de <code>;</code> dans la console fait changer le prompt en ![Prompt](cmd_julia.png)  et donne directement accès aux commande shell (unix...).
* L'aide peut être invoquée avec <code>help("sin")</code> ou <code>?sin</code> le prompt se transformant de nouveau ![aide](help_julia.png).

## Usage 

Un programme Julia est un script extension .jl on peut soit l'exécuter en ligne de commande "julia nomfichier.jl" ou en l'incluant 
<!-- #endregion -->

<!-- #region -->
```julia
include("MonFichier.jl")
```
<!-- #endregion -->

Toute ligne ou fin de ligne commançant par `#` est en commentaire, une bloc est délimité par `#=` et `=#`:

```julia
# commentaire
1+2    #commentaire en fin de ligne
```

```julia
#=   un bloc
        complet
de commentaires  =#        
```

<!-- #region -->
## Editeur à coloration syntaxique

Il est parfaitement possible de travailler à l'aide d'un éditeur de texte et de la console en parallèle.

Il existe des fichier de configuration pour la coloration syntaxique dans les éditeurs : 
* Gedit
* emacs
* Notepadd++ (rechercher "julia syntaxe highlighting")
* Sublime Text 3
* Atom 
* ...

Certains offre la possibilité de gérer un terminal dans une fenêtre.

## Environnement intégré (IDE)

Il n'y a plus actuellement d'interface Julia Studio (équivalent de Rstudio)... 

Néanmoins certains éditeurs offrent des extensions qui "intègrent" Julia

* Sublime Text 3 et l'extension https://github.com/quinnj/Sublime-IJulia
* Atom et l'extension https://github.com/JunoLab/atom-julia-client

[Junio](http://junolab.org/) est une interface atypique permettant l'évaluation au fur et à mesure du code. Junio est en autocontenu avec l'inclusion de Julia, disponible en télechargement sur la page de Julia http://julialang.org/downloads/

## Notebook

Le notebook est façon de programmer qui permet d'obtenir plus directement un rendu plus web-publiable. La plateforme Jupyter qui héberge les notebooks, offre des possibilités d'interaction supplémentaire avec l'utilisation de widgets... 

On peut installer sur sa propre machine une instance de [Jupyter](http://jupyter.org/) (ex iPython) permettant de travailler dans son navigateur. Pour cela il faut installer le package [IJulia](https://github.com/JuliaLang/IJulia.jl) dans le terminal (REPL) taper "]" :
```julia
(v1.1) pkg> add IJulia
using IJulia
notebook()
```

On peut aussi convertir un fichier notebook (extension `.ipynb`) en fichier `.jl` (ou autre): 
* Dans l'interface Jupyter faire : `File->Download as`
* Dans un terminal : ```ipython nbconvert --to script nomfichier.ipynb```.

<!-- #endregion -->

# Les Packages

Julia possède une communauté très dynamique, à la fois pour développer le coeur du langage mais aussi pour mettre à disposition de nouvelles fonctionnalités qui pour certaines feront partie des prochaines versions de Julia.

Un listing complet des packages officiels et disponible : http://pkg.julialang.org/

Pour installer un package faire "]"


(v1.1) pkg> add IJuliaNom_du_Package


et il est installé physiquement dans votre espace disque (répertoire .julia/).

L'utilisation se fait en début de chaque programme (ou script par "using"). L'initialisation est assez longue (pour les versions 0.3.xx) le package étant compilé en directe. Depuis la version 0.4 les packages sont compilés (ou pré-compilés) à l'installation ou premier usage et stocké en fichier pour être rechargé plus rapidement ultérieurement.

<!-- #region -->
```julia
using Nom_du_Package
```
<!-- #endregion -->

La commande Pkg permet de gérer les actions faire "]" 

(v1.1) pkg> rm Nom_du_Package # rm : remove
(v1.1) pkg>update # comme dit le nom

On verra dans les sections suivantes l'utilisation de quelques packages plus prisés et même jusqu'à la création d'un package !
