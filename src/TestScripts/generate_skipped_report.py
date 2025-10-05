#!/usr/bin/env python3
import sys
import subprocess
import xml.etree.ElementTree as ET

if len(sys.argv) < 3:
    print("Usage: generate_skipped_report.py <substring> <output.xml>")
    sys.exit(1)

substring = sys.argv[1]
output_file = sys.argv[2]

print(f"Getting full test list (filtering by: '{substring}')")

result = subprocess.run(
    [
        "swift", "test", "list", "--skip-build", "--disable-index-store",
        "--disable-code-coverage"
    ],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True
)

if result.returncode != 0:
    print(f"Failed to list tests:\n{result.stderr}")
    sys.exit(1)

testcases = []
for line in result.stdout.splitlines():
    if "." in line and "/" in line:
        classname, testname = line.strip().split("/", 1)
        if substring in classname or substring in testname:
            testcases.append((classname, testname))

print(f"Found {len(testcases)} tests to skip")

root = ET.Element("testsuites")
testsuite = ET.SubElement(root, "testsuite", {
    "name": substring,
    "errors": "0",
    "failures": "0",
    "tests": str(len(testcases)),
    "skipped": str(len(testcases)),
    "time": "0"
})

for classname, name in testcases:
    tc = ET.SubElement(testsuite, "testcase", {
        "classname": classname,
        "name": name,
        "time": "0"
    })
    ET.SubElement(tc, "skipped", {"message": ""})

tree = ET.ElementTree(root)
tree.write(output_file, encoding="utf-8", xml_declaration=True)

print(f"Skipped tests report written to: {output_file}")

