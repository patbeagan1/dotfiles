package main.builders

internal class QuantifierBuilder : RegexBuilder() {
    fun buildQuantifier(quantifier: String): String {
        return "${super.build()}$quantifier"
    }
}