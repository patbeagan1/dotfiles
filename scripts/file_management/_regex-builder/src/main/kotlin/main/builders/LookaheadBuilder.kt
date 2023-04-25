package main.builders

import main.RegexBuilder

class LookaheadBuilder : RegexBuilder() {
    fun buildLookahead(): String {
        return "(?=${super.build()})"
    }

    fun buildNegativeLookahead(): String {
        return "(?!${super.build()})"
    }
}