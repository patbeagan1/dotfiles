package main.builders

import main.RegexBuilder

class QuantifierBuilder : RegexBuilder() {
    fun buildQuantifier(quantifier: String): String {
        return "${super.build()}$quantifier"
    }
}