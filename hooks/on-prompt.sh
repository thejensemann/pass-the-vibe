#!/usr/bin/env bash
#
# pass-the-vibe: UserPromptSubmit hook
# Logs user prompts to branch-specific markdown files
#
set -euo pipefail

# Get repo root for absolute paths
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
VIBE_DIR="$REPO_ROOT/.vibe"

# Read JSON input from stdin
input=$(cat)

# Extract prompt from input (field is "prompt" or "user_prompt")
prompt=$(echo "$input" | jq -r '.prompt // .user_prompt // empty' 2>/dev/null || echo "")

if [[ -z "$prompt" ]]; then
    exit 0
fi

# Get current git branch (sanitize for filename)
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
branch_safe=$(echo "$branch" | tr '/' '-' | tr ' ' '-')

# Get current date
date_prefix=$(date +%Y-%m-%d)

# Build filename
log_file="$VIBE_DIR/${date_prefix}_${branch_safe}.md"

# Create vibe directory if it doesn't exist
mkdir -p "$VIBE_DIR"

# Initialize file with header if it doesn't exist
if [[ ! -f "$log_file" ]]; then
    {
        echo "# Vibe Log: $branch"
        echo ""
        echo "Date: $date_prefix"
        echo ""
        echo "---"
        echo ""
    } > "$log_file"
fi

# Get timestamp
timestamp=$(date +%H:%M:%S)

# Append user prompt
{
    echo "## [$timestamp] User"
    echo ""
    echo "$prompt"
    echo ""
} >> "$log_file"

# Store temp file reference for the stop hook to know where to write
echo "$log_file" > "$VIBE_DIR/.tmp_current_log"

# Exit 0 - don't block, don't output anything to Claude
exit 0
