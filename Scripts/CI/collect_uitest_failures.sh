#!/bin/bash

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <test_log_file> <output_dir> [xcresult_path]"
    exit 1
fi

TEST_LOG="$1"
OUTPUT_DIR="$2"
XCRESULT_PATH="${3:-}"

mkdir -p "$OUTPUT_DIR/reference"
mkdir -p "$OUTPUT_DIR/failed"
mkdir -p "$OUTPUT_DIR/diff"
mkdir -p "$OUTPUT_DIR/logs"

cp "$TEST_LOG" "$OUTPUT_DIR/logs/test_output.log" || true

echo "Parsing test log for odiff commands..."

grep -E 'odiff ".*" ".*"' "$TEST_LOG" | while IFS= read -r line; do
    reference_path=$(echo "$line" | sed -n 's/.*odiff "\([^"]*\)" "\([^"]*\)".*/\1/p')
    failed_path=$(echo "$line" | sed -n 's/.*odiff "\([^"]*\)" "\([^"]*\)".*/\2/p')

    if [ -f "$reference_path" ]; then
        foldername=$(basename "$(dirname "$reference_path")")
        filename=$(basename "$reference_path")
        mkdir -p "$OUTPUT_DIR/reference/$foldername"
        cp "$reference_path" "$OUTPUT_DIR/reference/$foldername/$filename"
        echo "Copied reference: $foldername/$filename"
    else
        echo "Reference not found: $reference_path"
    fi

    if [ -f "$failed_path" ]; then
        foldername=$(basename "$(dirname "$failed_path")")
        filename=$(basename "$failed_path")
        mkdir -p "$OUTPUT_DIR/failed/$foldername"
        cp "$failed_path" "$OUTPUT_DIR/failed/$foldername/$filename"
        echo "Copied failed: $foldername/$filename"

        # Generate diff image using odiff if both reference and failed exist
        if [ -f "$reference_path" ] && command -v odiff &>/dev/null; then
            ref_foldername=$(basename "$(dirname "$reference_path")")
            mkdir -p "$OUTPUT_DIR/diff/$foldername"
            diff_output="$OUTPUT_DIR/diff/$foldername/$filename"
            odiff "$reference_path" "$failed_path" "$diff_output" 2>/dev/null || true
            if [ -f "$diff_output" ]; then
                echo "Generated diff: $foldername/$filename"
            fi
        fi
    else
        echo "Failed snapshot not found: $failed_path"
    fi
done

# Copy xcresult bundle if provided and exists
if [ -n "$XCRESULT_PATH" ] && [ -d "$XCRESULT_PATH" ]; then
    mkdir -p "$OUTPUT_DIR/xcresult"
    cp -R "$XCRESULT_PATH" "$OUTPUT_DIR/xcresult/"
    echo "Copied xcresult bundle: $(basename "$XCRESULT_PATH")"
fi

reference_count=$(find "$OUTPUT_DIR/reference" -type f 2>/dev/null | wc -l)
failed_count=$(find "$OUTPUT_DIR/failed" -type f 2>/dev/null | wc -l)
diff_count=$(find "$OUTPUT_DIR/diff" -type f 2>/dev/null | wc -l)

echo ""
echo "Collection complete:"
echo "  Reference images: $reference_count"
echo "  Failed images: $failed_count"
echo "  Diff images: $diff_count"
if [ -n "$XCRESULT_PATH" ] && [ -d "$XCRESULT_PATH" ]; then
    echo "  xcresult bundle: copied"
else
    echo "  xcresult bundle: not provided or not found"
fi

if [ "$reference_count" -eq 0 ] && [ "$failed_count" -eq 0 ]; then
    echo "No failed snapshots found in test log"
fi
