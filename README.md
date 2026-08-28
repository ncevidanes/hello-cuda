# Hello CUDA

[![CI](https://github.com/ncevidanes/hello-cuda/actions/workflows/ci.yml/badge.svg)](https://github.com/ncevidanes/hello-cuda/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Projeto introdutório para aprender como a GPU organiza **grids**, **blocos** e
**threads** no CUDA.

## Objetivos

- descobrir as GPUs CUDA disponíveis;
- consultar propriedades essenciais do dispositivo;
- lançar um kernel com configuração 1D;
- imprimir `blockIdx`, `threadIdx`, `blockDim` e `gridDim`;
- calcular o índice global de cada thread;
- tratar erros de lançamento e execução;
- validar a fórmula de indexação com um teste independente da GPU.

## Estrutura

```text
.
├── .github/                  # CI, templates e CODEOWNERS
├── include/
│   ├── cuda_check.cuh        # Tratamento uniforme de erros CUDA
│   └── indexing.hpp          # Fórmula testável do índice global
├── scripts/
│   └── check.sh              # Validação local
├── src/
│   └── main.cu               # Descoberta da GPU e kernel
├── tests/
│   └── indexing_test.cpp     # Teste C++ sem necessidade de GPU
├── CMakeLists.txt
├── Makefile
└── README.md
```

## Pré-requisitos

Para executar o kernel:

- GPU NVIDIA compatível com CUDA;
- driver NVIDIA funcional;
- CUDA Toolkit contendo `nvcc`;
- compilador C++17.

Verifique o ambiente:

```bash
nvidia-smi
nvcc --version
```

`nvidia-smi` verifica o driver e a GPU. `nvcc` verifica a instalação do CUDA
Toolkit.

## Compilação com Make

```bash
make
./hello_cuda
```

Teste da fórmula de indexação, sem exigir GPU:

```bash
make test
```

## Compilação com CMake

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
ctest --test-dir build --output-on-failure
./build/hello_cuda
```

Quando o CMake não detectar o Toolkit automaticamente, informe o caminho:

```bash
cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCUDAToolkit_ROOT=/usr/local/cuda
```

## Uso

```text
./hello_cuda [blocos] [threads_por_bloco] [dispositivo]
```

Exemplos:

```bash
./hello_cuda
./hello_cuda 3 8 0
./hello_cuda --help
```

A configuração padrão é `<<<2, 4>>>`: dois blocos com quatro threads em cada
bloco.

## Modelo de execução

```text
Grid
├── bloco 0: threads locais 0, 1, 2, 3 → globais 0, 1, 2, 3
└── bloco 1: threads locais 0, 1, 2, 3 → globais 4, 5, 6, 7
```

Em uma grade unidimensional, o índice global é:

```cpp
const auto index = blockIdx.x * blockDim.x + threadIdx.x;
```

- `threadIdx.x`: posição local dentro do bloco;
- `blockIdx.x`: posição do bloco dentro do grid;
- `blockDim.x`: quantidade de threads por bloco;
- `gridDim.x`: quantidade de blocos no grid.

## Saída esperada

A identificação do dispositivo depende da máquina. A parte do kernel será
semelhante a:

```text
=== Lançamento do kernel ===
Blocos no grid       : 2
Threads por bloco    : 4
Total de threads     : 8
Configuração CUDA    : <<<2, 4>>>

[GPU] bloco=0 | thread_local=0 | thread_global=0 | blockDim.x=4 | gridDim.x=2
[GPU] bloco=1 | thread_local=3 | thread_global=7 | blockDim.x=4 | gridDim.x=2
```

A ordem das linhas não é garantida, pois as threads não devem ser entendidas
como iterações sequenciais de um laço comum.

## Tratamento de erros

O programa verifica:

- chamadas da Runtime API;
- parâmetros do dispositivo selecionado;
- limite de threads por bloco;
- limite de blocos no eixo `x`;
- erros imediatos de lançamento;
- erros assíncronos revelados por `cudaDeviceSynchronize()`.

## Integração contínua

A CI executa dois trabalhos:

1. teste C++ da fórmula de indexação em runner comum;
2. compilação com `nvcc` dentro de um container oficial CUDA.

O kernel não é executado na CI porque os runners hospedados não oferecem GPU
NVIDIA. A execução deve ser validada localmente ou em um runner próprio com
GPU.

## Experimentos guiados

```bash
./hello_cuda 1 1
./hello_cuda 1 8
./hello_cuda 2 4
./hello_cuda 3 5
```

Antes de executar, determine:

1. quantas threads serão criadas;
2. qual será o maior índice global;
3. quantas vezes `threadIdx.x == 0` aparecerá;
4. em qual bloco cada índice global estará.

## Critério de conclusão

O projeto está concluído quando você consegue:

- diferenciar grid, bloco e thread;
- prever o total de threads de um lançamento;
- calcular qualquer índice global sem consultar a fórmula;
- explicar por que `threadIdx.x` recomeça em zero em cada bloco;
- explicar por que a CPU precisa sincronizar neste exemplo.

## Licença

Distribuído sob a licença [MIT](LICENSE).
