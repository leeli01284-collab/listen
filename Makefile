.PHONY: help build build-engine build-data build-adapter build-frontend test test-rust lint lint-rust lint-ts clean docker-up docker-down

help:
	@echo "Listen Repository - Development Commands"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build              - Build all projects"
	@echo "  make build-engine       - Build listen-engine"
	@echo "  make build-data         - Build listen-data"
	@echo "  make build-adapter      - Build listen-adapter"
	@echo "  make build-frontend     - Build all frontend projects"
	@echo ""
	@echo "Test Commands:"
	@echo "  make test               - Run all tests"
	@echo "  make test-rust          - Run Rust tests"
	@echo ""
	@echo "Lint Commands:"
	@echo "  make lint               - Run all linters"
	@echo "  make lint-rust          - Run Rust linters"
	@echo "  make lint-ts            - Run TypeScript linters"
	@echo ""
	@echo "Docker Commands:"
	@echo "  make docker-up          - Start all services"
	@echo "  make docker-down        - Stop all services"
	@echo ""
	@echo "Utility Commands:"
	@echo "  make clean              - Clean build artifacts"

# Build Commands
build: build-engine build-data build-adapter build-frontend

build-engine:
	@echo "Building listen-engine..."
	cd listen-engine && cargo build --release

build-data:
	@echo "Building listen-data..."
	cd listen-data && cargo build --release

build-adapter:
	@echo "Building listen-adapter..."
	cd listen-adapter && cargo build --release

build-frontend:
	@echo "Building listen-interface..."
	cd listen-interface && npm run build
	@echo "Building listen-landing..."
	cd listen-landing && npm run build
	@echo "Building listen-miniapp..."
	cd listen-miniapp && npm run build

# Test Commands
test: test-rust

test-rust:
	@echo "Running Rust tests..."
	cd listen-engine && cargo test
	cd listen-data && cargo test
	cd listen-adapter && cargo test

# Lint Commands
lint: lint-rust lint-ts

lint-rust:
	@echo "Running Rust linters..."
	cd listen-engine && cargo clippy -- -D warnings
	cd listen-engine && cargo fmt --check
	cd listen-data && cargo clippy -- -D warnings
	cd listen-data && cargo fmt --check
	cd listen-adapter && cargo clippy -- -D warnings
	cd listen-adapter && cargo fmt --check

lint-ts:
	@echo "Running TypeScript linters..."
	cd listen-interface && npm run lint
	cd listen-landing && npm run lint
	cd listen-miniapp && npm run lint

# Docker Commands
docker-up:
	@echo "Starting Docker services..."
	docker compose up -d

docker-down:
	@echo "Stopping Docker services..."
	docker compose down

# Utility Commands
clean:
	@echo "Cleaning build artifacts..."
	cd listen-engine && cargo clean
	cd listen-data && cargo clean
	cd listen-adapter && cargo clean
	cd listen-interface && rm -rf dist node_modules
	cd listen-landing && rm -rf dist node_modules
	cd listen-miniapp && rm -rf dist node_modules
	@echo "Clean complete!"
