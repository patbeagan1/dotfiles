package main.builders

import main.types.CharacterClassType
import main.types.PosixCharacterClass
import main.types.QuantifierType

open class RegexBuilder {
    val stringBuilder = StringBuilder()

    fun literalPhrase(value: String): RegexBuilder {
        stringBuilder.append(value.replace(Regex("([\\\\.^$|?*+()\\[\\]{}/])"), "\\\\$1"))
        return this
    }

    fun unicodeProperty(property: String): RegexBuilder {
        stringBuilder.append("\\p{$property}")
        return this
    }

    fun absoluteStartOfString(): RegexBuilder {
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

    fun wordBoundary(): RegexBuilder {
        stringBuilder.append("\\b")
        return this
    }

    fun anyChar(): RegexBuilder {
        stringBuilder.append(".")
        return this
    }

    fun backreference(name: String): RegexBuilder {
        stringBuilder.append("\\k<")
        stringBuilder.append(name)
        stringBuilder.append(">")
        return this
    }

    // these might only be applicable in dotnet
//    fun conditional(
//        reference: String,
//        ifBuilder: RegexBuilder.() -> Unit,
//        elseBuilder: RegexBuilder.() -> Unit
//    ): RegexBuilder {
//        stringBuilder.append("(?")
//        stringBuilder.append(reference)
//        stringBuilder.append("?")
//        stringBuilder.append(RegexBuilder().apply(ifBuilder).stringBuilder)
//        stringBuilder.append(":")
//        stringBuilder.append(RegexBuilder().apply(elseBuilder).stringBuilder)
//        stringBuilder.append(")")
//        return this
//    }
//
//    fun recursion(): RegexBuilder {
//        stringBuilder.append("\\g<0>")
//        return this
//    }
//
//    fun comment(comment: String): RegexBuilder {
//        stringBuilder.append("(?#")
//        stringBuilder.append(comment)
//        stringBuilder.append(")")
//        return this
//    }

    fun group(type: GroupType = GroupType.Normal, init: GroupBuilder.() -> Unit): RegexBuilder {
        val groupBuilder = GroupBuilder(type).apply(init)
        stringBuilder.append(groupBuilder.buildGroup())
        return this
    }

    fun groupNamed(name: String, init: NamedGroupBuilder.() -> Unit): RegexBuilder {
        val namedGroupBuilder = NamedGroupBuilder(name).apply(init)
        stringBuilder.append(namedGroupBuilder.buildNamedGroup())
        return this
    }

    fun groupChoice(vararg init: RegexBuilder.() -> Unit): RegexBuilder = group {
        choiceOf(*init)
    }

    fun choiceOf(vararg alternates: RegexBuilder.() -> Unit): RegexBuilder {
        val alternatesBuilder = AlternatesBuilder()
        alternates.forEach {
            alternatesBuilder.choice(it)
        }
        stringBuilder.append(alternatesBuilder.buildUnion())
        return this
    }

    fun lookAround(
        type: LookAroundType = LookAroundType.PositiveLookahead,
        init: LookaroundBuilder.() -> Unit
    ): RegexBuilder {
        val lookAround = LookaroundBuilder(type).apply(init)
        stringBuilder.append(lookAround.buildLookaround())
        return this
    }

    fun characterClass(
        type: CharacterClassType = CharacterClassType.Positive,
        init: CharClassBuilder.() -> Unit
    ): RegexBuilder {
        val charClassBuilder = CharClassBuilder(type).apply(init)
        stringBuilder.append(charClassBuilder.buildCharClass())
        return this
    }

    fun characterClassPosix(characterClass: PosixCharacterClass): RegexBuilder {
        stringBuilder.append("[:${characterClass.characterClassName}:]")
        return this
    }

    fun quantifier(
        type: QuantifierType,
        init: RegexBuilder.() -> Unit
    ): RegexBuilder {
        val quantifierBuilder = QuantifierBuilder().apply(init)
        stringBuilder.append(quantifierBuilder.buildQuantifier(type.format()))
        return this
    }

    fun build(): String = stringBuilder.toString()
    fun buildToRegex(): Regex = Regex(build())
}