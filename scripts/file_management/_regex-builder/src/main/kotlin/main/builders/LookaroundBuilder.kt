package main.builders

import main.RegexBuilder

sealed class LookAroundType {
    abstract fun format(content: String): String

    object PositiveLookbehind : LookAroundType() {
        override fun format(content: String): String = "(?<=${content})"
    }

    object NegativeLookbehind : LookAroundType() {
        override fun format(content: String): String = "(?<!${content})"
    }

    object PositiveLookahead : LookAroundType() {
        override fun format(content: String): String = "(?=${content})"
    }

    object NegativeLookahead : LookAroundType() {
        override fun format(content: String): String = "(?!${content})"
    }
}

class LookaroundBuilder(private val type: LookAroundType) : RegexBuilder() {
    fun buildLookaround(): String = type.format(build())
}