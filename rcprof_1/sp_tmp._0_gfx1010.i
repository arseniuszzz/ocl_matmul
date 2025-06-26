# 1 "C:\\Users\\OCL_US~1\\AppData\\Local\\Temp\\comgr-96f2d4\\input\\CompileCLSource"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 372 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "C:\\Users\\OCL_US~1\\AppData\\Local\\Temp\\comgr-96f2d4\\input\\CompileCLSource" 2
__kernel void matmul(const __global float* A,
                     const __global float* B,
                     __global float* C,
                     const int M,
                     const int N,
                     const int K)
{
    uint col = get_global_id(0);
    uint row = get_global_id(1);

    float sum = 0.0f;

    for (int i = 0; i < K; i++) {
        sum += A[row * K + i] * B[i * N + col];
    }
    C[row * N + col] = sum;
}




__kernel
void matmul_local(const global float* A,
                  const __global float* B,
                  __global float* C,
                  const int M,
                  const int N,
                  const int K)
{

    int row = get_global_id(1);
    int col = get_global_id(0);

    __local float tileA[16][16];
    __local float tileB[16][16];

    int local_row = get_local_id(1);
    int local_col = get_local_id(0);

    float sum = 0.0f;

    for (int t = 0; t < (K + 16 - 1) / 16; ++t)
    {
        tileA[local_row][local_col] = A[(row * K + t * 16 + local_col)];
        tileB[local_row][local_col] = B[((t * 16 + local_row) * N + col)];

        barrier(CLK_LOCAL_MEM_FENCE);

        for (int k = 0; k < 16; ++k)
        {
            sum += tileA[local_row][k] * tileB[k][local_col];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    C[row * N + col] = sum;
}







__kernel void matmul_vector(const __global float* A,
                            const __global float* B,
                            __global float* C,
                            const uint M,
                            const uint N,
                            const uint K)
{

    uint row = get_global_id(1);
    uint col = get_global_id(0) * 4;

    __local union {
        float4 vec[32][32 / 4];
        float matrix[32][32];
    } tileA;

    __local float4 tileB[32][32 / 4];

    uint local_row = get_local_id(1);
    uint local_col = get_local_id(0);

    float4 sum = 0.0f;

    for (int t = 0; t < (K + 32 - 1) / 32; ++t)
    {
        float4 vA = vload4(0, &A[row * K + t * 32 + local_col * 4]);
        tileA.vec[local_row][local_col] = vA;

        float4 vB = vload4(0, &B[(t * 32 + local_row) * N + col]);
        tileB[local_row][local_col] = vB;

        barrier(CLK_LOCAL_MEM_FENCE);

        for (uint k = 0; k < 32; ++k)
        {
            float a = tileA.matrix[local_row][k];
            sum += a * tileB[k][local_col];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    vstore4(sum, 0, &C[row * N + col]);
}
