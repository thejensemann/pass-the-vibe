#!/usr/bin/env bash
#
# pass-the-vibe: Stop hook
# Logs Claude's response to branch-specific markdown files
#
set -euo pipefail

# Get repo root for absolute paths
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
VIBE_DIR="$REPO_ROOT/.vibe"

# Read JSON input from stdin
input=$(cat)

# Get the transcript path from the input
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

# Get current log file from temp reference
if [[ ! -f "$VIBE_DIR/.tmp_current_log" ]]; then
    exit 0
fi

log_file=$(cat "$VIBE_DIR/.tmp_current_log")

if [[ -z "$log_file" ]] || [[ ! -f "$log_file" ]]; then
    exit 0
fi

# Get timestamp
timestamp=$(date +%H:%M:%S)

# Extract Claude's last response from transcript if available
response=""
if [[ -n "$transcript_path" ]] && [[ -f "$transcript_path" ]]; then
    # Transcript is JSONL - get the last assistant message
    response=$(tail -100 "$transcript_path" 2>/dev/null | \
        jq -r 'select(.role == "assistant") | .content // empty' 2>/dev/null | \
        tail -1 || echo "")
fi

# If we couldn't extract response, note that
if [[ -z "$response" ]]; then
    response="*(Response logged - see conversation for details)*"
fi

# Append Claude's response
{
    echo "## [$timestamp] Claude"
    echo ""
    echo "$response"
    echo ""
    echo "---"
    echo ""
} >> "$log_file"

# Clean up temp file
rm -f "$VIBE_DIR/.tmp_current_log"

# Exit 0 - don't block
exit 0
