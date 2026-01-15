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

# Check if a log file already exists for this branch
existing_file=$(find "$VIBE_DIR" -maxdepth 1 -name "*_${branch_safe}.md" 2>/dev/null | head -1)

if [[ -n "$existing_file" ]]; then
    # Use existing file
    log_file="$existing_file"
else
    # Get branch creation date (date of first commit on this branch vs main/master)
    main_branch="main"
    if ! git rev-parse --verify "$main_branch" &>/dev/null; then
        main_branch="master"
    fi

    # Get the date of the first commit on this branch
    date_prefix=""
    merge_base=$(git merge-base HEAD "$main_branch" 2>/dev/null || echo "")
    if [[ -n "$merge_base" ]]; then
        # Get date of first commit after merge base
        date_prefix=$(git log --format=%cs "${merge_base}..HEAD" 2>/dev/null | tail -1)
    fi

    # Fallback to current date if we couldn't determine branch creation date
    if [[ -z "$date_prefix" ]]; then
        date_prefix=$(date +%Y-%m-%d)
    fi

    # Build filename
    log_file="$VIBE_DIR/${date_prefix}_${branch_safe}.md"
fi

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
