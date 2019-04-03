/*

#include <iostream>
#include <stdlib.h>
#include <cuda_runtime.h>

//funcion llamadada por el host y ejecutada por el device
__global__ void suma(int a, int b, int c, int *resultado){
	*resultado = a + b + c;
}

//funcion llamada y ejecutada por el host --> __host__

int main(int argc, char ** argv){C:\Users\Laura\AppData\Local\Temp\Rar$DIa0.869\book.h
	int n1 = 3, n2 = 5, n3 = 3;
	int *hst_c, *dev_c;

	//reserva de memoria para el host y el device
	hst_c = (int*)malloc(sizeof(int));
	cudaMalloc((void**)&dev_c, sizeof(int));

	//llamada a la funcion del kernel, pasandole los datos
	suma << <1, 1 >> >(n1, n2, n3, dev_c);

	//copiamos los datos del device al host
	cudaMemcpy(hst_c, dev_c, sizeof(int), cudaMemcpyDeviceToHost);

	printf("El resultado de la operacion es \n%2d + %2d + %2d = %2d \n", n1, n2, n3, *hst_c);

	printf("\n pulse INTRO para finalizar");
	//limpiamos el buffer
	fflush(stdin);
	char intro = getchar();
	return 0;
}

*/