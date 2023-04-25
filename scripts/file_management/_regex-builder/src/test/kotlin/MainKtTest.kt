import main.RegexBuilder
import main.builders.GroupType.*
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
            .characterGroup {
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
                characterGroup {
                    rangeLowerAZ()
                    rangeUpperAZ()
                    rangeDigit()
                    literal('.')
                    literal('-')
                }
            }
            .literalPhrase(".")
            .quantifier(AtLeast(2)) {
                characterGroup {
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
                characterGroup {
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
                        characterGroup {
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
                        characterGroup {
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
                characterGroup {
                    whitespace()
                    literal('.')
                    literal('-')
                }
            }
            .quantifier(Exactly(3)) { digit() }
            .quantifier(ZeroOrOne) {
                characterGroup {
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


    @Test
    fun `date`() {
        val expected = """^(19|20)\d{2}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$"""
        val actual = RegexBuilder()
            .startOfLine()
            // year
            .group {
                choiceOf({
                    literalPhrase("19")
                }, {
                    literalPhrase("20")
                })
            }
            .quantifier(Exactly(2)) {
                digit()
            }
            .literalPhrase("-")
            // month
            .group {
                choiceOf({
                    literalPhrase("0")
                    characterGroup { range('1', '9') }
                }, {
                    literalPhrase("1")
                    characterGroup { range('0', '2') }
                })
            }
            .literalPhrase("-")
            // day
            .group {
                choiceOf({
                    literalPhrase("0")
                    characterGroup {
                        range('1', '9')
                    }
                }, {
                    characterGroup {
                        literal('1')
                        literal('2')
                    }
                    characterGroup {
                        rangeDigit()
                    }
                }, {
                    literalPhrase("3")
                    characterGroup {
                        literal('0')
                        literal('1')
                    }
                })
            }
            .endOfLine()
            .build()
        assertEquals(expected, actual)
    }

    @Test
    fun `credit card`() {
        val expected = """^(?:\d[ -]?){13,16}$"""
        val actual = RegexBuilder()
            .startOfLine()
            .quantifier(Custom(13, 16)) {
                group(NonCapturing) {
                    digit()
                    quantifier(ZeroOrOne) {
                        characterGroup {
                            literal(' ')
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
    fun `color code`() {
        val expected = """^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"""
        val actual = RegexBuilder()
            .startOfLine()
            .literalPhrase("#")
            .groupChoice({
                quantifier(Exactly(6)) { characterGroup { rangeHexadecimal() } }
            }, {
                quantifier(Exactly(3)) { characterGroup { rangeHexadecimal() } }
            })
            .endOfLine()
            .build()
        assertEquals(expected, actual)
    }
}