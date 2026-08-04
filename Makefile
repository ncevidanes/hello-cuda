NVCC ?= nvcc
TARGET := hello_cuda
SOURCE := src/main.cu
INCLUDES := -Iinclude
NVCCFLAGS := -std=c++17 -O2 -lineinfo $(INCLUDES)

.PHONY: all run clean info

all: $(TARGET)

$(TARGET): $(SOURCE) include/cuda_check.cuh
	$(NVCC) $(NVCCFLAGS) $(SOURCE) -o $(TARGET)

run: $(TARGET)
	./$(TARGET)

info:
	$(NVCC) --version
	nvidia-smi

clean:
	rm -f $(TARGET)
