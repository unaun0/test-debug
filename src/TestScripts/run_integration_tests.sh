#!/bin/bash

RUN_DIR=${1:-"./TestResults/TestReport-default"}
UNIT_TEST_EXIT_CODE=${2:-0}

mkdir -p "$RUN_DIR"

IT_TEST_EXIT_CODE=0

if [ "$UNIT_TEST_EXIT_CODE" -ne 0 ]; then
    echo "Unit tests failed — пропускаем Integration tests."
    python3 TestScripts/generate_skipped_report.py IntegrationTests "$RUN_DIR/integration-tests.xml"
    IT_TEST_EXIT_CODE=$UNIT_TEST_EXIT_CODE
else
    if ! sh TestScripts/clean_db.sh; then
        echo "Failed to clean DB before Integration tests"
        exit 1
    fi

    if ! swift test --skip-build \
      --filter IntegrationTests \
      --parallel \
      --num-workers 1 \
      --disable-swift-testing \
      --xunit-output "$RUN_DIR/integration-tests.xml"; then
        IT_TEST_EXIT_CODE=1
    fi

    if ! sh TestScripts/clean_db.sh; then
        echo "Failed to clean DB after Integration tests"
    fi
fi

python3 TestScripts/fix_report.py "$RUN_DIR/integration-tests.xml" IntegrationTests

exit $IT_TEST_EXIT_CODE

