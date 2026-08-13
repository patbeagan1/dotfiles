import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import java.io.File

fun main(args: Array<String>) {
    if (args.isEmpty()) {
        System.err.println("usage: JsonKeysKt <file|->")
        kotlin.system.exitProcess(2)
    }
    val fileArg = args[0]
    val mapper = ObjectMapper()
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

    if (!root.isObject) {
        System.err.println("root is not a JSON object (got ${root.nodeType})")
        kotlin.system.exitProcess(1)
    }
    for (name in root.fieldNames().asSequence().toList().sorted()) {
        val child = root.get(name)
        val kind = when {
            child.isObject -> "object"
            child.isArray -> "array(${child.size()})"
            child.isTextual -> "string"
            child.isNumber -> "number"
            child.isBoolean -> "boolean"
            child.isNull -> "null"
            else -> child.nodeType.toString().lowercase()
        }
        println("$name\t$kind")
    }
}

fun expandHome(path: String): String {
    if (path == "~") return System.getProperty("user.home")
    if (path.startsWith("~/") || path.startsWith("~\\")) {
        return System.getProperty("user.home") + path.substring(1)
    }
    return path
}
