import main.RegexBuilder
import main.types.QuantifierType.*
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class MainKtTest {
    @Test
    fun first() {
        val expected = "(ab*c?de)"
        val actual = RegexBuilder()
            .group {
                literalPhrase("a")
                quantifier(ZeroOrMore) { literalPhrase("b") }
                quantifier(ZeroOrOne) { literalPhrase("c") }
                literalPhrase("de")
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
            .literalPhrase("@")
            .quantifier(OneOrMore) {
                characterClass {
                    rangeLowerAZ()
                    rangeUpperAZ()
                    rangeDigit()
                    literal('.')
                    literal('-')
                }
            }
            .literalPhrase(".")
            .quantifier(AtLeast(2)) {
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
            .startOfLine()
            .quantifier(ZeroOrOne) {
                group {
                    literalPhrase("http")
                    quantifier(ZeroOrOne) {
                        literalPhrase("s")
                    }
                    literalPhrase("://")
                }
            }
            .quantifier(OneOrMore) {
                characterClass {
                    wordChar()
                    literal('.')
                    literal('-')
                }
            }.quantifier(ZeroOrOne) {
                group {
                    literalPhrase(":")
                    quantifier(OneOrMore) {
                        digit()
                    }
                }
            }.quantifier(ZeroOrMore) {
                group {
                    literalPhrase("/")
                    quantifier(OneOrMore) {
                        characterClass {
                            wordChar()
                            literal('.')
                            literal('-')
                        }
                    }
                }
            }.quantifier(ZeroOrOne) {
                group {
                    literalPhrase("/?")
                    quantifier(OneOrMore) {
                        characterClass {
                            wordChar()
                            literal('.')
                            literal('=')
                            literal('&')
                            literal('-')
                        }
                    }
                }
            }
            .endOfLine()
            .build()

        assertEquals(expected, actual)
    }

    @Test
    fun `US phone number`() {
        val expected = """^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$"""
        val actual = RegexBuilder()
            .startOfLine()
            .quantifier(ZeroOrOne) {
                group {
                    literalPhrase("+")
                    quantifier(Custom(1, 2)) { digit() }
                    quantifier(ZeroOrOne) { whitespace() }
                }
            }
            .quantifier(ZeroOrOne) { literalPhrase("(") }
            .quantifier(Exactly(3)) { digit() }
            .quantifier(ZeroOrOne) { literalPhrase(")") }
            .quantifier(ZeroOrOne) {
                characterClass {
                    whitespace()
                    literal('.')
                    literal('-')
                }
            }
            .quantifier(Exactly(3)) { digit() }
            .quantifier(ZeroOrOne) {
                characterClass {
                    whitespace()
                    literal('.')
                    literal('-')
                }
            }
            .quantifier(Exactly(4)) { digit() }
            .endOfLine()
            .build()

        assertEquals(expected, actual)
    }
}