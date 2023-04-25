package main.builders

class GroupBuilder(private val type: GroupType) : RegexBuilder() {
    fun buildGroup(): String = type.format(build())
}

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
