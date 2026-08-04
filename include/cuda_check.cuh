#pragma once

#include <cuda_runtime.h>

#include <sstream>
#include <stdexcept>

inline void checkCuda(cudaError_t status,
                      const char* expression,
                      const char* file,
                      int line) {
    if (status == cudaSuccess) {
        return;
    }

    std::ostringstream message;
    message << "Erro CUDA em " << file << ':' << line
            << " ao executar " << expression << ": "
            << cudaGetErrorString(status);
    throw std::runtime_error(message.str());
}

#define CUDA_CHECK(expression) \
    checkCuda((expression), #expression, __FILE__, __LINE__)
