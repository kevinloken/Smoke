#!/bin/sh

# Build the target.
xcodebuild -target "Smoke" -configuration Debug clean
xcodebuild -target "Smoke" -configuration Debug build
