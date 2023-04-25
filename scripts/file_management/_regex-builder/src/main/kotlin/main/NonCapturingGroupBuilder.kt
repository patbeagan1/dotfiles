package main

class NonCapturingGroupBuilder : RegexBuilder() {
    fun buildNonCapturingGroup(): String {
        return "(?:${super.build()})"
    }
}