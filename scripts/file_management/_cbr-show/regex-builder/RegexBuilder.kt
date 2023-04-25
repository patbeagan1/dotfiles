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

    fun customQuantifier(min: Int, max: Int, init: QuantifierBuilder.() -> Unit): RegexBuilder {
        val quantifierBuilder = QuantifierBuilder().apply(init)
        stringBuilder.append(quantifierBuilder.buildQuantifier("{$min,$max}"))
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

    fun lookahead(init: LookaheadBuilder.() -> Unit): RegexBuilder {
        val lookaheadBuilder = LookaheadBuilder().apply(init)
        stringBuilder.append(lookaheadBuilder.buildLookahead())
        return this
    }

    fun or(): RegexBuilder {
        stringBuilder.append("|")
        return this
    }

    fun characterClass(init: CharClassBuilder.() -> Unit): RegexBuilder {
        val charClassBuilder = CharClassBuilder().apply(init)
        stringBuilder.append(charClassBuilder.buildCharClass())
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

    inner class CharClassBuilder {
        private val charClassBuilder = StringBuilder()

        fun range(from: Char, to: Char): CharClassBuilder {
            charClassBuilder.append("$from-$to")
            return this
        }

        fun literal(value: Char): CharClassBuilder {
            charClassBuilder.append(value)
            return this
        }

        fun buildCharClass(): String {
            return "[$charClassBuilder]"
        }
    }

    inner class LookaheadBuilder : RegexBuilder() {
        fun buildLookahead(): String {
            return "(?=${super.build().pattern})"
        }
    }
}

fun main() {
    val regex = RegexBuilder()
        .literal("a")
        .characterClass {
            range('1', '9')
        }
        .lookahead {
            literal("b")
        }
        .group {
            literal("b")
            anyChar()
        }
        .zeroOrMore {
            literal("y")
        }
        .literal("cd")
        .oneOrMore {
            literal("z")
        }
        .customQuantifier(2, 4) {
            literal("x")
        }
        .build()

    val input = "a3by
