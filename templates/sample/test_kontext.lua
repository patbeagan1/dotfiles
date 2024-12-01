#!/usr/bin/env lua5.4

local kstd = require "kontext"

print("\ntesting Run")
kstd:of({
    greet = function()
        print("Greetings")
    end
}):run(function()
    greet()
end)

print("\ntesting Let")
kstd:of(5):let(function()
    return it * it
end):let(function()
    print(it)
end)

print("\nEnsure that the 'it' from the let scope is not still bound")
print(it)

print("\ntesting Also")
kstd:of({
    a = 75
}):also(function()
    it.b = 25
end):let(function()
    print(it.a, it.b)
end)

print("\nTesting that the let function can have a named param, instead of an implicit 'it'")
kstd:of(1):let(function()
    print(it + 6)
    return it
end):let(function(named_it)
    print(named_it)
end)

print()

for i = 1, 10, 1 do
    kstd:of(i):takeIf(function()
        return it % 2 == 0
    end):let(function()
        if it then
            print(it)
        end
    end)
end
