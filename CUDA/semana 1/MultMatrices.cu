#include <cuda.h>
#include <cuda_runtime.h>
#include "device_launch_parameters.h"
#include <iostream>

#define TILE_WIDTH 8


__global__ void MulMatrices(int *dev_a, int *dev_b, int *dev_c, int Width){
	int fila = blockIdx.x * TILE_WIDTH + threadIdx.x;
	int columna = blockIdx.y * TILE_WIDTH + threadIdx.y;
	int suma = 0;

	for (int i = 0; i < Width; i++)
		suma += dev_a [fila * Width + i] * dev_b[i * Width + columna];

	dev_c[fila * Width + columna] = suma;
}

int main(){
	//definimos los punteros del host y de la GPU (device)
	int *host_a, *host_b, *host_c, *dev_a, *dev_b, *dev_c;

	int numBlocks = 8;
	int threadsPerBlock = 64;
	
	int contador = 0; //lo usaremos para rellenar las matrices

	//Reservamos la memoria del host y de la GPU

	int tam = numBlocks * threadsPerBlock * sizeof(int);

	host_a = (int *)malloc(tam);
	host_b = (int *)malloc(tam);
	host_c = (int *)malloc(tam);

	cudaMalloc((void**)&dev_a, tam);
	cudaMalloc((void**)&dev_b, tam);
	cudaMalloc((void**)&dev_c, tam);

	//Rellenamos las matrices, cada fila con numeros del 0 al 15
	for (int n = 0; n< threadsPerBlock*numBlocks; n++)
	{
		host_a[n] = host_b[n] = contador;
		contador++;
		contador = contador % 16;
	}

	dim3 dimGrid(numBlocks / 2, numBlocks / 2);
	dim3 dimBlock(threadsPerBlock / TILE_WIDTH, threadsPerBlock / TILE_WIDTH);

	//Copiamos la informacion del host a la GPU
	cudaMemcpy(dev_a, host_a, tam, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, host_b, tam, cudaMemcpyHostToDevice);

	MulMatrices << < dimGrid, dimBlock >> > (dev_a, dev_b, dev_c, TILE_WIDTH * 2);

	//Devolvemos la informacion al host
	cudaMemcpy(host_c, dev_c, tam, cudaMemcpyDeviceToHost);

	//Imprimimos la matriz de resultado

	for (int i = 0; i<numBlocks * 2; i++)
	{
		for (int j = 0; j < numBlocks * 2; j++)
			printf("%d ", host_c[numBlocks * 2 * i + j]);
		printf("\n");
	}

	//liberamos memoria
	cudaFree(dev_a);
	cudaFree(host_a);

	printf("\n pulse INTRO para finalizar");

	//limpiamos el buffer
	fflush(stdin);
	char intro = getchar();
	return 0;
}