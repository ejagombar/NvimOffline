#!/usr/bin/env bash
set -e

PARSER_DIR="/home/ejago/Repos/Projects/NvimOffline"

mkdir -p "$PARSER_DIR"

# ===== FUNCTIONS =====
build_parser() {
    local REPO_URL=$1
    local LANG_NAME=$2

    echo "==== Building parser for ${LANG_NAME} ===="

    TMP_DIR=$(mktemp -d)
    git clone --depth=1 "$REPO_URL" "$TMP_DIR"

    pushd "$TMP_DIR" > /dev/null

    # Detect optional scanner files
    EXTRA_SRC=""
    if [ -f src/scanner.c ]; then
        EXTRA_SRC="src/scanner.c"
    elif [ -f src/scanner.cc ]; then
        EXTRA_SRC="src/scanner.cc"
    fi

    # Compile parser
    cc -fPIC -I./src \
       -I"$(python3 -c "import sysconfig; print(sysconfig.get_paths()['include'])")" \
       -shared src/parser.c $EXTRA_SRC \
       -o "${LANG_NAME}.so"

    mv "${LANG_NAME}.so" "$PARSER_DIR/"

    popd > /dev/null
    rm -rf "$TMP_DIR"

    echo "Installed ${LANG_NAME}.so → ${PARSER_DIR}/"
}

# ===== BUILD LIST =====
build_parser "https://github.com/tree-sitter/tree-sitter-c.git" "c"
build_parser "https://github.com/tree-sitter/tree-sitter-cpp.git" "cpp"
build_parser "https://github.com/tree-sitter/tree-sitter-javascript.git" "javascript"

echo "✅ All parsers built and installed in $PARSER_DIR"
echo "📌 In Neovim, add this to your config so it finds them:"
echo "vim.opt.runtimepath:append(\"$(dirname "$PARSER_DIR")\")"

