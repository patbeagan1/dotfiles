#!/usr/bin/env python3

import argparse
import re
import xml.etree.ElementTree as ET
from xml.dom import minidom

# -------- DSL to XML --------


def parse_attributes(attr_string):
    attrs = {}
    if attr_string:
        attr_pairs = re.findall(r'(\w+)\s*=\s*("[^"]*"|\d+|\w+)', attr_string)
        for key, value in attr_pairs:
            if not (value.startswith('"') and value.endswith('"')):
                value = f'"{value}"'
            attrs[key] = value
    return attrs


def dsl_to_xml(lines, indent_level=0):
    xml = ""
    indent = "  " * indent_level

    while lines:
        line = lines.pop(0).strip()
        if not line:
            continue

        if line.startswith("#"):
            xml += f"{indent}<!-- {line[1:].strip()} -->\n"
            continue

        if re.match(r"^CDATA\s*\{", line):
            cdata_content = ""
            while lines:
                l = lines.pop(0).strip()
                if l == "}":
                    break
                match = re.match(r'"(.*)"', l)
                if match:
                    cdata_content += match.group(1)
            xml += f"{indent}<![CDATA[{cdata_content}]]>\n"
            continue

        match = re.match(r"(\w+)\s*(\([^)]*\))?\s*(\{)?$", line)
        if match:
            tag = match.group(1)
            attr_str = match.group(2)
            has_block = match.group(3) == "{"
            attrs = parse_attributes(attr_str[1:-1] if attr_str else "")
            attr_xml = (
                " " + " ".join(f"{k}={v}" for k, v in attrs.items()) if attrs else ""
            )

            if has_block:
                xml += f"{indent}<{tag}{attr_xml}>\n"
                xml += dsl_to_xml(lines, indent_level + 1)
                xml += f"{indent}</{tag}>\n"
            else:
                xml += f"{indent}<{tag}{attr_xml} />\n"
            continue

        if line == "}":
            return xml

        match = re.match(r'"(.*)"', line)
        if match:
            xml += f"{indent}{match.group(1)}\n"
        else:
            xml += f"{indent}{line}\n"

    return xml


def validate_dsl_syntax(dsl_string):
    stack = []
    in_quote = False
    for i, char in enumerate(dsl_string):
        if char == '"':
            in_quote = not in_quote
        elif not in_quote:
            if char == "{":
                stack.append("{")
            elif char == "}":
                if not stack or stack.pop() != "{":
                    return False, f"Unmatched closing brace at position {i}"
    if in_quote:
        return False, "Unclosed quotation mark"
    if stack:
        return False, "Unclosed brace(s)"
    return True, "DSL syntax is valid"


def validate_xml(xml_string):
    try:
        ET.fromstring(f"<root>{xml_string}</root>")
        return True, "XML is valid"
    except ET.ParseError as e:
        return False, f"XML Parse Error: {e}"


# -------- XML to DSL --------


def xml_to_dsl(elem, indent_level=0):
    indent = "  " * indent_level
    dsl = ""

    # Skip root wrapper if present
    if elem.tag == "root":
        for child in elem:
            dsl += xml_to_dsl(child, indent_level)
        return dsl

    attrs = elem.attrib
    attr_str = (
        "(" + ", ".join(f"{k}={repr(v)}" for k, v in attrs.items()) + ")"
        if attrs
        else ""
    )

    children = list(elem)
    has_text = elem.text and elem.text.strip()

    if not children and has_text:
        dsl += f"{indent}{elem.tag}{attr_str} {{"
        dsl += f' "{elem.text.strip()}"'
        dsl += f"}}\n"

    elif children or has_text:
        dsl += f"{indent}{elem.tag}{attr_str} {{\n"
        if has_text:
            dsl += f'{indent}  "{elem.text.strip()}"\n'

        for child in children:
            if isinstance(child.tag, str):
                dsl += xml_to_dsl(child, indent_level + 1)
            elif child.tag is ET.Comment:
                dsl += f"{indent}  # {child.text.strip()}\n"

        dsl += f"{indent}}}\n"
    else:
        dsl += f"{indent}{elem.tag}{attr_str}()\n"

    return dsl


def replacer(match):
    print("replace")
    prefix = match.group(1)
    inner = match.group(2)
    return f"{prefix} {{\n  {inner.strip()}\n}}"


def expand_single_line_blocks(dsl_code: str) -> str:
    """
    Replaces single-line DSL blocks like `something { foo() }` with:
        something {
            foo()
        }
    Only applies to blocks fully contained on a single line.
    """
    pattern = re.compile(r"\s*(\w+\s*\(?[^\)]*\)?\s*)\{\s*(.*?)\s*\}")
    print("expand")

    new_var = pattern.sub(replacer, dsl_code)
    print("expandAfter: " + new_var)
    return new_var


# -------- Main Entrypoint --------


def main():
    parser = argparse.ArgumentParser(description="Convert between DSL and XML.")
    parser.add_argument(
        "--dsl2xml",
        nargs=2,
        metavar=("input.dsl", "output.xml"),
        help="Convert DSL to XML",
    )
    parser.add_argument(
        "--xml2dsl",
        nargs=2,
        metavar=("input.xml", "output.dsl"),
        help="Convert XML to DSL",
    )
    args = parser.parse_args()

    if args.dsl2xml:
        in_file, out_file = args.dsl2xml
        with open(in_file, "r") as f:
            dsl_input = f.read()

        valid_dsl, msg = validate_dsl_syntax(dsl_input)
        if not valid_dsl:
            print("Error:", msg)
            return

        # replace single line dsl functions with multiline ones
        lines = [expand_single_line_blocks(it) for it in dsl_input.strip().splitlines()]

        xml_output = dsl_to_xml(lines)
        pretty_xml = minidom.parseString(f"<root>{xml_output}</root>").toprettyxml(
            indent="  "
        )
        with open(out_file, "w") as f:
            f.write(pretty_xml.replace("<root>", "").replace("</root>", "").strip())
        print(f"Converted DSL → XML: {out_file}")

    elif args.xml2dsl:
        in_file, out_file = args.xml2dsl
        tree = ET.parse(in_file)
        root = tree.getroot()
        dsl_output = xml_to_dsl(root)
        with open(out_file, "w") as f:
            f.write(dsl_output)
        print(f"Converted XML → DSL: {out_file}")

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
