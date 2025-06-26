#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <CL/cl.h>
#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <iomanip>
#include <cstdlib> 
#include <cstring>
#include <map>
#include <algorithm>
#include <cmath>

#define _CRT_SECURE_NO_WARNINGS
#define MAX_SOURCE_SIZE (0x100000)
#define VECTOR_SIZE 4
#define _SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS
//#define TILE_SIZE 32
cl_device_type parseDeviceType(const std::string& typeStr) {
    if (typeStr == "cpu") {
        return CL_DEVICE_TYPE_CPU;
    }
    else if (typeStr == "gpu") {
        return CL_DEVICE_TYPE_GPU;
    }
    else if (typeStr == "dgpu" || typeStr == "igpu") {
        return CL_DEVICE_TYPE_GPU;
    }
    else if (typeStr == "all") {
        return CL_DEVICE_TYPE_ALL;
    }
    else {
        return 0;
    }
}

// ������� ��� ���������� ������������� �����������
inline bool areAlmostEqual(float a, float b, float epsilon) {
    return fabs(a - b) <= epsilon * fmax(fabs(a), fabs(b));
}

std::vector<cl_device_id> getDevicesByType(cl_platform_id platform, cl_device_type deviceType, const std::string& deviceTypeStr) {
    cl_uint numDevices;
    cl_int ret = clGetDeviceIDs(platform, deviceType, 0, nullptr, &numDevices);
    if (ret != CL_SUCCESS || numDevices == 0) {
        return {};
    }
    std::vector<cl_device_id> devices(numDevices);
    ret = clGetDeviceIDs(platform, deviceType, numDevices, devices.data(), nullptr);
    if (ret != CL_SUCCESS) {
        return {};
    }

    // ���������� ��������� �� ���� (���������� ��� ���������������)
    if (deviceTypeStr == "igpu" || deviceTypeStr == "dgpu") {
        std::vector<cl_device_id> filteredDevices;
        for (const auto& device : devices) {
            cl_bool unifiedMemory;
            clGetDeviceInfo(device, CL_DEVICE_HOST_UNIFIED_MEMORY, sizeof(unifiedMemory), &unifiedMemory, nullptr);
            if ((deviceTypeStr == "igpu" && unifiedMemory == CL_TRUE) ||
                (deviceTypeStr == "dgpu" && unifiedMemory == CL_FALSE)) {
                filteredDevices.push_back(device);
            }
        }
        return filteredDevices;
    }

    return devices;
}

void writeMatrixToFile(float* matrix, int rows, int cols, const std::string& filename) {
    FILE* output_file = fopen(filename.c_str(), "w");
    if (!output_file) {
        std::cerr << "Failed to open output file." << std::endl;
        return;
    }

    fprintf(output_file, "%d %d\n", cols, rows);

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            fprintf(output_file, "%.6f ", matrix[i * cols + j]);
        }
        fprintf(output_file, "\n");
    }

    fclose(output_file);
}

void zeroPadMatrix(float* inputMatrix, float* outputMatrix, int M, int K, int paddedM, int paddedK) {
    // ���������� �������� ������� ������
    memset(outputMatrix, 0, sizeof(float) * paddedM * paddedK);

    // ����������� �������� �� �������� ������� � ��������
    for (int i = 0; i < M; ++i) {
        memcpy(&outputMatrix[i * paddedK], &inputMatrix[i * K], K * sizeof(float));
    }
}

void zeroPadMatrixB(float* inputMatrix, float* outputMatrix, int K, int N, int paddedK, int paddedN) {
    // ���������� �������� ������� ������
    memset(outputMatrix, 0, sizeof(float) * paddedK * paddedN);

    // ����������� �������� �� �������� ������� � ��������
    for (int i = 0; i < K; ++i) {
        memcpy(&outputMatrix[i * paddedN], &inputMatrix[i * N], N * sizeof(float));
    }
}

int main(int argc, char* argv[]) {
    std::map<std::string, std::string> args;
    for (int i = 1; i < argc; i += 2) {
        if (i + 1 < argc) {
            args[argv[i]] = argv[i + 1];
        }
        else {
            std::cout << "Usage: lab0.exe < --input file_name > < --output file_name > [ --device-type { dgpu | igpu | gpu | cpu | all } ] [ --device-index index ]\n";;
            return 1;
        }
    }
    // ���������� ��� �������� ���� � ������� ����������
    std::string deviceTypeStr = args.count("--device-type") ? args["--device-type"] : "all";
    cl_int deviceIndex = args.count("--device-index") ? std::stoi(args["--device-index"]) : 0;

    cl_device_type deviceType = parseDeviceType(deviceTypeStr);
    if (deviceType == NULL) {
        std::cerr << "Invalid device type.\n";
        return 1;
    }

    std::string input_filename;
    std::string output_filename;
    cl_platform_id platformID = NULL;

    cl_uint numDevices;
    cl_int ret;

    // �������� ���������� ��������� ������
    int realization = 0;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--realization") == 0) {
            if (i + 1 < argc) {
                realization = atoi(argv[i + 1]);
            }
            else {
                std::cerr << "--realization requires one argument." << std::endl;
                return 1;
            }
        }
    }

    // ��������� ���������� ��������� ������
    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--input" && i + 1 < argc) {
            input_filename = argv[++i];
        }
        else if (arg == "--output" && i + 1 < argc) {
            output_filename = argv[++i];
        }
    }

    if (input_filename.empty() || output_filename.empty()) {
        std::cerr << "Usage: " << argv[0] << " --input <input_file> --output <output_file>" << std::endl;
        return 1;
    }

    // ������ ������ �� �����
    std::ifstream input_file(input_filename);
    if (!input_file.is_open()) {
        std::cerr << "Failed to open input file." << std::endl;
        return 1;
    }

    cl_uint numPlatforms;
    ret = clGetPlatformIDs(0, nullptr, &numPlatforms);

    std::vector<cl_platform_id> platforms(numPlatforms);
    ret = clGetPlatformIDs(numPlatforms, platforms.data(), nullptr);
    if (ret != CL_SUCCESS) {
        std::cerr << "Failed to get platform IDs.\n";
        return 1;
    }

    std::vector<cl_device_id> allDevices;
    for (auto& platform : platforms) {
        auto devices = getDevicesByType(platform, deviceType, deviceTypeStr);
        allDevices.insert(allDevices.end(), devices.begin(), devices.end());
    }
    if (allDevices.empty()) {
        std::cerr << "No devices found.\n";
        return 1;
    }

    // ���������� ��������� �� ����
    std::vector<std::pair<cl_device_id, int>> devicesWithIndex;
    for (auto device : allDevices) {
        cl_device_type type;
        cl_bool unifiedMemory;
        clGetDeviceInfo(device, CL_DEVICE_TYPE, sizeof(type), &type, nullptr);
        clGetDeviceInfo(device, CL_DEVICE_HOST_UNIFIED_MEMORY, sizeof(unifiedMemory), &unifiedMemory, nullptr);

        int index_for_all;
        if (type == CL_DEVICE_TYPE_GPU && unifiedMemory == CL_FALSE) {
            index_for_all = 0; // ���������� ����������
        }
        else if (type == CL_DEVICE_TYPE_GPU && unifiedMemory == CL_TRUE) {
            index_for_all = 1; // ��������������� ����������
        }
        else if (type == CL_DEVICE_TYPE_CPU) {
            index_for_all = 2; // ���������
        }
        else {
            index_for_all = 3; // ��������� ����������
        }
        devicesWithIndex.emplace_back(device, index_for_all);
    }

    std::sort(devicesWithIndex.begin(), devicesWithIndex.end(), [](const auto& a, const auto& b) {
        return a.second < b.second;
        });

    std::vector<cl_device_id> sortedDevices;
    for (const auto& pair : devicesWithIndex) {
        sortedDevices.push_back(pair.first);
    }

    // ���������� allDevices ���������������� ������������
    allDevices = sortedDevices;

    if (deviceIndex >= allDevices.size()) {
        std::cerr << "Device index out of range. Using device 0 instead.\n";
        return 1;
    }

    cl_device_id deviceID = allDevices[deviceIndex];

    char deviceName[128];
    clGetDeviceInfo(deviceID, CL_DEVICE_NAME, sizeof(deviceName), deviceName, nullptr);
    std::cout << "Selected device: " << deviceName << "\n";
    std::cout << "Selected device index: " << deviceIndex << "\n";

    cl_uint M, N, K;
    input_file >> N >> K >> M;

    float* A = (float*)malloc(sizeof(float) * M * K);
    float* B = (float*)malloc(sizeof(float) * K * N);
    float* D = (float*)malloc(sizeof(float) * M * N);

    for (int i = 0; i < M * K; i++) {
        input_file >> A[i];
    }

    for (int i = 0; i < K * N; i++) {
        input_file >> B[i];
    }
    int TILE_SIZE;
    if (realization == 2) {
        TILE_SIZE = 16;
    }
    else if (realization == 3) {
        TILE_SIZE = 32;
    }
    /*
    // ������������ �� �����
#pragma omp parallel for
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            float sum = 0.0f;
            for (int k = 0; k < K; k++) {
                sum += A[i * K + k] * B[k * N + j];
            }
            D[i * N + j] = sum;
        }
    }
    */

    if (realization == 0) {
        double tstart = omp_get_wtime();

        // ���������� ������������ ������ �� �����
#pragma omp parallel for
        for (int i = 0; i < M; i++) {
            for (int j = 0; j < N; j++) {
                float sum = 0.0f;
                for (int k = 0; k < K; k++) {
                    sum += A[i * K + k] * B[k * N + j];
                }
                D[i * N + j] = sum;
            }
        }

        double tend = omp_get_wtime();
        printf("Execution time (ms): %lf\n", (tend - tstart) * 1000);

        // ������ ���������� � ����
        writeMatrixToFile(D, M, N, output_filename);
        // ������������ ������
        free(A);
        free(B);
        free(D);
        input_file.close();
        return 0;
    }

    // �������� ��������� OpenCL
    cl_context context = clCreateContext(nullptr, 1, &deviceID, nullptr, nullptr, NULL);

    // ������ ��������� ���� ���� �� �����
    std::ifstream kernelFile("kernel.cl");
    if (!kernelFile.is_open()) {
        std::cerr << "Error opening kernel file." << std::endl;
        return 1;
    }

    std::string kernelSource((std::istreambuf_iterator<char>(kernelFile)), std::istreambuf_iterator<char>());
    const char* kernelSourceCStr = kernelSource.c_str();

    // �������� ��������� OpenCL � �������� ����� ����
    cl_program program = clCreateProgramWithSource(context, 1, &kernelSourceCStr, NULL, NULL);

    // ���������� ���������
    clBuildProgram(program, 1, &deviceID, NULL, NULL, NULL);

    // �������� ������� ������ OpenCL
    cl_command_queue commandQueue = clCreateCommandQueue(context, deviceID, CL_QUEUE_PROFILING_ENABLE, NULL);

    // �������� ������� ��� ������
    cl_mem aMemObj = clCreateBuffer(context, CL_MEM_READ_ONLY, M * K * sizeof(float), NULL, NULL);
    cl_mem bMemObj = clCreateBuffer(context, CL_MEM_READ_ONLY, K * N * sizeof(float), NULL, NULL);
    cl_mem cMemObj = clCreateBuffer(context, CL_MEM_WRITE_ONLY, M * N * sizeof(float), NULL, NULL);

    // ������ ������ � ������
    clEnqueueWriteBuffer(commandQueue, aMemObj, CL_TRUE, 0, M * K * sizeof(float), static_cast<void*>(A), 0, NULL, NULL);
    clEnqueueWriteBuffer(commandQueue, bMemObj, CL_TRUE, 0, K * N * sizeof(float), static_cast<void*>(B), 0, NULL, NULL);

    cl_kernel kernel;
    cl_event event;
    size_t localItemSize[2];
    const char* kname[] = { "matmul" , "matmul_local", "matmul_vector" };
    

    kernel = clCreateKernel(program, kname[realization - 1], NULL);


    if (realization == 1)
    {
        // ��������� ���������� ����
        clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*)&aMemObj);
        clSetKernelArg(kernel, 1, sizeof(cl_mem), (void*)&bMemObj);
        clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*)&cMemObj);
        clSetKernelArg(kernel, 3, sizeof(cl_int), (void*)&M);
        clSetKernelArg(kernel, 4, sizeof(cl_int), (void*)&N);
        clSetKernelArg(kernel, 5, sizeof(cl_int), (void*)&K);

        // ��������� ������� ���������� � ��������� ������� ���������
        size_t globalItemSize[2] = { static_cast<size_t>(N), static_cast<size_t>(M) };

        // ���������� ����
        clEnqueueNDRangeKernel(commandQueue, kernel, 2, NULL, globalItemSize, NULL, NULL, NULL, &event);

        // ������ ���������� �� ������ ������ ������� � ����
        std::vector<float> C(M * N);
        clEnqueueReadBuffer(commandQueue, cMemObj, CL_TRUE, 0, sizeof(float) * M * N, C.data(), 0, NULL, NULL);

        // ������ ���������� � ���� output.txt
        writeMatrixToFile(C.data(), M, N, output_filename);
    }
    else
    {
        // ������� ����� ��������, ������� TILE_SIZE
        int paddedM = ((M + TILE_SIZE - 1) / TILE_SIZE) * TILE_SIZE;
        int paddedN = ((N + TILE_SIZE - 1) / TILE_SIZE) * TILE_SIZE;
        int paddedK = ((K + TILE_SIZE - 1) / TILE_SIZE) * TILE_SIZE;

        // ��������� ������ ��� ������ � zero padding
        float* paddedA = (float*)malloc(sizeof(float) * paddedM * paddedK);
        float* paddedB = (float*)malloc(sizeof(float) * paddedK * paddedN);
        float* paddedC = (float*)malloc(sizeof(float) * paddedM * paddedN);
        float* Z = (float*)malloc(sizeof(float) * M * N);

        // ���������� ������ � zero padding
        zeroPadMatrix(A, paddedA, M, K, paddedM, paddedK);
        zeroPadMatrixB(B, paddedB, K, N, paddedK, paddedN);

        // �������� ������� ��� ������ � zero padding
        cl_mem aMemObj = clCreateBuffer(context, CL_MEM_READ_ONLY, paddedM * paddedK * sizeof(float), NULL, NULL);
        cl_mem bMemObj = clCreateBuffer(context, CL_MEM_READ_ONLY, paddedK * paddedN * sizeof(float), NULL, NULL);
        cl_mem cMemObj = clCreateBuffer(context, CL_MEM_WRITE_ONLY, paddedM * paddedN * sizeof(float), NULL, NULL);

        // ����������� ������ � ������
        clEnqueueWriteBuffer(commandQueue, aMemObj, CL_TRUE, 0, paddedM* paddedK * sizeof(float), static_cast<void*>(paddedA), 0, NULL, NULL);
        clEnqueueWriteBuffer(commandQueue, bMemObj, CL_TRUE, 0, paddedK* paddedN * sizeof(float), static_cast<void*>(paddedB), 0, NULL, NULL);

        clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*)&aMemObj);
        clSetKernelArg(kernel, 1, sizeof(cl_mem), (void*)&bMemObj);
        clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*)&cMemObj);
        clSetKernelArg(kernel, 3, sizeof(cl_uint), (void*)&paddedM);
        clSetKernelArg(kernel, 4, sizeof(cl_uint), (void*)&paddedN);
        clSetKernelArg(kernel, 5, sizeof(cl_uint), (void*)&paddedK);

        // ������� ������� ������
        size_t globalItemSize[2];
        globalItemSize[0] = realization == 3 ? paddedN / VECTOR_SIZE : paddedN;
        globalItemSize[1] = paddedM;

        // ����� ������� ������� ��������� localItemSize � ����������� �� ����������
        localItemSize[1] = TILE_SIZE;

        // ����� ������� ������� ��������� localItemSize � ����������� �� ����������
        localItemSize[0] = realization == 3 ? TILE_SIZE / VECTOR_SIZE : TILE_SIZE;

        // ���������� ����
        clEnqueueNDRangeKernel(commandQueue, kernel, 2, NULL, globalItemSize, localItemSize, 0, NULL, &event);

        // ������ ���������� �� ������ ������
        clEnqueueReadBuffer(commandQueue, cMemObj, CL_TRUE, 0, paddedM* paddedN * sizeof(float), paddedC, 0, NULL, NULL);

        // ���������� ���������� � ������������� ��������� �� ������� � zero padding
        for (int i = 0; i < M; ++i) {
            memcpy(&Z[i * N], &paddedC[i * paddedN], N * sizeof(float));
        }

        // ������ ���������� � ����
        writeMatrixToFile(Z, M, N, output_filename);

        free(paddedA);
        free(paddedB);
        free(paddedC);
        /*
        // ����������� ���������� ������������� �����������
        float epsilon = 1e-3; // ��������� ��������
        
        // ��������� ���������� �� ����� � � �������������� OpenCL
        bool resultsMatch = true;
        for (int i = 0; i < M; ++i) {
            for (int j = 0; j < N; ++j) {
                if (!areAlmostEqual(D[i * N + j], Z[i * N + j], epsilon)) {
                    resultsMatch = false;
                    printf("Mismatch at (%d, %d): host = %.6f, OpenCL = %.6f\n", i, j, D[i * N + j], Z[i * N + j]);
                }
            }
        }

        if (resultsMatch) {
            printf("Results match with relative error tolerance of %.1e.\n", epsilon);
        }
        else {
            printf("Results do not match.\n");
        }*/
        
    }
    
    cl_ulong start_time;
    cl_ulong end_time;

    clGetEventProfilingInfo(event, CL_PROFILING_COMMAND_START, sizeof(start_time), &start_time, NULL);
    clGetEventProfilingInfo(event, CL_PROFILING_COMMAND_END, sizeof(end_time), &end_time, NULL);

    printf("Execution time of kernel: %g ms\n", (end_time - start_time) * 1E-6);
    
    if (realization >= 2)
    {
        printf("LOCAL_WORK_SIZE [%i, %i]\n", (int)localItemSize[0], (int)localItemSize[1]);
        if (realization == 3) 
        {
            printf("WI_WORK [%i]\n", (int)VECTOR_SIZE);
        }
    }
    
    // ������������ ��������
    free(A);
    free(B);
    free(D);
    clReleaseEvent(event);
    clReleaseKernel(kernel);
    clReleaseProgram(program);
    clReleaseMemObject(aMemObj);
    clReleaseMemObject(bMemObj);
    clReleaseMemObject(cMemObj);
    clReleaseCommandQueue(commandQueue);
    clReleaseContext(context);
    return 0;
}