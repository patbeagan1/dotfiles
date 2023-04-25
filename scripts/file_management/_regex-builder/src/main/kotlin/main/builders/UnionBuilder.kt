package main.builders

import main.RegexBuilder

class UnionBuilder : RegexBuilder() {

    private val choices = mutableListOf<RegexBuilder.() -> Unit>()

    fun choice(init: RegexBuilder.() -> Unit) {
        choices.add(init)
    }

    fun buildUnion(): String {
        return choices.joinToString("|") { RegexBuilder().apply(it).build() }
    }
}