#!/bin/bash
# Auto-format and lint edited files using project tooling
# This hook runs after file edits to maintain code style

# Read the edited file path from stdin (provided by Cursor)
read -r FILE_PATH

# Exit if no file path provided
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# Find project root (look for package.json, pyproject.toml, etc.)
find_project_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/package.json" ] || [ -f "$dir/pyproject.toml" ] || [ -f "$dir/Cargo.toml" ]; then
            echo "$dir"
            return
        fi
        dir=$(dirname "$dir")
    done
    echo ""
}

PROJECT_ROOT=$(find_project_root "$(dirname "$FILE_PATH")")

# If no project root found, just exit
if [ -z "$PROJECT_ROOT" ]; then
    exit 0
fi

cd "$PROJECT_ROOT" || exit 0

# Detect and run appropriate formatter based on file type and available tools

case "$EXT" in
    ts|tsx|js|jsx|mjs|cjs|json|css|scss|html|md|yaml|yml)
        # JavaScript/TypeScript ecosystem
        
        # Check for Biome (faster, recommended)
        if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
            if command -v biome &> /dev/null || [ -x "./node_modules/.bin/biome" ]; then
                npx biome format --write "$FILE_PATH" 2>/dev/null
                npx biome lint --write "$FILE_PATH" 2>/dev/null
                exit 0
            fi
        fi
        
        # Check for Prettier
        if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f ".prettierrc.js" ] || [ -f "prettier.config.js" ]; then
            if command -v prettier &> /dev/null || [ -x "./node_modules/.bin/prettier" ]; then
                npx prettier --write "$FILE_PATH" 2>/dev/null
            fi
        fi
        
        # Check for ESLint (for ts/js files)
        if [ "$EXT" = "ts" ] || [ "$EXT" = "tsx" ] || [ "$EXT" = "js" ] || [ "$EXT" = "jsx" ]; then
            if [ -f ".eslintrc" ] || [ -f ".eslintrc.json" ] || [ -f ".eslintrc.js" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; then
                if command -v eslint &> /dev/null || [ -x "./node_modules/.bin/eslint" ]; then
                    npx eslint --fix "$FILE_PATH" 2>/dev/null
                fi
            fi
        fi
        ;;
        
    py)
        # Python files
        
        # Check for Ruff (fast, recommended)
        if [ -f "ruff.toml" ] || [ -f ".ruff.toml" ] || [ -f "pyproject.toml" ]; then
            if command -v ruff &> /dev/null; then
                ruff format "$FILE_PATH" 2>/dev/null
                ruff check --fix "$FILE_PATH" 2>/dev/null
                exit 0
            fi
        fi
        
        # Check for Black
        if [ -f "pyproject.toml" ] || [ -f ".black" ]; then
            if command -v black &> /dev/null; then
                black "$FILE_PATH" 2>/dev/null
            fi
        fi
        
        # Check for isort
        if command -v isort &> /dev/null; then
            isort "$FILE_PATH" 2>/dev/null
        fi
        ;;
        
    go)
        # Go files
        if command -v gofmt &> /dev/null; then
            gofmt -w "$FILE_PATH" 2>/dev/null
        fi
        if command -v goimports &> /dev/null; then
            goimports -w "$FILE_PATH" 2>/dev/null
        fi
        ;;
        
    rs)
        # Rust files
        if command -v rustfmt &> /dev/null; then
            rustfmt "$FILE_PATH" 2>/dev/null
        fi
        ;;
        
    rb)
        # Ruby files
        if command -v rubocop &> /dev/null; then
            rubocop -a "$FILE_PATH" 2>/dev/null
        fi
        ;;
        
    php)
        # PHP files
        if [ -f "vendor/bin/php-cs-fixer" ]; then
            ./vendor/bin/php-cs-fixer fix "$FILE_PATH" 2>/dev/null
        elif command -v php-cs-fixer &> /dev/null; then
            php-cs-fixer fix "$FILE_PATH" 2>/dev/null
        fi
        ;;
        
    sql)
        # SQL files
        if command -v sqlfluff &> /dev/null; then
            sqlfluff fix "$FILE_PATH" 2>/dev/null
        fi
        ;;
        
    sh|bash)
        # Shell scripts
        if command -v shfmt &> /dev/null; then
            shfmt -w "$FILE_PATH" 2>/dev/null
        fi
        ;;
esac

exit 0
