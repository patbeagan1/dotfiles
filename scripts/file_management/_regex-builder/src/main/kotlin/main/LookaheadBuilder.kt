package main

class LookaheadBuilder : RegexBuilder() {
    fun buildLookahead(): String {
        return "(?=${super.build()})"
    }

    fun buildNegativeLookahead(): String {
        return "(?!${super.build()})"
    }
}