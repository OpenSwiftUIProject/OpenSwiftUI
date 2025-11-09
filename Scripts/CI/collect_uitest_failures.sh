#!/bin/bash

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <test_log_file> <output_dir>"
    exit 1
fi

TEST_LOG="$1"
OUTPUT_DIR="$2"

mkdir -p "$OUTPUT_DIR/reference"
mkdir -p "$OUTPUT_DIR/failed"
mkdir -p "$OUTPUT_DIR/logs"

cp "$TEST_LOG" "$OUTPUT_DIR/logs/test_output.log" || true

echo "Parsing test log for odiff commands..."

grep -E 'odiff ".*" ".*"' "$TEST_LOG" | while IFS= read -r line; do
    reference_path=$(echo "$line" | sed -n 's/.*odiff "\([^"]*\)" "\([^"]*\)".*/\1/p')
    failed_path=$(echo "$line" | sed -n 's/.*odiff "\([^"]*\)" "\([^"]*\)".*/\2/p')

    if [ -f "$reference_path" ]; then
        filename=$(basename "$reference_path")
        cp "$reference_path" "$OUTPUT_DIR/reference/$filename"
        echo "Copied reference: $filename"
    else
        echo "Reference not found: $reference_path"
    fi

    if [ -f "$failed_path" ]; then
        filename=$(basename "$failed_path")
        cp "$failed_path" "$OUTPUT_DIR/failed/$filename"
        echo "Copied failed: $filename"
    else
        echo "Failed snapshot not found: $failed_path"
    fi
done

reference_count=$(ls -1 "$OUTPUT_DIR/reference" 2>/dev/null | wc -l)
failed_count=$(ls -1 "$OUTPUT_DIR/failed" 2>/dev/null | wc -l)

echo "Collection complete:"
echo "  Reference images: $reference_count"
echo "  Failed images: $failed_count"

if [ "$reference_count" -eq 0 ] && [ "$failed_count" -eq 0 ]; then
    echo "No failed snapshots found in test log"
fi
