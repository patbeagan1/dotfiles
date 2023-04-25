package main

import main.types.QuantifierType.OneOrMore
import main.types.PosixCharacterClass
import main.types.QuantifierType
import main.types.RegexFlag
import java.util.Collections.emptySet

open class RegexBuilder(private val flags: Set<RegexFlag> = emptySet()) {
    val stringBuilder = StringBuilder()

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

    fun startOfLine(): RegexBuilder {
        stringBuilder.append("^")
        return this
    }

    fun endOfLine(): RegexBuilder {
        stringBuilder.append("$")
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

    fun quantifier(type: QuantifierType, init: RegexBuilder.() -> Unit): RegexBuilder {
        val quantifierBuilder = QuantifierBuilder().apply(init)
        stringBuilder.append(quantifierBuilder.buildQuantifier(type.format()))
        return this
    }

    fun build(): String = stringBuilder.toString()

    class LookaheadBuilder : RegexBuilder() {
        fun buildLookahead(): String {
            return "(?=${super.build()})"
        }

        fun buildNegativeLookahead(): String {
            return "(?!${super.build()})"
        }
    }

    class NonCapturingGroupBuilder : RegexBuilder() {
        fun buildNonCapturingGroup(): String {
            return "(?:${super.build()})"
        }
    }

    class NamedGroupBuilder(private val name: String) : RegexBuilder() {
        fun buildNamedGroup(): String {
            return "(?<$name>${super.build()})"
        }
    }

    class LookbehindBuilder : RegexBuilder() {
        fun buildPositiveLookbehind(): String {
            return "(?<=${super.build()})"
        }

        fun buildNegativeLookbehind(): String {
            return "(?<!${super.build()})"
        }
    }

    class AtomicGroupBuilder : RegexBuilder() {
        fun buildAtomicGroup(): String {
            return "(?>${super.build()})"
        }
    }

    class QuantifierBuilder : RegexBuilder() {
        fun buildQuantifier(quantifier: String): String {
            return "${super.build()}$quantifier"
        }
    }
}

fun main() {
    val regex = RegexBuilder()
        .namedGroup("digits") {
            digit()
            quantifier(OneOrMore) {
                digit()
            }
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
        .quantifier(QuantifierType.ZeroOrOne) {
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