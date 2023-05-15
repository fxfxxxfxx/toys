CC = clang
NVCC = nvcc
CFLAGS = -O2 -Wall -Wextra -Werror

.PHONY: all clean

all: getseed genrng

getseed: getseed.cu
	$(NVCC) -ccbin $(CC) $^ -o $@

genrng: genrng.c
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm getseed genrng
