#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ET

if len(sys.argv) < 3:
    print("Usage: fix_report.py file.xml SuiteName")
    sys.exit(1)

file_path = sys.argv[1]
suite_name = sys.argv[2]

tree = ET.parse(file_path)
root = tree.getroot()

# Найдём все testsuite и поменяем их имя, если оно "TestResults"
for testsuite in root.findall("testsuite"):
    if testsuite.get("name") == "TestResults":
        testsuite.set("name", suite_name)

tree.write(file_path, encoding="utf-8", xml_declaration=True)
