import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.SerializationFeature
import java.io.File

fun main(args: Array<String>) {
    if (args.size < 2) {
        System.err.println("usage: JsonSummaryKt <file|-> <pretty|summary|path> [dotted.path]")
        kotlin.system.exitProcess(2)
    }
    val fileArg = args[0]
    val mode = args[1].lowercase()
    val dotted = args.getOrNull(2).orEmpty()
    val color = wantColor()

    val mapper = ObjectMapper().enable(SerializationFeature.INDENT_OUTPUT)
    val root: JsonNode = if (fileArg == "-") {
        mapper.readTree(System.`in`)
    } else {
        val f = File(expandHome(fileArg))
        if (!f.isFile) {
            System.err.println("file not found: $fileArg")
            kotlin.system.exitProcess(2)
        }
        mapper.readTree(f)
    }

    when (mode) {
        "pretty" -> println(colorizeJson(mapper.writeValueAsString(root), color))
        "summary" -> {
            println("json summary")
            summarize(root, "", 0)
        }
        "path" -> {
            if (dotted.isBlank()) {
                System.err.println("mode=path requires a dotted --path")
                kotlin.system.exitProcess(2)
            }
            val node = walk(root, dotted)
            if (node == null || node.isMissingNode) {
                System.err.println("path not found: $dotted")
                kotlin.system.exitProcess(1)
            }
            if (node.isValueNode && !node.isBinary) {
                println(node.asText())
            } else {
                println(colorizeJson(mapper.writeValueAsString(node), color))
            }
        }
        else -> {
            System.err.println("unknown mode: $mode (pretty|summary|path)")
            kotlin.system.exitProcess(2)
        }
    }
}

fun expandHome(path: String): String {
    if (path == "~") return System.getProperty("user.home")
    if (path.startsWith("~/") || path.startsWith("~\\")) {
        return System.getProperty("user.home") + path.substring(1)
    }
    return path
}

fun wantColor(): Boolean {
    if (!System.getenv("NO_COLOR").isNullOrEmpty()) return false
    // Pretty JSON colors by default; set NO_COLOR=1 to disable.
    return true
}

fun colorizeJson(pretty: String, color: Boolean): String {
    if (!color) return pretty
    val key = "\u001B[36m" // cyan
    val str = "\u001B[32m" // green
    val num = "\u001B[33m" // yellow
    val bool = "\u001B[35m" // magenta
    val nil = "\u001B[90m" // bright black
    val reset = "\u001B[0m"
    val out = StringBuilder(pretty.length + 64)
    var i = 0
    var inString = false
    var escape = false
    var expectKey = false
    while (i < pretty.length) {
        val c = pretty[i]
        when {
            inString -> {
                out.append(c)
                when {
                    escape -> escape = false
                    c == '\\' -> escape = true
                    c == '"' -> {
                        inString = false
                        out.append(reset)
                    }
                }
            }
            c == '"' -> {
                // Look ahead: key if next non-space after closing quote is ':'
                var j = i + 1
                var esc = false
                while (j < pretty.length) {
                    val ch = pretty[j]
                    when {
                        esc -> esc = false
                        ch == '\\' -> esc = true
                        ch == '"' -> break
                    }
                    j++
                }
                var k = j + 1
                while (k < pretty.length && pretty[k].isWhitespace()) k++
                expectKey = k < pretty.length && pretty[k] == ':'
                out.append(if (expectKey) key else str)
                out.append(c)
                inString = true
                escape = false
            }
            c.isDigit() || (c == '-' && i + 1 < pretty.length && pretty[i + 1].isDigit()) -> {
                out.append(num)
                while (i < pretty.length) {
                    val ch = pretty[i]
                    if (ch.isDigit() || ch == '.' || ch == '-' || ch == '+' || ch == 'e' || ch == 'E') {
                        out.append(ch)
                        i++
                    } else break
                }
                out.append(reset)
                continue
            }
            pretty.startsWith("true", i) && isWordEnd(pretty, i + 4) -> {
                out.append(bool).append("true").append(reset)
                i += 4
                continue
            }
            pretty.startsWith("false", i) && isWordEnd(pretty, i + 5) -> {
                out.append(bool).append("false").append(reset)
                i += 5
                continue
            }
            pretty.startsWith("null", i) && isWordEnd(pretty, i + 4) -> {
                out.append(nil).append("null").append(reset)
                i += 4
                continue
            }
            else -> out.append(c)
        }
        i++
    }
    return out.toString()
}

fun isWordEnd(s: String, idx: Int): Boolean {
    if (idx >= s.length) return true
    val c = s[idx]
    return !(c.isLetterOrDigit() || c == '_')
}

fun walk(node: JsonNode, dotted: String): JsonNode? {
    var cur: JsonNode = node
    for (part in dotted.split('.').filter { it.isNotEmpty() }) {
        cur = when {
            cur.isArray && part.toIntOrNull() != null -> cur.get(part.toInt())
            cur.isObject -> cur.get(part)
            else -> return null
        } ?: return null
    }
    return cur
}

fun summarize(node: JsonNode, path: String, depth: Int) {
    val indent = "  ".repeat(depth)
    val label = if (path.isEmpty()) "(root)" else path
    when {
        node.isObject -> {
            val fields = node.fieldNames().asSequence().toList().sorted()
            println("$indent$label: object (${fields.size} keys)")
            for (name in fields) {
                summarize(node.get(name), name, depth + 1)
            }
        }
        node.isArray -> {
            println("$indent$label: array (${node.size()} items)")
            if (node.size() > 0) {
                println("$indent  [0] sample:")
                summarize(node.get(0), "[0]", depth + 2)
            }
        }
        node.isTextual -> println("$indent$label: string (${node.asText().length} chars)")
        node.isNumber -> println("$indent$label: number = ${node.numberValue()}")
        node.isBoolean -> println("$indent$label: boolean = ${node.booleanValue()}")
        node.isNull -> println("$indent$label: null")
        else -> println("$indent$label: ${node.nodeType}")
    }
}
