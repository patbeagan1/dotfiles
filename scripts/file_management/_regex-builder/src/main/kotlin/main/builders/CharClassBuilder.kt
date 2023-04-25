package main.builders

import main.types.CharacterClassType
import main.types.CharacterClassType.Negative
import main.types.CharacterClassType.Positive

class CharClassBuilder(private val type: CharacterClassType) : RegexBuilder() {

    fun buildCharClass(): String = when (type) {
        Positive -> "[${super.build()}]"
        Negative -> "[^${super.build()}]"
    }

    fun range(from: Char, to: Char): CharClassBuilder {
        stringBuilder.append("$from-$to")
        return this
    }

    fun literal(value: Char): CharClassBuilder {
        stringBuilder.append(value)
        return this
    }

    fun range(from: Int, to: Int): CharClassBuilder {
        val characterCodeOffset = 48
        val acceptableRange = 0..9
        if (from !in acceptableRange || to !in acceptableRange) throw IndexOutOfBoundsException()
        return range(Char(from + characterCodeOffset), Char(to + characterCodeOffset))
    }

    fun rangeLowerAZ() = range('a', 'z')
    fun rangeUpperAZ() = range('A', 'Z')
    fun rangeDigit() = range('0', '9')
    fun rangeHexadecimal() = range('A', 'F')
        .range('a', 'f')
        .rangeDigit()
}