#!/usr/bin/env kscript

import java.io.File

// Get the passed in path, i.e. "-d some/path" or use the current path.
File(if (args.contains("-d")) args[1 + args.indexOf("-d")] else ".")
        .listFiles { file -> file.isDirectory() }
        ?.forEach { folder -> println(folder) }
