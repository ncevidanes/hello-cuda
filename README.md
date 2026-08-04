# Projeto 1 — Hello CUDA

Projeto introdutório para visualizar o modelo de execução CUDA:

- detectar as GPUs disponíveis;
- consultar propriedades da GPU;
- lançar um kernel;
- imprimir `blockIdx`, `threadIdx`, `blockDim` e o índice global;
- verificar erros de lançamento e execução.

## 1. Pré-requisitos

- GPU NVIDIA compatível com CUDA;
- driver NVIDIA funcional;
- CUDA Toolkit com `nvcc`;
- CMake 3.24 ou superior, caso use o fluxo CMake.

Verifique o ambiente:

```bash
nvidia-smi
nvcc --version
```

> `nvidia-smi` comprova que o driver enxerga a GPU. `nvcc` comprova que o
> compilador do CUDA Toolkit está instalado.

## 2. Compilação rápida com Make

```bash
make
./hello_cuda
```

Para limpar:

```bash
make clean
```

## 3. Compilação com CMake

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
./build/hello_cuda
```

## 4. Parâmetros

```text
./hello_cuda [blocos] [threads_por_bloco] [dispositivo]
```

Exemplos:

```bash
# 2 blocos, 4 threads por bloco, GPU 0
./hello_cuda

# 3 blocos, 8 threads por bloco, GPU 0
./hello_cuda 3 8 0

# Ajuda
./hello_cuda --help
```

## 5. Como interpretar o kernel

O kernel é declarado assim:

```cpp
__global__ void helloCudaKernel()
```

`__global__` significa que:

- a função é chamada pelo código executado na CPU, chamado de *host*;
- a função é executada pelas threads da GPU, chamada de *device*.

O lançamento:

```cpp
helloCudaKernel<<<blocks, threadsPerBlock>>>();
```

usa a sintaxe:

```text
kernel<<<quantidade_de_blocos, threads_por_bloco>>>()
```

Dentro do kernel:

```cpp
const unsigned int globalThreadIndex =
    blockIdx.x * blockDim.x + threadIdx.x;
```

- `threadIdx.x`: posição da thread dentro do bloco;
- `blockIdx.x`: posição do bloco dentro do grid;
- `blockDim.x`: número de threads existentes em cada bloco;
- `gridDim.x`: número de blocos existentes no grid;
- `globalThreadIndex`: identificador linear único da thread no grid 1D.

Para `<<<2, 4>>>`, temos:

```text
Grid
├── bloco 0: threads locais 0, 1, 2, 3 → globais 0, 1, 2, 3
└── bloco 1: threads locais 0, 1, 2, 3 → globais 4, 5, 6, 7
```

## 6. Saída esperada

A GPU e os valores exatos dependem da máquina. A parte das threads será
semelhante a:

```text
=== Lançamento do kernel ===
Blocos no grid       : 2
Threads por bloco    : 4
Total de threads     : 8
Configuração CUDA    : <<<2, 4>>>

[GPU] bloco=0 | thread_local=0 | thread_global=0 | blockDim.x=4 | gridDim.x=2
[GPU] bloco=0 | thread_local=1 | thread_global=1 | blockDim.x=4 | gridDim.x=2
...
[GPU] bloco=1 | thread_local=3 | thread_global=7 | blockDim.x=4 | gridDim.x=2
```

A ordem das linhas pode mudar entre execuções. Threads da GPU não devem ser
entendidas como um laço sequencial comum.

## 7. Por que sincronizar?

O lançamento de um kernel é normalmente assíncrono em relação à CPU. Por isso
o programa usa:

```cpp
CUDA_CHECK(cudaGetLastError());
CUDA_CHECK(cudaDeviceSynchronize());
```

- `cudaGetLastError()` verifica problemas imediatos no lançamento;
- `cudaDeviceSynchronize()` espera o kernel terminar e revela erros ocorridos
  durante sua execução.

## 8. Experimentos guiados

Execute e desenhe o grid correspondente:

```bash
./hello_cuda 1 1
./hello_cuda 1 8
./hello_cuda 2 4
./hello_cuda 3 5
```

Perguntas:

1. Quantas vezes o kernel é executado em cada caso?
2. Em quais blocos aparece `thread_local=0`?
3. Qual é o maior `thread_global` em `<<<3, 5>>>`?
4. Por que `threadIdx.x` volta para zero em cada novo bloco?
5. A ordem da impressão permanece igual em todas as execuções?

## 9. Critério de conclusão

O projeto está concluído quando você consegue, sem consultar a fórmula:

1. prever o número total de threads;
2. calcular o índice global de qualquer thread;
3. explicar a diferença entre grid, bloco e thread;
4. explicar por que o kernel precisa de `cudaDeviceSynchronize()` neste exemplo.
