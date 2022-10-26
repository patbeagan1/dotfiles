#!/usr/bin/env python3

from os import makedirs, path, getcwd
from sys import argv

root_dir = path.realpath(getcwd())

print(getcwd())


def main(module: str):
    setup_main_directory(module)
    setup_test_directory(module)
    setup_build_gradle(module)
    setup_settings_gradle(module)


def to_path(input: str):
    return input.replace("-", "/")


def to_dotpath(input: str):
    return input.replace("-", ".")


def setup_settings_gradle(module):
    settings_file = path.join(root_dir, "settings.gradle")
    lines = []
    with open(settings_file, "r") as f:
        lines = f.readlines()
    lines.append(f"include ':{module}'")
    with open(settings_file, "w") as f:
        f.writelines(lines)


def setup_build_gradle(module):
    with open(path.join(root_dir, module, "build.gradle"), "w+") as f:
        f.write("apply from: rootProject.file('android-library.gradle')")


def setup_main_directory(module):
    prefix = path.join(
        root_dir,
        module,
        "src",
        "main")
    src_dir = path.join(
        prefix,
        "java",
        "com",
        "example",
        to_path(module))
    res_dir = path.join(prefix, "res")
    makedirs(src_dir)
    makedirs(path.join(res_dir, "layout"))
    makedirs(path.join(res_dir, "values"))
    with open(path.join(src_dir, "Main.kt"), "w+") as f:
        f.writelines(
            [
                f"package com.example.{to_dotpath(module)}",
                'fun main() = println("hello world")',
            ]
        )
    with open(path.join(prefix, "AndroidManifest.xml"), "w+") as f:
        f.writelines(
            [
                '<?xml version="1.0" encoding="utf-8"?>\n',
                '<manifest xmlns:android="http://schemas.android.com/apk/res/android"\n',
                f'    package="com.example.{module}">'.replace("-", "."),
                "</manifest>",
            ]
        )


def setup_test_directory(module):
    prefix = path.join(
        root_dir,
        module,
        "src",
        "test")
    makedirs(path.join(
        prefix,
        "java",
        "com",
        "example",
        to_path(module)))
    extensions_dir = path.join(
        prefix,
        "resources",
        "mockito-extensions")
    makedirs(extensions_dir)
    with open(path.join(extensions_dir, "org.mockito.plugins.MockMaker"), "w+") as f:
        f.write("# mock-maker-inline")


if __name__ == "__main__":
    if len(argv) > 1:
        print(f"Generating module: {argv[1]}")
        main(argv[1])
    else:
        print("Module name argument required")
