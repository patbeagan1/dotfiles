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

    fun zeroOrMore(init: QuantifierBuilder.() -> Unit): RegexBuilder {
        val quantifierBuilder = QuantifierBuilder().apply(init)
        stringBuilder.append(quantifierBuilder.buildQuantifier("*"))
        return this
    }

    fun oneOrMore(init: QuantifierBuilder.() -> Unit): RegexBuilder {
        val quantifierBuilder = QuantifierBuilder().apply(init)
        stringBuilder.append(quantifierBuilder.buildQuantifier("+"))
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

    inner class QuantifierBuilder : RegexBuilder() {
        fun buildQuantifier(quantifier: String): String {
            return "(${super.build().pattern})$quantifier"
        }
    }
}

fun main() {
    val regex = RegexBuilder()
        .group {
            literal("ab")
            anyChar()
        }
        .zeroOrMore {
            literal("y")
        }
        .literal("cd")
        .oneOrMore {
            literal("z")
        }
        .build()

    val input = "xabyycdzz"
    val result = regex.containsMatchIn(input)
    println("Match result: $result") // Should print: Match result: true
}
