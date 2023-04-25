package main

class CharClassBuilder : RegexBuilder() {

    fun buildCharClass(): String {
        return "[${super.build()}]"
    }

    fun range(from: Char, to: Char): CharClassBuilder {
        stringBuilder.append("$from-$to")
        return this
    }

    fun literal(value: Char): CharClassBuilder {
        stringBuilder.append(value)
        return this
    }

    fun rangeLowerAZ() = range('a', 'z')
    fun rangeUpperAZ() = range('A', 'Z')
    fun rangeDigit() = range('0', '9')
}