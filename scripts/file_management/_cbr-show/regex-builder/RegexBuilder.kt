class RegexBuilder {
    private val stringBuilder = StringBuilder()

    fun literal(value: String): RegexBuilder {
        stringBuilder.append(value.replace(Regex("([\\\\.^$|?*+()\\[\\]{}])"), "\\\\$1"))
        return this
    }

    fun anyChar(): RegexBuilder {
        stringBuilder.append(".")
        return this
    }

    fun zeroOrMore(): RegexBuilder {
        stringBuilder.append("*")
        return this
    }

    fun oneOrMore(): RegexBuilder {
        stringBuilder.append("+")
        return this
    }

    fun optional(): RegexBuilder {
        stringBuilder.append("?")
        return this
    }

    fun group(init: GroupBuilder.() -> Unit): RegexBuilder {
        val groupBuilder = GroupBuilder().apply(init)
        stringBuilder.append(groupBuilder.buildGroup())
        return this
    }

    fun or(): RegexBuilder {
        stringBuilder.append("|")
        return this
    }

    fun build(): Regex {
        return Regex(stringBuilder.toString())
    }

    inner class GroupBuilder : RegexBuilder() {
        fun buildGroup(): String {
            return "(${super.build().pattern})"
        }
    }
}

fun main() {
    val regex = RegexBuilder()
        .group {
            literal("ab")
            anyChar()
            zeroOrMore()
        }
        .literal("cd")
        .oneOrMore()
        .build()

    val input = "xabycdcd"
    val result = regex.containsMatchIn(input)
    println("Match result: $result") // Should print: Match result: true
}
