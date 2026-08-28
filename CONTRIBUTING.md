# Contribuindo

Este repositório usa desenvolvimento orientado por pull requests.

## Fluxo recomendado

1. Atualize a branch `main`.
2. Crie uma branch curta e descritiva, preferencialmente `feature/...`,
   `fix/...` ou `docs/...`.
3. Mantenha cada commit focado em uma alteração coerente.
4. Execute as validações locais.
5. Abra uma pull request inicialmente como draft.
6. Revise o diff e os resultados da CI antes de marcá-la como pronta.

## Validação local

```bash
make test
./scripts/check.sh
```

A compilação e a execução do programa CUDA exigem `nvcc`. O teste da fórmula de
indexação global funciona apenas com um compilador C++17.

## Commits

Use mensagens objetivas no imperativo ou descrevendo a entrega, por exemplo:

```text
Adiciona descoberta de dispositivos CUDA
Corrige validação de threads por bloco
Documenta modelo de execução 1D
```
