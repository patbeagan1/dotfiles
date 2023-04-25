package main.builders

import main.RegexBuilder

class NamedGroupBuilder(private val name: String) : RegexBuilder() {
    fun buildNamedGroup(): String {
        return "(?<$name>${super.build()})"
    }
}