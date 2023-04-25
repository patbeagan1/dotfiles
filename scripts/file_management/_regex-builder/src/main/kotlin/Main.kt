import java.util.Collections.emptySet

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

open class RegexBuilder(private val flags: Set<RegexFlag> = emptySet()) {
    private val stringBuilder = StringBuilder()

    fun unicodeProperty(property: String): RegexBuilder {
        stringBuilder.append("\\p{$property}")
        return this
    }

    fun startOfString(): RegexBuilder {
        stringBuilder.append("\\A")
        return this
    }

    fun endOfStringOrBeforeNewlineAtEnd(): RegexBuilder {
        stringBuilder.append("\\Z")
        return this
    }

    fun absoluteEndOfString(): RegexBuilder {
        stringBuilder.append("\\z")
        return this
    }

    fun endOfPreviousMatch(): RegexBuilder {
        stringBuilder.append("\\G")
        return this
    }

    fun escapeSequence(sequence: String): RegexBuilder {
        stringBuilder.append("\\Q$sequence\\E")
        return this
    }


    fun whitespace(): RegexBuilder {
        stringBuilder.append("\\s")
        return this
    }

    fun nonWhitespace(): RegexBuilder {
        stringBuilder.append("\\S")
        return this
    }

    fun wordChar(): RegexBuilder {
        stringBuilder.append("\\w")
        return this
    }

    fun nonWordChar(): RegexBuilder {
        stringBuilder.append("\\W")
        return this
    }

    fun digit(): RegexBuilder {
        stringBuilder.append("\\d")
        return this
    }

    fun nonDigit(): RegexBuilder {
        stringBuilder.append("\\D")
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

    fun backreference(name: String): RegexBuilder {
        stringBuilder.append("\\k<")
        stringBuilder.append(name)
        stringBuilder.append(">")
        return this
    }

    fun conditional(
        reference: String,
        ifBuilder: RegexBuilder.() -> Unit,
        elseBuilder: RegexBuilder.() -> Unit
    ): RegexBuilder {
        stringBuilder.append("(?")
        stringBuilder.append(reference)
        stringBuilder.append("?")
        stringBuilder.append(RegexBuilder().apply(ifBuilder).stringBuilder)
        stringBuilder.append(":")
        stringBuilder.append(RegexBuilder().apply(elseBuilder).stringBuilder)
        stringBuilder.append(")")
        return this
    }

    fun recursion(): RegexBuilder {
        stringBuilder.append("\\g<0>")
        return this
    }

    fun comment(comment: String): RegexBuilder {
        stringBuilder.append("(?#")
        stringBuilder.append(comment)
        stringBuilder.append(")")
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

    fun zeroOrOne(builder: RegexBuilder.() -> Unit): RegexBuilder {
        stringBuilder.append(RegexBuilder().apply(builder).stringBuilder)
        stringBuilder.append("?")
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

    fun build(): String {
        val pattern = stringBuilder.toString()
        val flagPattern =""// flags.joinToString(separator = "", prefix = "(?", postfix = ")") { it.flag }
        return "$flagPattern$pattern"
    }

    inner class GroupBuilder : RegexBuilder() {
        fun buildGroup(): String {
            return "(${super.build()})"
        }
    }

    inner class QuantifierBuilder : RegexBuilder() {
        fun buildQuantifier(quantifier: String): String {
            return "${super.build()}$quantifier"
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
            return "(?=${super.build()})"
        }

        fun buildNegativeLookahead(): String {
            return "(?!${super.build()})"
        }
    }

    inner class NonCapturingGroupBuilder : RegexBuilder() {
        fun buildNonCapturingGroup(): String {
            return "(?:${super.build()})"
        }
    }

    inner class NamedGroupBuilder(private val name: String) : RegexBuilder() {
        fun buildNamedGroup(): String {
            return "(?<$name>${super.build()})"
        }
    }

    inner class LookbehindBuilder : RegexBuilder() {
        fun buildPositiveLookbehind(): String {
            return "(?<=${super.build()})"
        }

        fun buildNegativeLookbehind(): String {
            return "(?<!${super.build()})"
        }
    }

    inner class AtomicGroupBuilder : RegexBuilder() {
        fun buildAtomicGroup(): String {
            return "(?>${super.build()})"
        }
    }

}

fun main() {
    val regex = RegexBuilder()
        .namedGroup("digits") {
            digit()
            oneOrMore { digit() }
        }
//        .comment("Named group for digits")
        .literal("abc")
        .backreference("digits")
//        .comment("Backreference to digits group")
//        .conditional("digits", {
//            literal("YES")
//        }, {
//            literal("NO")
//        })
//        .comment("Conditional depending on the existence of the 'digits' group")
        .zeroOrOne {
            literal("Z")
        }
//        .comment("Zero or one occurrence of 'Z'")
//        .recursion()
//        .comment("Recursive pattern")
        .build()

    val input = "123abc123YESZ123abc123YESZ"
    val result = Regex(regex).containsMatchIn(input)
    println("Match result: $result") // Should print: Match result: true
}