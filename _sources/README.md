[![Binder](https://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/pnavaro/Julia_Introduction/master)

# Introduction au langage Julia

Une introduction à Julia sous forme de notebooks jupyter. Elle a été écrite par [Thierry Clopeau](https://github.com/clopeau/Julia_Introduction) avec la version 1.1 de Julia. J'ai fait quelques corrections pour l'adapter à la version 1.7.

La visualisation est automatique sous Github, pour rendre interactif les notebooks il faut "cloner" le répertoire sur sa machine (ou sur un serveur Jupyter). Pour lire les fichiers au format markdown en tant que notebook jupyter, pensez à installer [jupytext](https://jupytext.readthedocs.io/en/latest/). Vous pouvez aussi utiliser [Weave.jl](https://weavejl.mpastell.com/stable/notebooks/#Converting-between-formats) pour convertir ces fichiers.

```
git clone https://github.com/pnavaro/Julia_Introduction
cd Julia_Introduction
julia --project
julia> import Pkg
julia> Pkg.instantiate()
julia> using IJulia
julia> notebook(dir=pwd())
```

Une version html [jupyterbook](https://jupyterbook.org/) est [disponible](https://pnavaro.github.io/Julia_Introduction)

Toute contribution est la bien-venue à l'aide d'un simple "pull request".

Pierre 
