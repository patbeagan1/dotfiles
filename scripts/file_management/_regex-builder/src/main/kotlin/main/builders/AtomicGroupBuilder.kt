package main.builders

import main.RegexBuilder

class AtomicGroupBuilder : RegexBuilder() {
    fun buildAtomicGroup(): String {
        return "(?>${super.build()})"
    }
}