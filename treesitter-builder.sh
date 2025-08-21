#!/usr/bin/env bash
set -e
ROOT_DIR="$(pwd)"
mkdir -p "$ROOT_DIR/parser"
mkdir -p "$ROOT_DIR/queries"

# ===== FUNCTIONS =====
build_parser() {
    local REPO_URL=$1
    local LANG_NAME=$2
    echo "==== Building parser for ${LANG_NAME} ===="
    TMP_DIR=$(mktemp -d)
    git clone --depth=1 "$REPO_URL" "$TMP_DIR"
    pushd "$TMP_DIR" > /dev/null
    
    local C_COMPILER="cc"
    local CXX_COMPILER="c++"
    
    # Correctly get the Python include directory
    local PYTHON_INCLUDE_DIR
    PYTHON_INCLUDE_DIR="$(python3 -c "import sysconfig; print(sysconfig.get_paths()['include'])")"
    
    # Use an array for compiler arguments for safety (handles spaces etc.)
    local COMMON_ARGS=(
        -fPIC
        -I./src
        -I"${PYTHON_INCLUDE_DIR}"
    )
    local CXX_EXTRA_ARGS=("-std=c++14")
    local LINKER_FLAGS=("-shared")
    local OUTPUT_FILE="${ROOT_DIR}/parser/${LANG_NAME}.so"
    
    if [ -f "src/scanner.cc" ]; then
        echo "Detected C++ scanner, using C++ compilation..."
        # Use C++ compiler for everything when C++ scanner exists
        LINKER_FLAGS+=("-lstdc++")  # Link C++ standard library
        $CXX_COMPILER "${COMMON_ARGS[@]}" "${CXX_EXTRA_ARGS[@]}" -c src/parser.c -o parser.o
        $CXX_COMPILER "${COMMON_ARGS[@]}" "${CXX_EXTRA_ARGS[@]}" -c src/scanner.cc -o scanner.o
        $CXX_COMPILER "${LINKER_FLAGS[@]}" parser.o scanner.o -o "$OUTPUT_FILE"
    else
        echo "Using C compilation..."
        # Compile C files together
        local EXTRA_SRC=()
        if [ -f "src/scanner.c" ]; then
            EXTRA_SRC=("src/scanner.c")
        fi
        $C_COMPILER "${COMMON_ARGS[@]}" "${LINKER_FLAGS[@]}" src/parser.c "${EXTRA_SRC[@]}" -o "$OUTPUT_FILE"
    fi
    
    # Verify the shared library was created and has proper symbols
    if [ -f "$OUTPUT_FILE" ]; then
        echo "✓ Created shared library: $OUTPUT_FILE"
        # Check if the library has the required tree-sitter symbols
        if command -v nm >/dev/null 2>&1; then
            if nm -D "$OUTPUT_FILE" 2>/dev/null | grep -q "tree_sitter_${LANG_NAME}"; then
                echo "✓ Library contains expected symbols"
            else
                echo "⚠ Warning: Library might be missing expected symbols"
            fi
        fi
    else
        echo "✗ Failed to create shared library"
        popd > /dev/null
        rm -rf "$TMP_DIR"
        return 1
    fi
    
    # Copy queries into queries/<lang>/
    if [ -d queries ]; then
        mkdir -p "$ROOT_DIR/queries/${LANG_NAME}"
        cp -r queries/* "$ROOT_DIR/queries/${LANG_NAME}/"
        echo "✓ Copied queries for ${LANG_NAME}"
    else
        echo "⚠ No queries directory found for ${LANG_NAME}"
    fi
    
    popd > /dev/null
    rm -rf "$TMP_DIR"
    echo "✓ Installed ${LANG_NAME}.so → ${ROOT_DIR}/parser/"
    echo "✓ Installed queries → ${ROOT_DIR}/queries/${LANG_NAME}/"
}

# Build parsers
build_parser "https://github.com/tree-sitter/tree-sitter-c.git" "c"
build_parser "https://github.com/tree-sitter/tree-sitter-cpp.git" "cpp"
build_parser "https://github.com/tree-sitter/tree-sitter-javascript.git" "javascript"

echo "✅ All parsers built and installed in $ROOT_DIR"
echo "📌 In Neovim, add this to your config so it finds them:"
echo "vim.opt.runtimepath:append(\"$ROOT_DIR\")"

# Additional debug info
echo ""
echo "🔍 Debug info:"
echo "Parser files created:"
ls -la "$ROOT_DIR/parser/"
echo ""
echo "Query directories created:"
ls -la "$ROOT_DIR/queries/"
