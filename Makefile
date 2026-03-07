# ─────────────────────────────────────────────────────────────────────────────
# Inventar Flutter Makefile
# Comprehensive build, test, lint, and run commands for Flutter/Dart development
# ─────────────────────────────────────────────────────────────────────────────

.PHONY: help deps clean format lint analyze test coverage build build-all \
        build-linux build-apk build-appbundle run run-linux run-android \
        doctor check ci-lint ci-test ci-build

# Default target
.DEFAULT_GOAL := help

FLUTTER_CHANNEL ?= stable
BUILD_DIR := build
COVERAGE_DIR := coverage

# ─────────────────────────────────────────────────────────────────────────────
# Info & Help
# ─────────────────────────────────────────────────────────────────────────────

help:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║            Inventar Flutter/Dart Build System                 ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Core Commands:"
	@echo "  make deps              Install/update Flutter & Dart dependencies"
	@echo "  make clean             Remove build artifacts and cache"
	@echo ""
	@echo "Code Quality:"
	@echo "  make format            Format Dart code (dart format)"
	@echo "  make lint              Run linter with fatal warnings (flutter analyze)"
	@echo "  make analyze           Full static analysis"
	@echo "  make check             Format + lint + analyze (pre-commit check)"
	@echo ""
	@echo "Testing:"
	@echo "  make test              Run unit tests"
	@echo "  make coverage          Run tests with coverage report"
	@echo ""
	@echo "Building:"
	@echo "  make build-linux       Build Linux desktop release"
	@echo "  make build-apk         Build Android APK release"
	@echo "  make build-appbundle   Build Android App Bundle release"
	@echo "  make build-all         Build all release targets"
	@echo ""
	@echo "Running:"
	@echo "  make run-linux         Run on Linux desktop"
	@echo "  make run-android       Run on Android device/emulator"
	@echo "  make run               Build and run (default: Linux)"
	@echo ""
	@echo "Utilities:"
	@echo "  make doctor            Run Flutter doctor for environment checks"
	@echo "  make ci-lint           CI lint job (format check + analyze)"
	@echo "  make ci-test           CI test job (unit tests + coverage)"
	@echo "  make ci-build          CI build jobs (linux + apk)"
	@echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Dependencies
# ─────────────────────────────────────────────────────────────────────────────

deps:
	@echo "📦 Installing Flutter/Dart dependencies..."
	@flutter pub get
	@echo "✓ Dependencies installed"

doctor:
	@echo "🔍 Running Flutter doctor..."
	@flutter doctor

# ─────────────────────────────────────────────────────────────────────────────
# Code Quality & Formatting
# ─────────────────────────────────────────────────────────────────────────────

format:
	@echo "🎨 Formatting Dart code..."
	@dart format .
	@echo "✓ Code formatted"

format-check:
	@echo "🔍 Checking Dart code format..."
	@dart format --set-exit-if-changed .
	@echo "✓ Format check passed"

lint: analyze

analyze:
	@echo "🔍 Running Flutter analyzer..."
	@flutter analyze --fatal-warnings
	@echo "✓ Analysis passed (no fatal warnings)"

check: format-check analyze
	@echo "✓ All checks passed (format + analyze)"

# ─────────────────────────────────────────────────────────────────────────────
# Testing
# ─────────────────────────────────────────────────────────────────────────────

test:
	@echo "🧪 Running unit tests..."
	@flutter test
	@echo "✓ All tests passed"

coverage:
	@echo "🧪 Running tests with coverage..."
	@flutter test --coverage
	@echo "✓ Coverage report generated: $(COVERAGE_DIR)/lcov.info"

# ─────────────────────────────────────────────────────────────────────────────
# Building
# ─────────────────────────────────────────────────────────────────────────────

build-linux:
	@echo "🔨 Building Linux desktop release..."
	@flutter build linux --release
	@echo "✓ Linux build complete: $(BUILD_DIR)/linux/x64/release/bundle"

build-apk:
	@echo "🔨 Building Android APK release..."
	@flutter build apk --release
	@echo "✓ APK build complete: $(BUILD_DIR)/app/outputs/flutter-apk/app-release.apk"

build-appbundle:
	@echo "🔨 Building Android App Bundle release..."
	@flutter build appbundle --release
	@echo "✓ App Bundle build complete: $(BUILD_DIR)/app/outputs/bundle/release/app-release.aab"

build-all: build-linux build-apk build-appbundle
	@echo "✓ All release builds complete"

build: build-linux
	@echo "✓ Default build (Linux) complete"

# ─────────────────────────────────────────────────────────────────────────────
# Running
# ─────────────────────────────────────────────────────────────────────────────

run-linux:
	@echo "▶ Running on Linux desktop..."
	@flutter run -d linux

run-android:
	@echo "▶ Running on Android device/emulator..."
	@flutter run -d android

run: run-linux

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────────────────────────────────────────

clean:
	@echo "🗑 Cleaning build artifacts..."
	@flutter clean
	@rm -rf $(BUILD_DIR) $(COVERAGE_DIR)
	@echo "✓ Clean complete"

# ─────────────────────────────────────────────────────────────────────────────
# CI Workflow Targets (mirror GitHub Actions jobs)
# ─────────────────────────────────────────────────────────────────────────────

ci-lint: deps format-check analyze
	@echo "✓ CI lint job complete (format + analyze)"

ci-test: deps test coverage
	@echo "✓ CI test job complete (unit tests + coverage)"

ci-build: deps build-linux build-apk
	@echo "✓ CI build jobs complete (linux + apk)"

ci: deps check test build-all
	@echo "✓ Full CI pipeline complete"

# ─────────────────────────────────────────────────────────────────────────────
# Quick Recipes
# ─────────────────────────────────────────────────────────────────────────────

.PHONY: quick-build quick-test quick-check pre-commit

quick-build: deps build
quick-test: deps test
quick-check: deps check

pre-commit: format-check analyze test
	@echo "✓ Pre-commit checks passed"
