// Fixed compute benchmark for the TU117 unlock A/B: cublasSgemm, N=2048,
// deterministic input (seed 0xC0DE1234), fixed iteration counts.
// Run identical binary before (baseline) and after (post) the transaction.
#include <cublas_v2.h>
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>

#define N 2048
#define WARMUP 20
#define ITERS 100
#define REPS 5

#define CK(x) do { cudaError_t e_ = (x); if (e_ != cudaSuccess) { \
    fprintf(stderr, "CUDA error %s @%s:%d\n", cudaGetErrorString(e_), __FILE__, __LINE__); \
    exit(1); } } while (0)
#define CKC(x) do { cublasStatus_t s_ = (x); if (s_ != CUBLAS_STATUS_SUCCESS) { \
    fprintf(stderr, "cuBLAS error %d @%s:%d\n", (int)s_, __FILE__, __LINE__); \
    exit(1); } } while (0)

int main() {
    CK(cudaFree(0));  // force runtime init
    cudaSetDevice(0);
    cudaDeviceProp prop;
    CK(cudaGetDeviceProperties(&prop, 0));
    printf("device: %s (SM %d.%d), %zu MiB total\n",
           prop.name, prop.major, prop.minor,
           (size_t)prop.totalGlobalMem >> 20);

    float *a, *b, *c;
    size_t n = (size_t)N * N;
    CK(cudaMalloc(&a, n * sizeof(float)));
    CK(cudaMalloc(&b, n * sizeof(float)));
    CK(cudaMalloc(&c, n * sizeof(float)));

    // deterministic fill on host, seed 0xC0DE1234
    std::vector<float> ha(n), hb(n);
    unsigned seed = 0xC0DE1234u;
    auto lcg = [&]() { seed = seed * 1664525u + 1013904223u; return (float)(seed >> 24) / (1.0f / 16777216.0f) - 8.0f; };
    for (size_t i = 0; i < n; i++) { ha[i] = lcg(); hb[i] = lcg(); }
    CK(cudaMemcpy(a, ha.data(), n * sizeof(float), cudaMemcpyHostToDevice));
    CK(cudaMemcpy(b, hb.data(), n * sizeof(float), cudaMemcpyHostToDevice));

    cublasHandle_t h;
    CKC(cublasCreate(&h));
    const float alpha = 1.0f, beta = 0.0f;
    auto gemm = [&]() {
        // C = A * B^T (N x N); op A = N, op B = T
        CKC(cublasSgemm(h, CUBLAS_OP_N, CUBLAS_OP_T, N, N, N,
                        &alpha, a, N, b, N, &beta, c, N));
    };
    for (int i = 0; i < WARMUP; i++) gemm();
    CK(cudaDeviceSynchronize());

    double best_ms = 1e30, sum_ms = 0.0;
    for (int r = 0; r < REPS; r++) {
        cudaEvent_t t0, t1;
        CK(cudaEventCreate(&t0));
        CK(cudaEventCreate(&t1));
        CK(cudaEventRecord(t0));
        for (int i = 0; i < ITERS; i++) gemm();
        CK(cudaEventRecord(t1));
        CK(cudaEventSynchronize(t1));
        float ms;
        CK(cudaEventElapsedTime(&ms, t0, t1));
        sum_ms += ms;
        if (ms < best_ms) best_ms = ms;
        printf("rep %d: %.3f ms for %d iters\n", r, ms, ITERS);
        CK(cudaEventDestroy(t0));
        CK(cudaEventDestroy(t1));
    }
    double flops = 2.0 * (double)N * N * N * ITERS;
    double best_gflops = flops / (best_ms * 1e-3) / 1e9;
    double mean_gflops = flops * REPS / (sum_ms * 1e-3) / 1e9;
    // checksum: sample four output cells to bind the result to the math
    float check = 0.0f;
    {
        std::vector<float> hc(4);
        CK(cudaMemcpy(hc.data(), c, 4 * sizeof(float), cudaMemcpyDeviceToHost));
        for (auto v : hc) check += v;
        check = fmodf(check + (float)N, 7919.0f);
    }
    printf("RESULT best_reps=%d best_ms=%.3f best_gflops=%.2f mean_ms=%.3f mean_gflops=%.2f checksum=%.4f\n",
           REPS, best_ms, best_gflops, sum_ms / REPS, mean_gflops, check);
    return 0;
}
