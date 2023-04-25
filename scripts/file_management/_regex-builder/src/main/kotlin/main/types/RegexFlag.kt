package main.types

enum class RegexFlag(val flag: String) {
    CASE_INSENSITIVE("i"),
    MULTILINE("m"),
    DOTALL("s"),
    UNICODE_CASE("u"),
    UNIX_LINES("d")
}