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
}