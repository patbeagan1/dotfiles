package main

class AtomicGroupBuilder : RegexBuilder() {
    fun buildAtomicGroup(): String {
        return "(?>${super.build()})"
    }
}