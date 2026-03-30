#!/bin/bash
set -e

# Make bin dir if it doesn't exist
mkdir -p bin

echo "Building standalone Common Lisp executable for Hermes Agent..."
# We run SBCL, load the build script, and quit (handled by save-lisp-and-die)
sbcl --no-userinit --no-sysinit --load ~/.sbclrc --load build.lisp || {
    echo "Build failed. Do you have SBCL and Quicklisp installed?"
    exit 1
}

echo "Build complete. Executable located at bin/hermes-agent"
