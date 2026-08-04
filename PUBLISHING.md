# Publicação no GitHub por draft PR

O repositório local foi preparado com:

- `main`: commit inicial mínimo;
- `agent/hello-cuda-foundation`: implementação completa;
- CI, testes, documentação e templates de colaboração.

## Publicação automática

Instale e autentique o GitHub CLI:

```bash
gh --version
gh auth status
```

Depois execute:

```bash
./scripts/publish_github.sh
```

O script cria `ncevidanes/hello-cuda` como repositório público, publica as duas
branches e abre uma draft PR da branch de implementação para `main`.
