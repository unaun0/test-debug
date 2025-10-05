#!/bin/bash

SRC_FILE="./Sources/Domain/Protocols/DataAccess/ITrainerRepository.swift"
DEST_FILE="./Tests/AppTests/Mocks/GeneratedMocks.swift"
IMPORTS="Backend"

echo "🔄 $SRC_FILE ..."

mockolo \
  --sourcefiles $SRC_FILE \
  --destination $DEST_FILE \
  --testable-imports $IMPORTS

if [ $? -eq 0 ]; then
  echo "Success: $DEST_FILE"
else
  echo "Error"
  exit 1
fi

