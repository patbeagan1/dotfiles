#!/bin/bash
# (c) 2022 Pat Beagan: MIT License
set -euo pipefail

if [ $# -ne 1 ]; then 
	echo "Usage: $0 <module-name>"
	exit 1
fi

echo "include(\"$1\")" >> settings.gradle.kts
mkdir -p "$1/src/main/kotlin/com/example"
mkdir -p "$1/src/main/resources/"
cat << EOF > "$1/src/main/kotlin/com/example/Main.kt"
package com.example;

fun main() = println("Hello")
EOF
cat << EOF > "$1/build.gradle.kts"
plugins {
    kotlin("jvm")
}

group = "com.example"
version = "1.0"

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib"))
}
EOF

