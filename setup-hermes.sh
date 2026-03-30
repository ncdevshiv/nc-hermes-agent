#!/bin/bash
set -e

echo "Setting up Hermes Lisp Environment..."
echo "1. Checking SBCL installation..."
if ! command -v sbcl &> /dev/null; then
    echo "SBCL is not installed. Please install it (e.g., 'sudo apt install sbcl' or 'brew install sbcl')"
    return 1 2>/dev/null
fi

echo "2. Building Native Standalone Executable..."
./build.sh

echo "3. Installation Complete. Run using './bin/hermes-agent'"
