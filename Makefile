NVCC ?= nvcc
CXX ?= g++
TARGET := hello_cuda
TEST_TARGET := indexing_test
SOURCE := src/main.cu
TEST_SOURCE := tests/indexing_test.cpp
INCLUDES := -Iinclude
NVCCFLAGS := -std=c++17 -O2 -lineinfo $(INCLUDES)
CXXFLAGS := -std=c++17 -O2 -Wall -Wextra -Wpedantic -Werror $(INCLUDES)

.PHONY: all run test clean info

all: $(TARGET)

$(TARGET): $(SOURCE) include/cuda_check.cuh include/indexing.hpp
	$(NVCC) $(NVCCFLAGS) $(SOURCE) -o $(TARGET)

$(TEST_TARGET): $(TEST_SOURCE) include/indexing.hpp
	$(CXX) $(CXXFLAGS) $(TEST_SOURCE) -o $(TEST_TARGET)

run: $(TARGET)
	./$(TARGET)

test: $(TEST_TARGET)
	./$(TEST_TARGET)

info:
	$(NVCC) --version
	nvidia-smi

clean:
	rm -f $(TARGET) $(TEST_TARGET)
	rm -rf build
