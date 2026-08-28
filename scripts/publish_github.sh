#!/usr/bin/env bash
set -euo pipefail

repository="ncevidanes/hello-cuda"
base_branch="main"
feature_branch="agent/hello-cuda-foundation"

fail() {
    echo "Erro: $*" >&2
    exit 1
}

command -v git >/dev/null 2>&1 || fail "git não está instalado."
command -v gh >/dev/null 2>&1 || fail "gh não está instalado."
gh auth status >/dev/null 2>&1 || fail "execute 'gh auth login' antes de continuar."

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || \
    fail "execute este script dentro do repositório hello-cuda."

[[ -z "$(git status --porcelain)" ]] || \
    fail "há alterações locais não commitadas."

git show-ref --verify --quiet "refs/heads/$base_branch" || \
    fail "branch $base_branch não encontrada."
git show-ref --verify --quiet "refs/heads/$feature_branch" || \
    fail "branch $feature_branch não encontrada."

if gh repo view "$repository" >/dev/null 2>&1; then
    fail "o repositório $repository já existe; revise antes de publicar."
fi

git switch "$base_branch"
gh repo create "$repository" \
    --public \
    --description "Projeto introdutório para aprender grids, blocos e threads em CUDA" \
    --source . \
    --remote origin \
    --push

git switch "$feature_branch"
git push -u origin "$feature_branch"

pr_body="$(mktemp)"
trap 'rm -f "$pr_body"' EXIT
cat > "$pr_body" <<'BODY'
## Objetivo

Introduzir o Projeto 1 — Hello CUDA por meio do fluxo de pull request.

## Alterações

- descoberta e inspeção das GPUs CUDA disponíveis;
- kernel introdutório com índices local e global;
- validação dos parâmetros de lançamento;
- tratamento uniforme de erros da Runtime API;
- build com Make e CMake;
- teste unitário da fórmula de indexação sem dependência de GPU;
- CI com teste host e compilação em container CUDA;
- documentação didática, templates e orientações de contribuição.

## Validação

```bash
make test
./scripts/check.sh
```

A execução real do kernel deve ser validada em uma máquina com GPU NVIDIA e
CUDA Toolkit. A CI compila o código CUDA, mas não executa o kernel por ausência
de GPU nos runners hospedados.

## Checklist

- [x] Escopo focado no primeiro projeto de aprendizagem CUDA.
- [x] Código e documentação organizados por responsabilidade.
- [x] Teste independente da GPU incluído.
- [x] Compilação CUDA automatizada na CI.
- [x] Pull request criada inicialmente como draft.
BODY

gh pr create \
    --repo "$repository" \
    --base "$base_branch" \
    --head "$feature_branch" \
    --draft \
    --title "Implementa Projeto 1 — Hello CUDA" \
    --body-file "$pr_body"
