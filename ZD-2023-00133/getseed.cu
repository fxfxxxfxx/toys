#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <cuda.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__device__ int next(uint32_t state[32], int *ptr) {
    uint32_t next_state = state[(*ptr + 1) % 32] + state[(*ptr + 29) % 32];
    state[*ptr] = next_state;
    *ptr = (*ptr + 1) % 32;
    return next_state >> 1;
}

__device__ void init(uint32_t seed, uint32_t r[32]) {
    uint32_t state[344];
    state[0] = seed;
    for (int i = 1; i <= 30; i++)
        state[i] = (16807 * (int64_t)state[i - 1]) % 2147483647;
    for (int i = 31; i <= 33; i++)
        state[i] = state[i - 31];
    for (int i = 34; i < 344; i++)
        state[i] = (state[i - 3] + state[i - 31]);
    for (int i = 0; i < 31; i++)
        r[i] = state[313 + i];
}

__global__ void collide(uint8_t *ctx, uint32_t *ans, uint32_t *fnd,
                        uint32_t cnt, size_t start, size_t n_vars) {
    uint32_t bitrep = 0;
    bitrep |= cnt << 24;
    bitrep |= blockIdx.x << 16;
    bitrep |= threadIdx.x << 8;

    uint8_t *data = ctx;
    for (int lsb = 0; lsb < 256; lsb++) {
        uint32_t seed = bitrep | lsb;
        uint32_t r[32];
        init(seed, r);
        int ptr = 31;

        for (int i = 0; i < start; i++)
            next(r, &ptr);
        int valid = 1;
        for (int i = 0; i < n_vars; i++) {
            int res = next(r, &ptr) % 16;
            valid &= (res == data[i]);
        }
        if (valid) {
            *ans = seed;
            *fnd = 1;
            break;
        }
    }
}

uint8_t *read_from_file(const char *fname, size_t *n_vars, size_t *start) {
    FILE *fp = fopen(fname, "r");
    if (!fp) {
        printf("Failed to open %s\n", fname);
        exit(0);
    }
    fscanf(fp, "%zu%zu", n_vars, start);
    uint8_t *data = (uint8_t *)malloc(*n_vars);
    for (int i = 0; i < *n_vars; i++)
        fscanf(fp, "%hhd", &data[i]);
    fclose(fp);
    return data;
}

int validate(uint32_t seed, uint8_t *data, size_t n_vars, size_t start) {
    printf("Validating %u\n", seed);
    srandom(seed);
    for (int i = 0; i < start; i++)
        random();
    for (int i = 0; i < n_vars; i++) {
        if (random() % 16 != data[i])
            return 0;
    }
    return 1;
}

int run(uint8_t *host_ctx, size_t n_vars, size_t start) {
    uint8_t *device_ctx;
    cudaMalloc((void **)&device_ctx, n_vars);
    cudaMemcpy(device_ctx, host_ctx, n_vars, cudaMemcpyHostToDevice);

    uint32_t *device_ans, *device_fnd, zero = 0;
    cudaMalloc((void **)&device_ans, sizeof(uint32_t));
    cudaMalloc((void **)&device_fnd, sizeof(uint32_t));
    cudaMemcpy(device_ans, &zero, sizeof(uint32_t), cudaMemcpyHostToDevice);
    cudaMemcpy(device_fnd, &zero, sizeof(uint32_t), cudaMemcpyHostToDevice);

    for (int cnt = 0; cnt < 256; cnt++) {
        collide<<<256, 256>>>(device_ctx, device_ans, device_fnd, cnt, start, n_vars);
        uint32_t host_ans, host_fnd = 0;
        cudaMemcpy(&host_ans, device_ans, sizeof(uint32_t), cudaMemcpyDeviceToHost);
        cudaMemcpy(&host_fnd, device_fnd, sizeof(uint32_t), cudaMemcpyDeviceToHost);
        if (host_fnd) {
            if (validate(host_ans, host_ctx, n_vars, start))
                printf("Seed is %u\n", host_ans);
            else
                printf("Validation failed.\n");
            return 1;
        }
    }
    return 0;
}

int main(int argc, char **argv) {
    if (argc == 0) exit(-1);
    if (argc == 1) {
        printf("Usage: %s input_file\n\n", argv[0]);
        printf("input_file:\n");
        printf("n start\n");
        printf("rng_0 rng_1 ... rng_n\n\n");
        printf("rng_0 is the first number after calling random() `start` times\n");
        exit(0);
    }

    int num_devices = 0;
    cudaGetDeviceCount(&num_devices);
    for (int i = 0; i < num_devices; i++) {
        struct cudaDeviceProp devInfo;
        cudaGetDeviceProperties(&devInfo, i);
        printf("Device name: %s\n", devInfo.name);
    }

    size_t n_vars, start;
    uint8_t *host_ctx = read_from_file(argv[1], &n_vars, &start);

    run(host_ctx, n_vars, start);

    free(host_ctx);

    return 0;
}
