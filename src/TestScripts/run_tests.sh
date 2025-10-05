#!/bin/bash

NO_CACHE=${1:-false}

if [ "$NO_CACHE" = "true" ]; then
    echo "▶ Cleaning build..."
    
    swift package clean
    
    echo "▶ Building tests..."
    if ! swift build --build-tests; then
        echo "Build failed!"
        exit 1
    fi
fi

RESULTS_DIR="./TestResults"
mkdir -p "$RESULTS_DIR"

export CONFIG_PATH="./Shared/config.json"

RUN_DATE=$(date +%Y.%m.%d_%H-%M-%S)
RUN_DIR="$RESULTS_DIR/TestReport-$RUN_DATE"
mkdir -p "$RUN_DIR"

chmod +x TestScripts/*.py
chmod +x TestScripts/*.sh

echo "▶ Unit Tests running..."
sh TestScripts/run_unit_tests.sh "$RUN_DIR"
UNIT_CODE=$?
echo "Unit tests exit code: $UNIT_CODE"

echo "▶ Integration Tests running..."
sh TestScripts/run_integration_tests.sh "$RUN_DIR" "$UNIT_CODE"
IT_CODE=$?
echo "Integration tests exit code: $IT_CODE"

echo "▶ E2E Tests running..."
sh TestScripts/run_e2e_tests.sh "$RUN_DIR" "$IT_CODE"
E2E_CODE=$?
echo "E2E tests exit code: $E2E_CODE"

echo "▶ Allure results..."

ALLURE_DIR="./Allure"
ALLURE_RESULTS_DIR="$ALLURE_DIR/allure-results"

mkdir -p "$ALLURE_RESULTS_DIR"

cp "$RUN_DIR"/*.xml "$ALLURE_RESULTS_DIR/" || echo "No XML results found"

# ALLURE_RESULTS_DIR="$RESULTS_DIR/AllureResults"
# ALLURE_HTML_DIR="$RESULTS_DIR/AllureReport"

# rm -rf "$ALLURE_RESULTS_DIR"
# mkdir -p "$ALLURE_RESULTS_DIR"

# cp "$RUN_DIR"/*.xml "$ALLURE_RESULTS_DIR/" || echo "No XML results found"

# if [ -d "$ALLURE_HTML_DIR/history" ]; then
#     echo "▶ Copying Allure history..."
#     mkdir -p "$ALLURE_RESULTS_DIR/history"
#     cp -r "$ALLURE_HTML_DIR/history" "$ALLURE_RESULTS_DIR/"
# fi

# mkdir -p "$ALLURE_HTML_DIR"
# echo "▶ Generating Allure report..."
# if ! allure generate "$ALLURE_RESULTS_DIR" -o "$ALLURE_HTML_DIR" --clean; then
#     echo "Failed to generate Allure report"
#     exit 1
# fi

# allure open "$ALLURE_HTML_DIR"

exit_code=$(( UNIT_CODE || IT_CODE || E2E_CODE ))
exit $exit_code
