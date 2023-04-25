package main.builders

import main.RegexBuilder

class LookbehindBuilder : RegexBuilder() {
    fun buildPositiveLookbehind(): String {
        return "(?<=${super.build()})"
    }

    fun buildNegativeLookbehind(): String {
        return "(?<!${super.build()})"
    }
}