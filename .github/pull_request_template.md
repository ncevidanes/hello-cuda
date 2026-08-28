## Objetivo

Descreva claramente o propósito desta alteração.

## Alterações

- [ ] Código
- [ ] Testes
- [ ] Documentação
- [ ] CI/build

## Validação

Informe os comandos executados e os resultados observados.

```bash
make test
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
ctest --test-dir build --output-on-failure
```

## Checklist

- [ ] O escopo está limitado a uma finalidade clara.
- [ ] Não há arquivos gerados ou credenciais versionados.
- [ ] A documentação acompanha o comportamento implementado.
- [ ] Os testes relevantes foram executados.
- [ ] A PR está pronta para revisão ou marcada como draft.
