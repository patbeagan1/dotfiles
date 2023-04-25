package main.types

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