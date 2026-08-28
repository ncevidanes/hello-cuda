#pragma once

#include <cstddef>

#if defined(__CUDACC__)
#define HELLO_CUDA_HOST_DEVICE __host__ __device__
#else
#define HELLO_CUDA_HOST_DEVICE
#endif

namespace hello_cuda {

[[nodiscard]] HELLO_CUDA_HOST_DEVICE constexpr std::size_t globalThreadIndex(
    std::size_t blockIndex,
    std::size_t blockDimension,
    std::size_t localThreadIndex) noexcept {
    return blockIndex * blockDimension + localThreadIndex;
}

}  // namespace hello_cuda

#undef HELLO_CUDA_HOST_DEVICE
