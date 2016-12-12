
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void kernel_double(int *c, int *a)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    c[i] = a[i] * 2;
}
int main()
{
    const int size = 100;
    int a[size][size], c[size][size];
	int sum_a = 0;
	int sum_c = 0;

	for (int i = 0; i < size; i++) {
		for (int j = 0; j < size; j++) {
			a[i][j] = rand() % 10;
			sum_a += a[i][j];
		}
	}
	printf("sum of matrix a is %d \n", sum_a);

	int *dev_a = 0;
	int *dev_c = 0;
	cudaMalloc((void**)&dev_c, size * size * sizeof(int));
	cudaMalloc((void**)&dev_a, size * size * sizeof(int));
	cudaMemcpy(dev_a, a, size * size * sizeof(int), cudaMemcpyHostToDevice);
	printf("grid size %d \n", int(size * size / 1024) + 1);
	kernel_double << <int(size * size / 1024) + 1, 1024  >> >(dev_c, dev_a);
	cudaDeviceSynchronize();
	cudaMemcpy(c, dev_c, size * size * sizeof(int), cudaMemcpyDeviceToHost);
	cudaFree(dev_c);
	cudaFree(dev_a);
	for (int i = 0; i < size; i++) {
		for (int j = 0; j < size; j++) {
			sum_c += c[i][j];
		}
	}
	printf("sum of matrix c is %d \n", sum_c);
	return 0;
}
