package main

class GroupBuilder : RegexBuilder() {
    fun buildGroup(): String {
        return "(${super.build()})"
    }
}