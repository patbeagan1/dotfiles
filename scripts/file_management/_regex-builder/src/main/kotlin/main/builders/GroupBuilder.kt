package main.builders

import main.RegexBuilder

class GroupBuilder : RegexBuilder() {
    fun buildGroup(): String {
        return "(${super.build()})"
    }
}