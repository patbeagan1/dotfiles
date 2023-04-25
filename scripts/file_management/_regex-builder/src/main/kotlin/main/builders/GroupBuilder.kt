package main.builders

import main.RegexBuilder

sealed class GroupType {
    abstract fun format(content: String): String

    object Normal : GroupType() {
        override fun format(content: String): String = "(${content})"
    }

    object Atomic : GroupType() {
        override fun format(content: String): String = "(?>${content})"
    }

    object NonCapturing : GroupType() {
        override fun format(content: String): String = "(?:${content})"
    }
}

class GroupBuilder(private val type: GroupType) : RegexBuilder() {
    fun buildGroup(): String = type.format(build())
}

class NamedGroupBuilder(private val name: String) : RegexBuilder() {
    fun buildNamedGroup(): String = "(?<$name>${super.build()})"
}