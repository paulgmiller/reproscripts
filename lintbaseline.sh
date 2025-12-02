!/bin/bash

# Golangci-lint binary path (adjust as needed)
golangci_lint_bin="golangci-lint"

# Specific linter to run (replace with your desired linter)
linter="unused"

# Prepend comment with no-lint directive
no_lint_comment="//nolint:$linter"

# Run golangci-lint with specified linter
files=$($golangci_lint_bin run --linter $linter --output=filepath)

# Loop through flagged files
for file in $files; do
  # Check if file already exists (avoid overwriting)
  if [ -f "$file" ]; then
    # Prepend comment with no-lint directive using sed
    sed -i "1s/^/$no_lint_comment/" "$file"
  fi
done

echo "Prepended '$no_lint_comment' comments to flagged files."