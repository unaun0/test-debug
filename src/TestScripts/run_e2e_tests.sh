#!/bin/bash

RUN_DIR=${1:-"./TestResults/TestReport-default"}
IT_EXIT_CODE=${2:-0}

mkdir -p "$RUN_DIR"

E2E_TEST_EXIT_CODE=0

if [ "$IT_EXIT_CODE" -ne 0 ]; then
    echo "Integration tests failed — пропускаем E2E tests."
    python3 TestScripts/generate_skipped_report.py E2ETests "$RUN_DIR/e2e-tests.xml"
    E2E_TEST_EXIT_CODE=$IT_EXIT_CODE
else
    if ! sh TestScripts/clean_db.sh; then
        echo "Failed to clean DB before E2E tests"
        exit 1
    fi

    if ! swift test --skip-build \
      --filter E2ETests \
      --parallel \
      --num-workers 1 \
      --disable-swift-testing \
      --xunit-output "$RUN_DIR/e2e-tests.xml"; then
        E2E_TEST_EXIT_CODE=1
    fi

    if ! sh TestScripts/clean_db.sh; then
        echo "Failed to clean DB after E2E tests"
    fi
fi

python3 TestScripts/fix_report.py "$RUN_DIR/e2e-tests.xml" E2ETests

exit $E2E_TEST_EXIT_CODE
