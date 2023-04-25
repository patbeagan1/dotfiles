import main.RegexBuilder
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class MainKtTest {
    @Test
    fun first() {
        val expected = "(ab*c?de)"
        val actual = RegexBuilder()
            .group {
                literal("a")
                zeroOrMore { literal("b") }
                zeroOrOne { literal("c") }
                literal("de")
            }.build()
        assertEquals(expected, actual)
    }


    @Test
    fun `email address`() {
        val expected = """^[a-zA-Z0-9._%+-]@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"""
        val actual = RegexBuilder()
            .startOfLine()
            .characterClass {
                rangeLowerAZ()
                rangeUpperAZ()
                rangeDigit()
                literal('.')
                literal('_')
                literal('%')
                literal('+')
                literal('-')
            }
            .literal("@")
            .oneOrMore {
                characterClass {
                    rangeLowerAZ()
                    rangeUpperAZ()
                    rangeDigit()
                    literal('.')
                    literal('-')
                }
            }
            .literal(".")
            .customQuantifier(0, 2) {
                characterClass {
                    range('a', 'z')
                    range('A', 'Z')
                }
            }
            .endOfLine()
            .build()

        assertEquals(expected, actual)

    }

    @Test
    fun `url`() {
        val expected = """^(https?:\/\/)?[\w.-]+(:\d+)?(\/[\w.-]+)*(\/\?[\w.=&-]+)?$"""
        val actual = RegexBuilder()
    }
}