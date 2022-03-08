function helloworld()
    return "Hello World!"
end

println(helloworld())
println("Le fichier s'appelle $(@__FILE__)")
println("Il est dans le répertoire $(@__DIR__)")
