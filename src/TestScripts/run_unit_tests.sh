#!/bin/bash

RUN_DIR=${1:-"./TestResults/TestReport-default"}
mkdir -p "$RUN_DIR"

UNIT_TEST_EXIT_CODE=0

if ! swift test --skip-build \
  --filter UnitTests \
  --parallel \
  --num-workers 8 \
  --disable-swift-testing \
  --xunit-output "$RUN_DIR/unit-tests.xml"; then
    UNIT_TEST_EXIT_CODE=1
fi

python3 TestScripts/fix_report.py "$RUN_DIR/unit-tests.xml" UnitTests

exit $UNIT_TEST_EXIT_CODE
