#include <stdlib.h>
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <stdio.h>
static void HandleError(cudaError_t err,
	const char *file,
	int line) {
	if (err != cudaSuccess) {
		printf("%s in %s at line %d\n", cudaGetErrorString(err),
			file, line);
		exit(EXIT_FAILURE);
	}
}
#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))
int main(void) {
	cudaDeviceProp prop;
	int count;
	//Comprobamos el numero de dispositivos que hay en el equipo
	HANDLE_ERROR(cudaGetDeviceCount(&count));
	//Recogemos los datos de todos los dispositivos en el equipo (1 en este caso)
	for (int i = 0; i< count; i++) {
		//Imprimimos los datos de la tarjeta
		printf("Numero de dispositivos en el equipo %d; dispositivo mostrado: %d\n", count, i + 1);
		HANDLE_ERROR(cudaGetDeviceProperties(&prop, i));
		printf(" --- Informacion general del dispositivo %d ---\n", i+1);
		printf("Nombre: %s\n", prop.name);
		printf("Capacidad computacion: %d.%d\n", prop.major, prop.minor);
		printf("Clock rate: %d\n", prop.clockRate);
		printf("Device copy overlap: ");
		if (prop.deviceOverlap)
			printf("Enabled\n");
		else
			printf("Disabled\n");
		printf("Timeout de ejecucion del kernel: ");
		if (prop.kernelExecTimeoutEnabled)
			printf("Enabled\n");
		else
			printf("Disabled\n");
		printf(" --- Informacion de memoria del dispositivo %d ---\n", i+1);
		printf("Memoria global total: %ld\n", prop.totalGlobalMem);
		printf("Memoria constante total: %ld\n", prop.totalConstMem);
		printf("Memoria pitch maxima: %ld\n", prop.memPitch);
		printf("Texture Alignment: %ld\n", prop.textureAlignment);
		printf(" --- Informacion MP del dispositivo %d ---\n", i+1);
		printf("Numero multiprocesadores: %d\n",
			prop.multiProcessorCount);
		printf("Memoria compartida por MP: %ld\n", prop.sharedMemPerBlock);
		printf("Registros por MP: %d\n", prop.regsPerBlock);
		printf("Hilos por warp: %d\n", prop.warpSize);
		printf("Hilos maximos por bloque: %d\n",
			prop.maxThreadsPerBlock);
		printf("Dimension maxima de hilos: (%d, %d, %d)\n",
			prop.maxThreadsDim[0], prop.maxThreadsDim[1],
			prop.maxThreadsDim[2]);
		printf("Dimension grid maxima: (%d, %d, %d)\n",
			prop.maxGridSize[0], prop.maxGridSize[1],
			prop.maxGridSize[2]);
		printf("\n");
		system("PAUSE");
	}
}