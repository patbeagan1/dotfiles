package main

import main.builders.RegexBuilder
import main.types.QuantifierType
import main.types.QuantifierType.OneOrMore

fun main() {
    val regex = RegexBuilder()
        .groupNamed("digits") {
            digit()
            quantifier(OneOrMore) {
                digit()
            }
        }
//        .comment("Named group for digits")
        .literalPhrase("abc")
        .backreference("digits")
//        .comment("Backreference to digits group")
//        .conditional("digits", {
//            literalPhrase("YES")
//        }, {
//            literalPhrase("NO")
//        })
//        .comment("Conditional depending on the existence of the 'digits' group")
        .quantifier(QuantifierType.ZeroOrOne) {
            literalPhrase("Z")
        }
//        .comment("Zero or one occurrence of 'Z'")
//        .recursion()
//        .comment("Recursive pattern")
        .build()
        .also { println(it) }

    val input = "123abc123YESZ123abc123YESZ"
    val result = Regex(regex).containsMatchIn(input)
    println("Match result: $result") // Should print: Match result: true
}