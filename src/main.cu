#include "cuda_check.cuh"
#include "indexing.hpp"

#include <cuda_runtime.h>

#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>

namespace {

struct LaunchConfig {
    int blocks = 2;
    int threadsPerBlock = 4;
    int device = 0;
};

int parseInteger(const char* text,
                 const std::string& argumentName,
                 int minimum) {
    try {
        const std::string value{text};
        std::size_t parsedCharacters = 0;
        const long parsed = std::stol(value, &parsedCharacters);

        if (parsedCharacters != value.size() || parsed < minimum ||
            parsed > std::numeric_limits<int>::max()) {
            throw std::invalid_argument("fora do intervalo permitido");
        }

        return static_cast<int>(parsed);
    } catch (const std::exception&) {
        throw std::invalid_argument(
            "Valor inválido para " + argumentName + ": '" + text + "'.");
    }
}

void printUsage(const char* executableName) {
    std::cout
        << "Uso:\n"
        << "  " << executableName
        << " [blocos] [threads_por_bloco] [dispositivo]\n\n"
        << "Valores padrão:\n"
        << "  blocos             = 2\n"
        << "  threads_por_bloco  = 4\n"
        << "  dispositivo        = 0\n\n"
        << "Exemplo:\n"
        << "  " << executableName << " 3 8 0\n";
}

LaunchConfig parseArguments(int argc, char** argv) {
    if (argc > 1 && std::string{argv[1]} == "--help") {
        printUsage(argv[0]);
        std::exit(EXIT_SUCCESS);
    }

    if (argc > 4) {
        printUsage(argv[0]);
        throw std::invalid_argument("Quantidade excessiva de argumentos.");
    }

    LaunchConfig config;

    if (argc >= 2) {
        config.blocks = parseInteger(argv[1], "blocos", 1);
    }
    if (argc >= 3) {
        config.threadsPerBlock =
            parseInteger(argv[2], "threads_por_bloco", 1);
    }
    if (argc >= 4) {
        config.device = parseInteger(argv[3], "dispositivo", 0);
    }

    return config;
}

void printDeviceProperties(int deviceId, const cudaDeviceProp& properties) {
    constexpr double bytesPerGiB = 1024.0 * 1024.0 * 1024.0;

    std::cout << "\nGPU " << deviceId << ": " << properties.name << '\n'
              << "  Compute Capability : " << properties.major << '.'
              << properties.minor << '\n'
              << "  Memória global     : " << std::fixed
              << std::setprecision(2)
              << static_cast<double>(properties.totalGlobalMem) / bytesPerGiB
              << " GiB\n"
              << "  Multiprocessadores : " << properties.multiProcessorCount
              << '\n'
              << "  Tamanho do warp    : " << properties.warpSize << '\n'
              << "  Máx. threads/bloco : " << properties.maxThreadsPerBlock
              << '\n'
              << "  Máx. bloco (x,y,z) : (" << properties.maxThreadsDim[0]
              << ", " << properties.maxThreadsDim[1] << ", "
              << properties.maxThreadsDim[2] << ")\n"
              << "  Máx. grid (x,y,z)  : (" << properties.maxGridSize[0]
              << ", " << properties.maxGridSize[1] << ", "
              << properties.maxGridSize[2] << ")\n";
}

__global__ void helloCudaKernel() {
    const unsigned long long globalIndex =
        static_cast<unsigned long long>(hello_cuda::globalThreadIndex(
            blockIdx.x, blockDim.x, threadIdx.x));

    printf("[GPU] bloco=%u | thread_local=%u | thread_global=%llu "
           "| blockDim.x=%u | gridDim.x=%u\n",
           blockIdx.x,
           threadIdx.x,
           globalIndex,
           blockDim.x,
           gridDim.x);
}

void validateDeviceId(const LaunchConfig& config, int deviceCount) {
    if (config.device >= deviceCount) {
        throw std::out_of_range(
            "O dispositivo solicitado não existe. GPUs disponíveis: 0 a " +
            std::to_string(deviceCount - 1) + '.');
    }
}

void validateLaunchConfig(const LaunchConfig& config,
                          const cudaDeviceProp& properties) {
    if (config.threadsPerBlock > properties.maxThreadsPerBlock) {
        throw std::out_of_range(
            "threads_por_bloco excede o limite da GPU selecionada (" +
            std::to_string(properties.maxThreadsPerBlock) + ").");
    }

    if (config.blocks > properties.maxGridSize[0]) {
        throw std::out_of_range(
            "blocos excede o limite de gridDim.x da GPU selecionada (" +
            std::to_string(properties.maxGridSize[0]) + ").");
    }
}

}  // namespace

int main(int argc, char** argv) {
    try {
        const LaunchConfig config = parseArguments(argc, argv);

        int deviceCount = 0;
        CUDA_CHECK(cudaGetDeviceCount(&deviceCount));

        if (deviceCount == 0) {
            std::cerr << "Nenhuma GPU compatível com CUDA foi encontrada.\n";
            return EXIT_FAILURE;
        }

        std::cout << "=== Projeto 1: Hello CUDA ===\n"
                  << "GPUs CUDA encontradas: " << deviceCount << '\n';

        for (int deviceId = 0; deviceId < deviceCount; ++deviceId) {
            cudaDeviceProp properties{};
            CUDA_CHECK(cudaGetDeviceProperties(&properties, deviceId));
            printDeviceProperties(deviceId, properties);
        }

        validateDeviceId(config, deviceCount);

        cudaDeviceProp selectedProperties{};
        CUDA_CHECK(
            cudaGetDeviceProperties(&selectedProperties, config.device));
        validateLaunchConfig(config, selectedProperties);
        CUDA_CHECK(cudaSetDevice(config.device));

        const long long totalThreads =
            static_cast<long long>(config.blocks) * config.threadsPerBlock;

        std::cout << "\n=== Lançamento do kernel ===\n"
                  << "GPU selecionada      : " << config.device << " ("
                  << selectedProperties.name << ")\n"
                  << "Blocos no grid       : " << config.blocks << '\n'
                  << "Threads por bloco    : " << config.threadsPerBlock
                  << '\n'
                  << "Total de threads     : " << totalThreads << '\n'
                  << "Configuração CUDA    : <<<" << config.blocks << ", "
                  << config.threadsPerBlock << ">>>\n\n";

        helloCudaKernel<<<config.blocks, config.threadsPerBlock>>>();

        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaDeviceSynchronize());

        std::cout
            << "\nKernel concluído com sucesso.\n"
            << "Observação: a ordem das linhas impressas pela GPU não é "
               "garantida.\n";

        CUDA_CHECK(cudaDeviceReset());
        return EXIT_SUCCESS;
    } catch (const std::exception& error) {
        std::cerr << "Falha: " << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
