package main.builders

class NamedGroupBuilder(private val name: String) : RegexBuilder() {
    fun buildNamedGroup(): String = "(?<$name>${super.build()})"
}