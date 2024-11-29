
local kontext = require "kontext"

print("\ntesting Run")
kontext:of({
    greet = function()
        print("Greetings")
    end
}):run(function()
    greet()
end)

print("\ntesting Let")
kontext:of(5):let(function(it)
    return it * it
end):let(function(it)
    print(it)
end)

print("\ntesting Also")
kontext:of({
    a = 75
}):also(function(it)
    it.b = 25
end):let(function(it)
    print(it.a, it.b)
end)

print("\ntesting Apply")
kontext:of({
    a = 75
}):apply(function()
    b = 25
end):let(function(it)
    print(it.a, it.b)
end)
