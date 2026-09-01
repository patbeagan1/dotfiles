.PHONY: build test clean run deps help

build:
	@echo "Building Python project..."
	@uv pip install -r requirements.txt

test:
	@echo "Running tests..."
	@uv run pytest

clean:
	@echo "Cleaning..."
	@rm -rf __pycache__/
	@rm -rf .pytest_cache/
	@rm -rf dist/
	@rm -rf build/
	@rm -rf *.egg-info/
	@find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true

run:
	@uv run restic-framework-backup --help

deps:
	@uv pip install -r requirements.txt

help:
	@echo "Available targets:"
	@echo "  build  - Install dependencies"
	@echo "  test   - Run tests"
	@echo "  clean  - Clean build artifacts"
	@echo "  run    - Show CLI help"
	@echo "  deps   - Install dependencies"
