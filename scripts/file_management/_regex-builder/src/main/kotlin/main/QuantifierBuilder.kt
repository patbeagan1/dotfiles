package main

class QuantifierBuilder : RegexBuilder() {
    fun buildQuantifier(quantifier: String): String {
        return "${super.build()}$quantifier"
    }
}