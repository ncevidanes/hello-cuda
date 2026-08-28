#include "indexing.hpp"

#include <cstddef>
#include <iostream>

int main() {
    static_assert(hello_cuda::globalThreadIndex(0, 4, 0) == 0);
    static_assert(hello_cuda::globalThreadIndex(0, 4, 3) == 3);
    static_assert(hello_cuda::globalThreadIndex(1, 4, 0) == 4);
    static_assert(hello_cuda::globalThreadIndex(1, 4, 3) == 7);
    static_assert(hello_cuda::globalThreadIndex(2, 5, 4) == 14);

    for (std::size_t block = 0; block < 3; ++block) {
        for (std::size_t thread = 0; thread < 5; ++thread) {
            const auto expected = block * 5 + thread;
            const auto actual =
                hello_cuda::globalThreadIndex(block, 5, thread);

            if (actual != expected) {
                std::cerr
                    << "Falha no teste de indexação: bloco=" << block
                    << ", thread=" << thread
                    << ", esperado=" << expected
                    << ", obtido=" << actual << '\n';
                return 1;
            }
        }
    }

    std::cout << "Todos os testes de indexação passaram.\n";
    return 0;
}
