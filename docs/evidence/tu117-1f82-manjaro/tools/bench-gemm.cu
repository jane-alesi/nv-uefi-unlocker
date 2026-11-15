// Fixed cuBLAS FP32 GEMM bench for the tu117-1f82 evidence series.
// Reconstructed 2026-11-15 (the Nov 3 original lived on /tmp and was lost
// with the tmpfs wipe); shape/seed match the Nov 3 record: N=2048,
// seed 0xC0DE1234, 5 reps x 100 iters. Checksum = mean + max of C.
// Build: nvcc -O3 bench-gemm.cu -lcublas -o bench-gemm
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <cublas_v2.h>
#include <cuda_runtime.h>

#define CK(x) do { cudaError_t e=(x); if(e){printf("cuda err %s @%d\n",cudaGetErrorString(e),__LINE__);exit(1);} } while(0)

int main() {
    const int N = 2048;
    const size_t bytes = (size_t)N * N * sizeof(float);
    float *A, *B, *C, *h;
    CK(cudaMalloc(&A, bytes)); CK(cudaMalloc(&B, bytes)); CK(cudaMalloc(&C, bytes));
    h = (float*)malloc(bytes);
    srand(0xC0DE1234u);
    for (size_t i = 0; i < (size_t)N * N; i++) h[i] = (float)rand() / RAND_MAX - 0.5f;
    CK(cudaMemcpy(A, h, bytes, cudaMemcpyHostToDevice));
    CK(cudaMemcpy(B, h, bytes, cudaMemcpyHostToDevice));
    cublasHandle_t cb; cublasCreate(&cb);
    float al = 1.0f, be = 0.0f;
    cudaEvent_t e0, e1; cudaEventCreate(&e0); cudaEventCreate(&e1);
    double best = 0, total = 0;
    for (int rep = 0; rep < 5; rep++) {
        cudaEventRecord(e0);
        for (int i = 0; i < 100; i++)
            cublasSgemm(cb, CUBLAS_OP_N, CUBLAS_OP_N, N, N, N, &al, A, N, B, N, &be, C, N);
        cudaEventRecord(e1); cudaEventSynchronize(e1);
        float ms; cudaEventElapsedTime(&ms, e0, e1);
        double gf = (2.0 * N * N * N * 100.0) / (ms / 1000.0) / 1e9;
        printf("rep %d: %.2f ms  %.2f GFLOPS\n", rep, ms, gf);
        if (gf > best) best = gf; total += gf;
    }
    CK(cudaMemcpy(h, C, bytes, cudaMemcpyDeviceToHost));
    double sum = 0; float mx = 0;
    for (size_t i = 0; i < (size_t)N * N; i++) { sum += h[i]; if (fabsf(h[i]) > mx) mx = fabsf(h[i]); }
    printf("BEST %.2f GFLOPS  MEAN %.2f GFLOPS  checksum mean=%.4f max=%.4f\n",
           best, total / 5, sum / ((double)N * N), mx);
    return 0;
}
