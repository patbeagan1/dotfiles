package main

class CharClassBuilder {
    private val charClassBuilder = StringBuilder()

    fun range(from: Char, to: Char): CharClassBuilder {
        charClassBuilder.append("$from-$to")
        return this
    }

    fun rangeLowerAZ() = range('a', 'z')
    fun rangeUpperAZ() = range('A', 'Z')
    fun rangeDigit() = range('0', '9')

    fun literal(value: Char): CharClassBuilder {
        charClassBuilder.append(value)
        return this
    }

    fun buildCharClass(): String {
        return "[$charClassBuilder]"
    }
}