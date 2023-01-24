#!/usr/bin/env python3
# (c) 2022 Pat Beagan: MIT License

from os import makedirs, path, getcwd
from sys import argv
import argparse
from pathlib import Path

root_dir = path.realpath(getcwd())

print(getcwd())


def to_path(input: str):
    return input.replace("-", "/")


def to_dotpath(input: str):
    return input.replace("-", ".")


def package_to_path(input: str):
    return input.replace(".", "/")


class Gradle:

    def __init__(self, module: str, package_name):
        self.module = module
        self.package_name = package_name

    def setup_settings_gradle(self):
        settings_file = path.join(root_dir, "settings.gradle.kts")
        lines = []
        Path(settings_file).touch()
        with open(settings_file, "r") as f:
            lines = f.readlines()
        lines.append(f"\ninclude(\":{self.module}\")\n")
        with open(settings_file, "w") as f:
            f.writelines(lines)


class GradleAndroid(Gradle):

    def run(self):
        self.setup_main_directory()
        self.setup_test_directory()
        self.setup_build_gradle()
        self.setup_settings_gradle()

    def setup_build_gradle(self):
        with open(path.join(root_dir, self.module, "build.gradle.kts"), "w+") as f:
            f.write("""
plugins {
    kotlin("jvm")
}

android {
    compileSdkVersion = 21
    minSdkVersion 21
}
    """)

    def setup_main_directory(self):
        prefix = path.join(
            root_dir,
            self.module,
            "src",
            "main")
        src_dir = path.join(
            prefix,
            "java",
            package_to_path(self.package_name),
            to_path(self.module))
        res_dir = path.join(prefix, "res")
        makedirs(src_dir)
        makedirs(path.join(res_dir, "layout"))
        makedirs(path.join(res_dir, "values"))
        with open(path.join(src_dir, "Main.kt"), "w+") as f:
            f.writelines(
                [
                    f"package {self.package_name}.{to_dotpath(self.module)}\n",
                    'fun main() = println("hello world")',
                ]
            )
        with open(path.join(prefix, "AndroidManifest.xml"), "w+") as f:
            f.writelines(
                [
                    '<?xml version="1.0" encoding="utf-8"?>\n',
                    '<manifest xmlns:android="http://schemas.android.com/apk/res/android"\n',
                    f'    package="{self.package_name}.{self.module}">'.replace("-", "."),
                    "</manifest>",
                ]
            )

    def setup_test_directory(self):
        prefix = path.join(
            root_dir,
            self.module,
            "src",
            "test")
        makedirs(path.join(
            prefix,
            "java",
            package_to_path(self.package_name),
            to_path(self.module)))
        extensions_dir = path.join(
            prefix,
            "resources",
            "mockito-extensions")
        makedirs(extensions_dir)
        with open(path.join(extensions_dir, "org.mockito.plugins.MockMaker"), "w+") as f:
            f.write("# mock-maker-inline")


class GradleMultiplatform(Gradle):

    def run(self):
        self.setup_main_directory_all()
        self.setup_build_gradle()
        self.setup_settings_gradle()

    def setup_build_gradle(self):
        with open(path.join(root_dir, self.module, "build.gradle.kts"), "w+") as f:
            f.write("""
plugins {
    kotlin("multiplatform") version "1.8.0"
}

kotlin {
    jvm {
        compilations.all {
            kotlinOptions.jvmTarget = "1.8"
        }
        withJava()
        testRuns["test"].executionTask.configure {
            useJUnitPlatform()
        }
    }
    js(BOTH) {
        browser {
            commonWebpackConfig {
                cssSupport {
                    enabled.set(true)
                }
            }
        }
    }
    val hostOs = System.getProperty("os.name")
    val isMingwX64 = hostOs.startsWith("Windows")
    val nativeTarget = when {
        hostOs == "Mac OS X" -> macosX64("native")
        hostOs == "Linux" -> linuxX64("native")
        isMingwX64 -> mingwX64("native")
        else -> throw GradleException("Host OS is not supported in Kotlin/Native.")
    }

    sourceSets {
        val commonMain by getting
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
            }
        }
        val jvmMain by getting
        val jvmTest by getting
        val jsMain by getting
        val jsTest by getting
        val nativeMain by getting
        val nativeTest by getting
    }
}
    """)

    def setup_main_directory_all(self):
        source_sets = [
            "jsMain",
            "jvmMain",
            "commonTest",
            "nativeMain",
            "jsTest",
            "nativeTest",
            "jvmTest",
            "commonMain",
        ]
        prefix = path.join(
            root_dir,
            self.module,
            "src",
        )
        for i in source_sets:
            self.setup_main_directory(i, prefix)

    def setup_main_directory(self, source_set, prefix):
        src_dir = path.join(
            prefix,
            source_set,
            "kotlin",
            package_to_path(self.package_name),
            to_path(self.module))
        makedirs(src_dir)
        with open(path.join(src_dir, "Main.kt"), "w+") as f:
            f.writelines(
                [
                    f"package {self.package_name}.{to_dotpath(self.module)}\n",
                    'fun main() = println("hello world")',
                ]
            )


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="""
       Creates a new module in a gradle project
       """)
    parser.add_argument("module_name", help="The name of the module", type=str)
    parser.add_argument("package_name", help="The package name", type=str)

    arg_group = parser.add_mutually_exclusive_group()
    arg_group.add_argument("-a", "--android", action="store_true",
                           help="generates a new android module")
    arg_group.add_argument("-m", "--multiplatform", action="store_true",
                           help="generates a new kotlin multiplatform module")

    args = parser.parse_args()

    ############################################################################

    if args.android:
        print(f"Generating Android module: {args.module_name}")
        GradleAndroid(args.module_name, args.package_name).run()
    elif args.multiplatform:
        print(f"Generating Multiplatform module: {args.module_name}")
        GradleMultiplatform(args.module_name, args.package_name).run()
    else:
        parser.print_help()
        exit(1)
