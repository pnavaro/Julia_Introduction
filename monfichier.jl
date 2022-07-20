
function helloworld()
    return "Hello World!"
end

println(helloworld())
println("Le fichier s'appelle $(@__FILE__)")
println("Il est dans le répertoire $(@__DIR__)")

f(x, y) = 3x + 2

println(f(4,5))
