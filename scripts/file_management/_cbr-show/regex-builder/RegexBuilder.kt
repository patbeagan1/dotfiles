enum class PosixCharacterClass(val characterClassName: String) {
    ALNUM("alnum"),
    ALPHA("alpha"),
    ASCII("ascii"),
    BLANK("blank"),
    CNTRL("cntrl"),
    DIGIT("digit"),
    GRAPH("graph"),
    LOWER("lower"),
    PRINT("print"),
    PUNCT("punct"),
    SPACE("space"),
    UPPER("upper"),
    WORD("word"),
    XDIGIT("xdigit")
}

enum class RegexFlag(val flag: String) {
    CASE_INSENSITIVE("i"),
    MULTILINE("m"),
    DOTALL("s"),
    UNICODE_CASE("u"),
    UNIX_LINES("d")
}

class RegexBuilder(private val flags: Set<RegexFlag> = emptySet()) {
        private val stringBuilder = StringBuilder()

        fun unicodeProperty(property: String): RegexBuilder {
        stringBuilder.append("\\p{$property}")
        return this
    }

    fun unicodeCharacter(hexCode: String): RegexBuilder {
        stringBuilder.append("\\u$hexCode")
        return this
    }

   fun unicodeScript(script: String): RegexBuilder {
        stringBuilder.append("\\p{Is$script}")
        return this
    }

    fun unicodeCategory(category: String): RegexBuilder {
        stringBuilder.append("\\p{$category}")
        return this
    }

    fun posixCharacterClass(characterClass: PosixCharacterClass): RegexBuilder {
        stringBuilder.append("[:${characterClass.characterClassName}:]")
        return this
    }

fun positiveLookbehind(init: LookbehindBuilder.() -> Unit): RegexBuilder {
        val lookbehindBuilder = LookbehindBuilder().apply(init)
        stringBuilder.append(lookbehindBuilder.buildPositiveLookbehind())
        return this
    }

    fun negativeLookbehind(init: LookbehindBuilder.() -> Unit): RegexBuilder {
        val lookbehindBuilder = LookbehindBuilder().apply(init)
        stringBuilder.append(lookbehindBuilder.buildNegativeLookbehind())
        return this
    }

    fun atomicGroup(init: AtomicGroupBuilder.() -> Unit): RegexBuilder {
        val atomicGroupBuilder = AtomicGroupBuilder().apply(init)
        stringBuilder.append(atomicGroupBuilder.buildAtomicGroup())
        return this
    }

    fun wordBoundary(): RegexBuilder {
        stringBuilder.append("\\b")
        return this
    }

      fun negativeLookahead(init: LookaheadBuilder.() -> Unit): RegexBuilder {
        val lookaheadBuilder = LookaheadBuilder().apply(init)
        stringBuilder.append(lookaheadBuilder.buildNegativeLookahead())
        return this
    }

    fun nonCapturingGroup(init: NonCapturingGroupBuilder.() -> Unit): RegexBuilder {
        val nonCapturingGroupBuilder = NonCapturingGroupBuilder().apply(init)
        stringBuilder.append(nonCapturingGroupBuilder.buildNonCapturingGroup())
        return this
    }

    fun namedGroup(name: String, init: NamedGroupBuilder.() -> Unit): RegexBuilder {
        val namedGroupBuilder = NamedGroupBuilder(name).apply(init)
        stringBuilder.append(namedGroupBuilder.buildNamedGroup())
        return this
    }

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
        val pattern = stringBuilder.toString()
        val flagPattern = flags.joinToString(separator = "", prefix = "(?", postfix = ")") { it.flag }
        return Regex("$flagPattern$pattern")
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

        fun buildNegativeLookahead(): String {
            return "(?!${super.build().pattern})"
        }
    }

    inner class NonCapturingGroupBuilder : RegexBuilder() {
        fun buildNonCapturingGroup(): String {
            return "(?:${super.build().pattern})"
        }
    }

    inner class NamedGroupBuilder(private val name: String) : RegexBuilder() {
        fun buildNamedGroup(): String {
            return "(?<$name>${super.build().pattern})"
        }
    }

        inner class LookbehindBuilder : RegexBuilder() {
        fun buildPositiveLookbehind(): String {
            return "(?<=${super.build().pattern})"
        }

        fun buildNegativeLookbehind(): String {
            return "(?<!${super.build().pattern})"
        }
    }

    inner class AtomicGroupBuilder : RegexBuilder() {
        fun buildAtomicGroup(): String {
            return "(?>${super.build().pattern})"
        }
    }

}

fun main() {
    val regex = RegexBuilder(flags = setOf(RegexFlag.CASE_INSENSITIVE, RegexFlag.MULTILINE))
        .wordBoundary()
        .unicodeScript("Latin") // Characters from the Latin script
        .unicodeCategory("Lu") // Uppercase letters
        .unicodeCharacter("002E") // Unicode character for a period (.)
        .characterClass {
            posixCharacterClass(PosixCharacterClass.ALNUM) // Alphanumeric characters
        }
        .negativeLookbehind {
            literal("c")
        }
        .nonCapturingGroup {
            literal("b")
            anyChar()
        }
        .atomicGroup {
            literal("x")
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
        .wordBoundary()
        .build()

    val input = "A.Byxcdzzxx"
    val result = regex.containsMatchIn(input)
    println("Match result: $result") // Should print: Match result: true
}