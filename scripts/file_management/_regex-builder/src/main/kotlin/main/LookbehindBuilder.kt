package main

class LookbehindBuilder : RegexBuilder() {
    fun buildPositiveLookbehind(): String {
        return "(?<=${super.build()})"
    }

    fun buildNegativeLookbehind(): String {
        return "(?<!${super.build()})"
    }
}