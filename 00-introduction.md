# Présentation

Hello tout le monde !

Je me présente, je suis ingénieur calcul à l'Institut de Recherche Mathématiques de Rennes. J'ai une formation en mécanique des fluides numérique. J'ai écrit beaucoup de codes en Fortran avec MPI et OpenMP. Depuis une dizaine d'années je fais beaucoup de Python. J'ai commencé à apprendre le langage Julia en juillet 2018 lorsque la version 1.0 est sortie. Je surveillais sa progression depuis 2015.
Les supports que je vais utiliser ont été écrits à l'origine par [Thierry Clopeau](https://github.com/clopeau/Julia_Introduction). 

**Julia** est un langage de programmation de haut niveau dédié au calcul scientifique et calcul haute performance. C'est un logiciel libre sous [licence MIT](https://github.com/JuliaLang/julia/blob/master/LICENSE.md).

**Julia** se veut la combinaison de :
* la facilité de développement des environnements interprétés comme *R*, *MATLAB*, *OCTAVE*, *SCILAB*, *PYTHON* … 
* la performance d'un langage compilé, permettant une exécution parallèle et/ou distribuée *C*, *C++*, *Fortran*...

**Julia** est jeune à l'échelle de l'âge des langages. On peut voir son activité de développement [sous GITHUB](https://github.com/JuliaLang/julia), naissance en *aôut 2009*!. La première version stable 1.0 est sortie en juillet 2018 durant la conférence JuliaCon à Londres.

Ce langage possède déjà un grand nombre d'atouts :
* des fonctions mathématiques de précision numérique étendue (<code>Int128</code>, <code>Float64</code>...).
* de nombreuses bibliothèques (ou packages) dont beaucoup écrites en Julia http://pkg.julialang.org/.
* l'intégration naturel de très nombreuses bibliothèques en C, Fortran, Python... 
* Mais surtout l'usage d'un compilateur à la volée (Just In Time) !

Les quelques pages qui suivent vont - nous l'espérons- vous guider dans l'usage de **Julia** il est possible également de consulter :
* Le site officiel http://julialang.org/ avec une documentation très complète.
* http://en.wikibooks.org/wiki/Introducing_Julia excellent et très complet guide de Julia.
* https://zestedesavoir.com/articles/141/a-la-decouverte-de-julia/ très bon article à lire absolument !
* http://bioinfo-fr.net/julia-le-successeur-de-r un exemple en bioinfo.
* https://juliadocs.github.io/Julia-Cheat-Sheet/fr/ Aide-mémoire


# Installation et accessibilité

## Le terminal 

Julia est disponible sous tout OS (Mac-linux et Windows) voici la page de téléchargement officielle http://julialang.org/downloads/
A voir également cette page pour des installation plus spécifiques comme sous linux http://julialang.org/downloads/platform.html.

Une fois installé une interface _brut de pomme_ apparait, en fait, une simple console ou REPL pour Read/Evaluate/Print/Loop :

![julia shell](shell.png)

Le prompt <code>julia></code> invitant la commande... 

Dans la console de *Julia* on retrouve l'usage classique d'un terminal avec 
* "flèche vers le haut" pour rappeler une commande précédente.
* "Tab" la tabulation qui complète ou propose la fin d'un mot.
* Des commandes <code>pwd()</code> (affiche le répertoire courant) <code>cd()</code> (Change directory), <code>homedir()</code> (pointe sur le home directory)...
* l'usage de <code>;</code> dans la console fait changer le prompt en ![Prompt](cmd_julia.png)  et donne directement accès aux commande shell (unix...).
* L'aide peut être invoquée avec <code>help("sin")</code> ou <code>?sin</code> le prompt se transformant de nouveau ![aide](help_julia.png).

## Usage 

Un programme Julia est un script extension .jl on peut soit l'exécuter en ligne de commande "julia nomfichier.jl" ou en l'incluant 
<!-- #endregion -->

```julia
include("monfichier.jl")
```

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

On les retrouve dans l'organisation [JuliaEditorSupport](https://github.com/JuliaEditorSupport). 
Certains offrent la possibilité de gérer un terminal, les graphiques et un debugger dans la même fenêtre.

## Environnement intégré (IDE)

Il n'y a plus actuellement d'interface Julia Studio (équivalent de Rstudio)... 

Néanmoins certains éditeurs offrent des extensions qui "intègrent" Julia

* Sublime Text 3 et l'extension [Sublime-IJulia](https://github.com/quinnj/Sublime-IJulia)
* Atom et l'extension [JunoLab](http://junolab.org/)

Depuis 2020 l'IDE préconisé par les développeurs de Julia est [Visual Studio Code](https://www.julia-vscode.org). 


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

L'outil [jupytext](https://github.com/mwouts/jupytext) permet de synchroniser un notebook (.ipynb) avec un fichier au format markdown (.md) ou au format script (.jl).
Intégré avec Jupyter, il permet d'ouvrir n'importe lequel de ces 3 formats.

Le package [Literate.jl](https://github.com/fredrikekre/Literate.jl) est un outil Julia qui permet également de générer des notebooks et des fichiers markdown.

Vous pouvez également regarder sur côté de [Pluto.jl](https://github.com/fonsp/Pluto.jl) qui permet de créer des notebooks Julia avec des fonctionalités améliorant l'interactivité.
<!-- #endregion -->

# Les Packages

Julia possède une communauté très dynamique, à la fois pour développer le coeur du langage mais aussi pour mettre à disposition de nouvelles fonctionnalités qui pour certaines feront partie des prochaines versions de Julia.

Un listing complet des packages officiels est disponible sur [juliapackages.com](https://juliapackages.com) et/ou [juliahub.com](https://juliahub.com/ui/Packages). 

Pour installer un package faire "]"


(v1.1) pkg> add NomDuPackage


et il est installé physiquement dans votre espace disque (répertoire .julia/).

L'utilisation se fait en début de chaque programme (ou script par "using"). L'initialisation est assez longue, le package étant compilé en directe. Depuis la version 0.4 les packages sont compilés (ou pré-compilés) à l'installation ou premier usage et stocké en fichier pour être rechargé plus rapidement ultérieurement.

<!-- #region -->
```julia
using NomDuPackage
```
<!-- #endregion -->

La commande Pkg permet de gérer les actions faire "]" 

(v1.1) pkg> rm NomDuPackage # rm : remove
(v1.1) pkg> update # comme dit le nom
(v1.1) pkg> precompile # pour forcer la compilation

On verra dans les sections suivantes l'utilisation de quelques packages plus prisés et même jusqu'à la création d'un package !
