__kernel void matmul(const __global float* A, 
                     const __global float* B, 
                     __global float* C, 
                     const int M, 
                     const int N, 
                     const int K) 
{
    uint col = get_global_id(0); // номер столбца от 0 до M в матрице C
    uint row = get_global_id(1); // номер строчки от 0 до N в матрице C
    
    float sum = 0.0f;

    for (int i = 0; i < K; i++) {
        sum += A[row * K + i] * B[i * N + col];
    }
    C[row * N + col] = sum;
}

__kernel void matmul_local(const global float* A, 
                  const __global float* B, 
                  __global float* C, 
                  const int M, 
                  const int N, 
                  const int K) 
{
#define TILE_SIZE 16
    int row = get_global_id(1);
    int col = get_global_id(0);

    __local float tileA[TILE_SIZE][TILE_SIZE];
    __local float tileB[TILE_SIZE][TILE_SIZE];

    int local_row = get_local_id(1);
    int local_col = get_local_id(0);

    float sum = 0.0f;

    for (int t = 0; t < (K + TILE_SIZE - 1) / TILE_SIZE; ++t) 
    {
        tileA[local_row][local_col] = A[(row * K + t * TILE_SIZE + local_col)];
        tileB[local_row][local_col] = B[((t * TILE_SIZE + local_row) * N + col)];

        barrier(CLK_LOCAL_MEM_FENCE);

        for (int k = 0; k < TILE_SIZE; ++k)
        {
            sum += tileA[local_row][k] * tileB[k][local_col];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    C[row * N + col] = sum;
}


// test
#define VECTOR_SIZE 4
#define vloadn vload4
#define vstoren vstore4
#define floatn float4

__kernel void matmul_vector(const __global float* A,
                                       const __global float* B,
                                       __global float* C,
                                       const uint M,
                                       const uint N,
                                       const uint K)
{
    #define TILE_SIZE 32
    uint row = get_global_id(1);
    uint col = get_global_id(0) * VECTOR_SIZE;

    __local union {
        floatn vec[TILE_SIZE][TILE_SIZE / VECTOR_SIZE]; 
        float matrix[TILE_SIZE][TILE_SIZE]; 
    } tileA;

    __local union {
        floatn vec[TILE_SIZE][TILE_SIZE / VECTOR_SIZE]; 
        float matrix[TILE_SIZE][TILE_SIZE]; 
    } tileB;

    uint local_row = get_local_id(1);
    uint local_col = get_local_id(0);

    floatn sum = (floatn)(0.0f);

    for (int t = 0; t < (K + TILE_SIZE - 1) / TILE_SIZE; ++t)
    {
        // Загрузка тайла A
        tileA.vec[local_row][local_col] = vloadn(0, &A[row * K + (t * TILE_SIZE + local_col * VECTOR_SIZE)]);

        // Загрузка транспонированного тайла B
        tileB.vec[local_row][local_col] = vloadn(0, &B[(t * TILE_SIZE + local_row) * N + col]);

        barrier(CLK_LOCAL_MEM_FENCE);

        // Вычисление произведения тайлов
        for (uint k = 0; k < TILE_SIZE; ++k)
        {
            float a = tileA.matrix[local_row][k];
            floatn b = tileB.vec[k][local_col];
            sum += a * b;
        }

        barrier(CLK_LOCAL_MEM_FENCE);
    }

    // Запись результата в C
    vstoren(sum, 0, &C[row * N + col]);
}



// 32 ms
/*
#define VECTOR_SIZE 4
#define vloadn vload4
#define vstoren vstore4
#define floatn float4

__kernel void matmul_vector(const __global float* A,
                            const __global float* B,
                            __global float* C,
                            const uint M,
                            const uint N,
                            const uint K)
{
    #define TILE_SIZE 32
    uint row = get_global_id(1);
    uint col = get_global_id(0) * VECTOR_SIZE;

    __local union {
        floatn vec[TILE_SIZE][TILE_SIZE / VECTOR_SIZE]; 
        float matrix[TILE_SIZE][TILE_SIZE]; 
    } tileA;

    __local floatn tileB[TILE_SIZE][TILE_SIZE / VECTOR_SIZE];

    uint local_row = get_local_id(1);
    uint local_col = get_local_id(0);

    floatn sum = 0.0f;

    for (int t = 0; t < (K + TILE_SIZE - 1) / TILE_SIZE; ++t)
    {
        floatn vA = vloadn(0, &A[row * K + t * TILE_SIZE + local_col * VECTOR_SIZE]);
        tileA.vec[local_row][local_col] = vA;

        floatn vB = vloadn(0, &B[(t * TILE_SIZE + local_row) * N + col]);
        tileB[local_row][local_col] = vB;

        barrier(CLK_LOCAL_MEM_FENCE);

        for (uint k = 0; k < TILE_SIZE; ++k)
        {
            floatn a = tileA.matrix[local_row][k];
            floatn b = tileB[k][local_col];
            sum += a * b; // Умножение вектора на вектор
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    vstoren(sum, 0, &C[row * N + col]);
}
*/

/*

#define VECTOR_SIZE 4
#define vloadn vload4
#define vstoren vstore4
#define floatn float4

__kernel void matmul_vector(const __global float* A, 
                            const __global float* B, 
                            __global float* C, 
                            const uint M, 
                            const uint N, 
                            const uint K) 
{
    #define TILE_SIZE 32
    uint row = get_global_id(1);
    uint col = get_global_id(0) * VECTOR_SIZE;

    __local float tileA[TILE_SIZE][TILE_SIZE];
    __local floatn tileB[TILE_SIZE][TILE_SIZE / VECTOR_SIZE];

    uint local_row = get_local_id(1);
    uint local_col = get_local_id(0);

    floatn sum = 0.0f;

    for (int t = 0; t < (K + TILE_SIZE - 1) / TILE_SIZE; ++t) 
    {
        floatn vA = vloadn(0, &A[row * K + t * TILE_SIZE + local_col * VECTOR_SIZE]);
        vstoren(vA, 0, &tileA[local_row][local_col * VECTOR_SIZE]);

        floatn vB = vloadn(0, &B[(t * TILE_SIZE + local_row) * N + col]);
        tileB[local_row][local_col] = vB;
        barrier(CLK_LOCAL_MEM_FENCE);

        for (uint k = 0; k < TILE_SIZE; ++k)
        {
            sum += tileA[local_row][k] * tileB[k][local_col];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    vstoren(sum, 0, &C[row * N + col]);
}
*/

/*
#define VECTOR_SIZE 4
#define vloadn vload4
#define vstoren vstore4
#define floatn float4

__kernel void matmul_vector(const __global float* A, 
                            const __global float* B, 
                            __global float* C, 
                            const uint M, 
                            const uint N, 
                            const uint K) 
{
    #define TILE_SIZE 32
    uint row = get_global_id(1);
    uint col = get_global_id(0) * VECTOR_SIZE;

    __local float tileA[TILE_SIZE][TILE_SIZE];
    __local floatn tileB[TILE_SIZE][TILE_SIZE / VECTOR_SIZE];

    uint local_row = get_local_id(1);
    uint local_col = get_local_id(0);

    floatn sum = 0.0f;

    for (int t = 0; t < (K + TILE_SIZE - 1) / TILE_SIZE; ++t) 
    {
        floatn vA = vloadn(0, &A[row * K + t * TILE_SIZE + local_col * VECTOR_SIZE]);
        vstoren(vA, 0, &tileA[local_row][local_col * VECTOR_SIZE]);

        floatn vB = vloadn(0, &B[(t * TILE_SIZE + local_row) * N + col]);
        tileB[local_row][local_col] = vB;
        barrier(CLK_LOCAL_MEM_FENCE);

        for (uint k = 0; k < TILE_SIZE; ++k)
        {
            sum += tileA[local_row][k] * tileB[k][local_col];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    vstoren(sum, 0, &C[row * N + col]);
}
*/

/*
#define VECTOR_SIZE 4
#define vloadn vload4
#define vstoren vstore4
#define floatn float4

__kernel void matmul_vector(const __global float* A, 
                            const __global float* B, 
                            __global float* C, 
                            const uint M, 
                            const uint N, 
                            const uint K) 
{
    #define TILE_SIZE 32
    uint row = get_global_id(1);
    uint col = get_global_id(0) * VECTOR_SIZE;

    __local float tileA[TILE_SIZE][TILE_SIZE];
    __local floatn tileB[TILE_SIZE][TILE_SIZE / VECTOR_SIZE];

    uint local_row = get_local_id(1);
    uint local_col = get_local_id(0);

    floatn sum = 0.0f;

    for (int t = 0; t < (K + TILE_SIZE - 1) / TILE_SIZE; ++t) 
    {
        floatn vA = vloadn(0, &A[row * K + t * TILE_SIZE + local_col * VECTOR_SIZE]);
        vstoren(vA, 0, &tileA[local_row][local_col * VECTOR_SIZE]);

        floatn vB = vloadn(0, &B[(t * TILE_SIZE + local_row) * N + col]);
        tileB[local_row][local_col] = vB;
        barrier(CLK_LOCAL_MEM_FENCE);

        for (int k = 0; k < TILE_SIZE; ++k)
        {
            sum += tileA[local_row][k] * tileB[k][local_col];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    vstoren(sum, 0, &C[row * N + col]);
}
*/
/*
#define VECTOR_SIZE 4
#define vloadn vload4
#define vstoren vstore4
#define floatn float4

__kernel void matmul_vector(const __global float* A, 
                            const __global float* B, 
                            __global float* C, 
                            const uint M, 
                            const uint N, 
                            const uint K) 
{
    #define TILE_SIZE 32
    uint row = get_global_id(1);
    uint col = get_global_id(0) * VECTOR_SIZE;

    __local float tileA[TILE_SIZE][TILE_SIZE];
    __local floatn tileB[TILE_SIZE][TILE_SIZE / VECTOR_SIZE];

    uint local_row = get_local_id(1);
    uint local_col = get_local_id(0);

    floatn sum = 0.0f;

    for (int t = 0; t < (K + TILE_SIZE - 1) / TILE_SIZE; ++t) 
    {
        floatn vA = vloadn(0, &A[row * K + t * TILE_SIZE + local_col * VECTOR_SIZE]);
        vstoren(vA, 0, &tileA[local_row][local_col * VECTOR_SIZE]);

        floatn vB = vloadn(0, &B[(t * TILE_SIZE + local_row) * N + col]);
        tileB[local_row][local_col] = vB;
        barrier(CLK_LOCAL_MEM_FENCE);

        for (int k = 0; k < TILE_SIZE; ++k)
        {
            sum += tileA[local_row][k] * tileB[k][local_col];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    vstoren(sum, 0, &C[row * N + col]);
}
*/

/*
#define VECTOR_SIZE 4
__kernel void matmul_vector(const __global float* A, 
                                  const __global float* B, 
                                  __global float* C, 
                                  const uint M, 
                                  const uint N, 
                                  const uint K) 
{   
#define TILE_SIZE 32
    uint row = get_global_id(1);
    uint col = get_global_id(0) * VECTOR_SIZE;

    __local float tileA[TILE_SIZE][TILE_SIZE];
    __local float4 tileB[TILE_SIZE][TILE_SIZE / VECTOR_SIZE];

    uint local_row = get_local_id(1);
    uint local_col = get_local_id(0);

    float4 sum = 0.0f;

    for (int t = 0; t < (K + TILE_SIZE - 1) / TILE_SIZE; ++t) 
    {
        float4 vA = vload4(0, &A[row * K + t * TILE_SIZE + local_col * VECTOR_SIZE]);
        vstore4(vA, 0, &tileA[local_row][local_col * VECTOR_SIZE]);

        float4 vB = vload4(0, &B[(t * TILE_SIZE + local_row) * N + col]);
        //vstore4(vB, 0, &tileB[local_row][local_col]);
        tileB[local_row][local_col] = vB;
        barrier(CLK_LOCAL_MEM_FENCE);

        for (int k = 0; k < TILE_SIZE; ++k)
        {
            //sum += tileA[local_row][k] * vload4(0, &tileB[k][local_col]);
            sum += tileA[local_row][k] * tileB[k][local_col];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    vstore4(sum, 0, &C[row * N + col]);
}
*/