#!/usr/bin/env bash
# Detect project type and return icon

dir="${1:-.}"

# Check for git repo
if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch=$(git -C "$dir" branch --show-current 2>/dev/null)
    git_icon="git:$git_branch"
else
    git_icon=""
fi

# Detect language based on files
lang_icon=""

if [ -f "$dir/Cargo.toml" ]; then
    lang_icon="rs"
elif [ -f "$dir/package.json" ]; then
    lang_icon="js"
elif [ -f "$dir/pyproject.toml" ] || [ -f "$dir/setup.py" ] || [ -f "$dir/requirements.txt" ]; then
    lang_icon="py"
elif [ -f "$dir/go.mod" ]; then
    lang_icon="go"
elif [ -f "$dir/pom.xml" ] || [ -f "$dir/build.gradle" ]; then
    lang_icon="java"
elif [ -f "$dir/CMakeLists.txt" ]; then
    lang_icon="c++"
elif [ -f "$dir/Makefile" ]; then
    # Check for C or C++ in Makefile
    if grep -q "g++\|clang++" "$dir/Makefile" 2>/dev/null; then
        lang_icon="c++"
    else
        lang_icon="c"
    fi
elif [ -f "$dir/*.c" ] 2>/dev/null; then
    lang_icon="c"
elif [ -f "$dir/*.cpp" ] 2>/dev/null; then
    lang_icon="c++"
elif [ -f "$dir/*.rs" ] 2>/dev/null; then
    lang_icon="rs"
elif [ -f "$dir/*.py" ] 2>/dev/null; then
    lang_icon="py"
elif [ -f "$dir/*.js" ] 2>/dev/null; then
    lang_icon="js"
elif [ -f "$dir/*.ts" ] 2>/dev/null; then
    lang_icon="ts"
fi

# Combine icons
if [ -n "$git_icon" ] && [ -n "$lang_icon" ]; then
    echo "$git_icon|$lang_icon"
elif [ -n "$git_icon" ]; then
    echo "$git_icon"
elif [ -n "$lang_icon" ]; then
    echo "$lang_icon"
else
    echo "term"
fi
