# Atajos del proyecto. Ejecutar con `make <objetivo>`.
# En Windows funciona desde Git Bash si tienes `make` (winget install ezwinports.make).

.PHONY: help install dev sync lock lint fmt test run-app run-lab clean

help:
	@echo "Objetivos disponibles:"
	@echo "  install   - uv sync base"
	@echo "  dev       - uv sync con grupos dev + notebooks"
	@echo "  sync      - uv sync con TODOS los grupos"
	@echo "  lock      - regenera uv.lock"
	@echo "  lint      - ruff check"
	@echo "  fmt       - ruff format"
	@echo "  test      - pytest"
	@echo "  run-app   - streamlit run"
	@echo "  run-lab   - jupyter lab"
	@echo "  clean     - borra cachés"

install:
	uv sync

dev:
	uv sync --group dev --group notebooks

sync:
	uv sync --all-groups

lock:
	uv lock

lint:
	uv run ruff check .

fmt:
	uv run ruff format .

test:
	uv run pytest -q

run-app:
	uv run streamlit run src/p10jj/ui/app.py

run-lab:
	uv run jupyter lab

clean:
	rm -rf .pytest_cache .ruff_cache .mypy_cache htmlcov .coverage
	find . -type d -name __pycache__ -exec rm -rf {} +
