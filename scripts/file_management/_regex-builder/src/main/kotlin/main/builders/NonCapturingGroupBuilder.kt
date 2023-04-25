package main.builders

import main.RegexBuilder

class NonCapturingGroupBuilder : RegexBuilder() {
    fun buildNonCapturingGroup(): String {
        return "(?:${super.build()})"
    }
}