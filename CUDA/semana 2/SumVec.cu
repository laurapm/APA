#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>


//PROGRAMA PARA REALIZAR LA SUMA DE UN VECTOR EN LA GPU
//USANDO 3 BLOQUES CON 8 HILOS POR BLOQUE

__global__ void sumKernel(int* c, int* a, int *b, const int tamVec){
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	if (i < tamVec)
		c[i] = a[i] + b[i];
}

//funcion auxiliar que usa CUDA para sumar vectores en paralelo
void auxSum(int* c, int* a, int* b, const int tamVec){
	int*  dev_a = nullptr;
	int* dev_b = nullptr;
	int* dev_c = nullptr;
	//Reservamos memoria
	
	cudaMalloc((void**)&dev_a, tamVec * sizeof(int));
	cudaMalloc((void**)&dev_b, tamVec * sizeof(int));
	cudaMalloc((void**)&dev_c, tamVec * sizeof(int));

	//Copiamos los vectores en la GPU
	cudaMemcpy(dev_a, a, tamVec * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b, tamVec * sizeof(int), cudaMemcpyHostToDevice);

	int numBlocks = 3;
	int threadsPerBlock = 8;
	sumKernel << <numBlocks, threadsPerBlock >> > (dev_c, dev_a, dev_a, tamVec);

	//Copiamos el resultado de la GPU en el host
	cudaMemcpy(c, dev_c, tamVec * sizeof(int), cudaMemcpyDeviceToHost);

	//liberamos la memoria
	cudaFree(dev_c);
	cudaFree(dev_a);
	cudaFree(dev_b);
}

int main(int argc, char** argv) {
	const int tamVec = 24;
	int a[tamVec] = { 1, 2, 3, 4, 5, 6,7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 };
	int b[tamVec] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 };
	int c[tamVec] = { 0 };

	auxSum(c, a, b, tamVec);

	printf("[");
	for (int i = 0; i < tamVec; i++){
		printf("%d ", a [i]);
	}

	printf("] + [");

	for (int i = 0; i < tamVec; i++){
		printf("%d ", b[i]);
	}

	printf("] = ["); 

	for (int i = 0; i < tamVec; i++){
		printf("%d ", c[i]);
	}
	printf("] \n");

	printf("\n pulse INTRO para finalizar");
	//limpiamos el buffer
	fflush(stdin);
	char intro = getchar();
	return 0;
}

