#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

echo "[1/3] Compilando teste de indexação..."
make test

echo "[2/3] Verificando configuração CMake..."
if command -v nvcc >/dev/null 2>&1; then
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build --parallel
    ctest --test-dir build --output-on-failure
else
    echo "nvcc não encontrado: etapa CUDA ignorada neste ambiente."
fi

echo "[3/3] Verificando arquivos versionados..."
git diff --check

echo "Validações concluídas."
