package main.types

sealed class QuantifierType {
    abstract fun format(): String

    object ZeroOrMore : QuantifierType() {
        override fun format() = "*"
    }

    object ZeroOrOne : QuantifierType() {
        override fun format() = "?"
    }

    object OneOrMore : QuantifierType() {
        override fun format() = "+"
    }

    class Exactly(private val n: Int) : QuantifierType() {
        override fun format() = "{$n}"
    }

    class AtLeast(private val n: Int) : QuantifierType() {
        override fun format() = "{$n,}"
    }

    class Custom(private val min: Int, private val max: Int) : QuantifierType() {
        override fun format() = "{$min,$max}"
    }

    object ZeroOrMoreLazy : QuantifierType() {
        override fun format() = "*?"
    }

    object ZeroOrOneLazy : QuantifierType() {
        override fun format() = "??"
    }

    object OneOrMoreLazy : QuantifierType() {
        override fun format() = "+?"
    }

    class ExactlyLazy(private val n: Int) : QuantifierType() {
        override fun format() = "{$n}?"
    }

    class AtLeastLazy(private val n: Int) : QuantifierType() {
        override fun format() = "{$n,}?"
    }

    class CustomLazy(private val min: Int, private val max: Int) : QuantifierType() {
        override fun format() = "{$min,$max}?"
    }
}