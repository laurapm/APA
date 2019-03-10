#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <conio.h>
#include <time.h>
#include <stdio.h>
#include <fstream>
#include <windows.h>

#define ARRIBA 72
#define ABAJO 80
#define DERECHA 77
#define IZQUIERDA 75
#define ESCAPE 27

using namespace std;

//Funciones que van a utilizarse a lo largo del programa
//CPU
void generarTablero(int *tablero, int filas, int columnas);
void imprimirTablero(int *tablero, int filas, int columnas);
void imprimirColumnas(int columnas);
void generarSemillas(int *tablero, int filas, int columnas);
void modoManual(int *tablero, int filas, int columnas);

//GPU
__global__ void juegoManual(int *tablero, int fila, int columna, int filas, int columnas, int movimiento);
__device__ void compruebaSemillas(int *tablero, int filas, int columnas, int movimiento);
__device__ void compruebaArriba(int *tablero, int fila, int columna, int filas, int columnas);
__device__ void compruebaAbajo(int *tablero, int fila, int columna, int filas, int columnas, int anterior);
__device__ void compruebaDerecha(int *tablero, int fila, int columna, int filas, int columnas, int anterior);
__device__ void compruebaIzquierda(int *tablero, int fila, int columna, int filas, int columnas, int anterior);
//AUX
__device__ void compruebaAux(int *tablero, int fila, int columna, int filas, int columnas, int anterior);
__device__ void bajarCeros(int *tablero, int fila, int columna, int filas, int columnas);

int main(void){

	//Almacenamos las propiedades de la tarjeta para no exceder el numero de hilos posibles en el tablero
	cudaDeviceProp prop;
	cudaGetDeviceProperties(&prop, 0);

	//Propiedades del tablero
	int *tablero;
	int filas = 0;
	int columnas = 0;
	int dificultad = 0;

	//Recogemos los datos de filas y columnas del tablero que vamos a usar
	cout << "Seleccione el numero de filas con las que desea jugar: \n";
	cin >> filas;
	cout << "Seleccione el numero de columnas con las que desea jugar: \n";
	cin >> columnas;

	//Tablero m�nimo de 4 por 4
	while (filas < 4) {
		cout << "El numero de filas con las que desea jugar es demasiado peque�o, el minimo aceptado es 4: \n";
		cin >> filas;
	}
	while (columnas < 4) {
		cout << "El numero de columnas con las que desea jugar es demasiado peque�o, el minimo aceptado es 4: \n";
		cin >> columnas;
	}
	while (prop.maxThreadsPerBlock < (filas * columnas)) {
		cout << "Has excedido el limite de semillas posibles para el tablero, introduce las filas y las columnas de nuevo: \n";
		cout << "Seleccione el numero de filas con las que desea jugar: \n";
		cin >> filas;
		cout << "Seleccione el numero de columnas con las que desea jugar: \n";
		cin >> columnas;
	}

	//Reservamos la memoria del tablero y lo inicializamos con generar tablero
	tablero = new int[filas * columnas];
	generarTablero(tablero, filas, columnas);
	modoManual(tablero, filas, columnas);

    
	system("PAUSE");
}

//Generar tablero con n�meros aleatorios
void generarTablero(int *tablero, int filas, int columnas){
	srand(time(0));
	int tama�o = filas * columnas;
	for (int i = 0; i < tama�o; i++){
		tablero[i] = 0;
	}
	generarSemillas(tablero, filas, columnas);
}

//Genera los n�meros para jugar en el tablero
void generarSemillas(int *tablero, int filas, int columnas){
	int tama�o = filas * columnas;
	int contador = 0;
	while (contador < 3){
		int aux = rand() % 3;
		int i = rand() % tama�o;
		//cout << "POSICION: " << i+1 << "\n";
		if (tablero[i] == 0){
			switch (aux){
			case 0:
				tablero[i] = 2;
				break;
			case 1:
				tablero[i] = 4;
				break;
			case 2:
				tablero[i] = 8;
				break;
			}
			contador++;
		}
	}
}

//Funci�n que imprime el n�mero de columnas que va a tener el tablero para que sea m�s facil elegir semillas
void imprimirColumnas(int columnas) {
	for (int i = 0; i < columnas; i++) {
		if (i == 0) {
			cout << "         " << i + 1;
		}
		else {
			if (i < 9) {
				cout << "    " << i + 1;
			}
			else {
				cout << "   " << i + 1;
			}
		}
	}
	cout << "\n";
	for (int i = 0; i < columnas; i++) {
		if (i == 0) {
			cout << "         |";
		}
		else {
			cout << "    |";
		}
	}
	cout << "\n";
}

//Imprimimos el tablero
void imprimirTablero(int *tablero, int filas, int columnas) {
	cout << "SE HAN GENERADO " << filas << " FILAS Y " << columnas << " COLUMNAS\n";
	cout << "+-+-+-TABLERO DE JUEGO-+-+-+\n\n";
	imprimirColumnas(columnas);
	for (int i = 0; i < filas; i++) {
		if (i < 9) {
			cout << i + 1 << "    - ";
		}
		else {
			cout << i + 1 << "   - ";
		}
		for (int k = 0; k < columnas; k++) {
			//Damos color en funci�n del n�mero imprimido
			int bloque = tablero[i * filas + k];
			switch (bloque) {
				case 2:
					SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 14); //Amarillo
					break;
				case 4:
					SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 12); //Rojo
					break;
				case 8:
					SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 13); //Morado
					break;
				default:
					SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7); //Gris
			}
			if (bloque < 10) cout << "| " << bloque << " |";
			else cout << "| " << bloque << "|";
		}
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
		cout << "\n";
	}
}

__device__ void compruebaSemillas(int *tablero, int fila, int columna, int filas, int columnas, int movimiento){

	switch (movimiento){
	case ARRIBA:
		for (int i = 0; i < columnas; i++){
			compruebaAux(tablero, 0, i, filas, columnas, tablero[i]);
		}
		break;
	case ABAJO:
		compruebaArriba(tablero, fila, columna, filas, columnas);
		break;
	case DERECHA:
		for (int i = 0; i < filas; i++){
			compruebaIzquierda(tablero, i, (columnas - 1), filas, columnas, tablero[(i * columnas) + (columnas - 1)]);
		}
		break;
	case IZQUIERDA:
		for (int i = 0; i < filas; i++){
			compruebaDerecha(tablero, i, 0, filas, columnas, tablero[i * columnas]);
		}
		break;
	}

}

__device__ void compruebaArriba(int *tablero, int fila, int columna, int filas, int columnas){

	bajarCeros(tablero, fila, columna, filas, columnas);
	if (tablero[(fila * columnas) + columna] != 0 && tablero[(fila * columnas) + columna] == tablero[((fila - 1) * columnas) + columna]){
		tablero[(fila * columnas) + columna] = tablero[(fila * columnas) + columna] * 2;
		tablero[((fila - 1) * columnas) + columna] = 0;
		bajarCeros(tablero, fila, columna, filas, columnas);
	}
	//compruebaArriba(tablero, fila - 1, columna, filas, columnas);
}

__device__ void bajarCeros(int *tablero, int fila, int columna, int filas, int columnas){
	
	/*for (int i = filas - 1; i > 0; i--){
		if (tablero[(i * columnas) + columna] == 0){
			tablero[(i * columnas) + columna] = tablero[((i - 1) * columnas) + columna];
			tablero[((i - 1) * columnas) + columna] = 0;
		}

	}*/
	for (int i = filas - 1; i > 0; i--){
		if (tablero[((i - 1) * columnas) + columna] != 0){
			int a = i;
			while (tablero[((a - 1) * columnas) + columna] == 0){
				tablero[(a * columnas) + columna] = tablero[((a - 1) * columnas) + columna];
				tablero[((a - 1) * columnas) + columna] = 0;
			}
		}
	}

}

__device__ void compruebaAux(int *tablero, int fila, int columna, int filas, int columnas, int anterior){

	int siguiente = tablero[((fila + 1) * columnas) + columna];
	int contador = filas;
	if (fila != (filas - 1)){
		while (anterior == 0 && contador != 0){
			tablero[(fila * columnas) + columna] = siguiente;
		}
		if (siguiente == anterior){
			tablero[(fila * columnas) + columna] = anterior * 2;
			tablero[((fila + 1) * columnas) + columna] = 0;
			//compruebaAux(tablero, fila + 1, columna, filas, columnas, tablero[(fila * columnas) + columna]);
		}
		/*else if (anterior == 0){
			if (siguiente != 0) tablero[(fila * columnas) + columna] = siguiente;
			compruebaAux(tablero, fila + 1, columna, filas, columnas, tablero[(fila * columnas) + columna]);
		}*/
		compruebaAux(tablero, fila + 1, columna, filas, columnas, tablero[(fila * columnas) + columna]);
	}

}

__device__ void compruebaAbajo(int *tablero, int fila, int columna, int filas, int columnas, int anterior){

	if (tablero[((fila + 1) * columnas) + columna] == anterior){
		tablero[(fila * columnas) + columna] = anterior * 2;
		tablero[((fila + 1) * columnas) + columna] = 0;
	}
	else if (tablero[(fila * columnas) + columna] == 0){
		tablero[(fila * columnas) + columna] = tablero[((fila + 1) * columnas) + columna];
		tablero[((fila + 1) * columnas) + columna] = 0;
	}

}

__device__ void compruebaDerecha(int *tablero, int fila, int columna, int filas, int columnas, int anterior){

	if (tablero[(fila * columnas) + (columna + 1)] == anterior){
		tablero[(fila * columnas) + columna] = anterior * 2;
		tablero[(fila * columnas) + (columna + 1)] = 0;
	}
	else if (tablero[(fila * columnas) + columna] == 0){
		tablero[(fila * columnas) + columna] = tablero[(fila * columnas) + (columna + 1)];
		tablero[(fila * columnas) + (columna + 1)] = 0;
	}

}

__device__ void compruebaIzquierda(int *tablero, int fila, int columna, int filas, int columnas, int anterior){

	if (tablero[(fila * columnas) + (columna - 1)] == anterior){
		tablero[(fila * columnas) + columna] = anterior * 2;
		tablero[(fila * columnas) + (columna - 1)] = 0;
	}
	else if (tablero[(fila * columnas) + columna] == 0){
		tablero[(fila * columnas) + columna] = tablero[(fila * columnas) + (columna - 1)];
		tablero[(fila * columnas) + (columna - 1)] = 0;
	}

}

__global__ void juegoManual(int *tablero, int filas, int columnas, int movimiento){

	//Guardamos la columna y la fila del hilo
	int columnaHilo = threadIdx.x;
	int filaHilo = threadIdx.y;

	compruebaSemillas(tablero, filaHilo, columnaHilo, filas, columnas, movimiento);

	__syncthreads();

}

void modoManual(int *tablero, int filas, int columnas){

	//system("cls");
	int movimiento = 1;
	while (movimiento != ESCAPE){
		imprimirTablero(tablero, filas, columnas);
		cout << "Pulsa arriba, abajo, izquierda o dercha en el teclado para mover los numeros (ESC para salir): \n";
		cin >> movimiento;
		//while (movimiento != (ARRIBA || ABAJO || IZQUIERDA || DERECHA)) {
		while (movimiento != ARRIBA && movimiento != ABAJO && movimiento != IZQUIERDA && movimiento != DERECHA) {
			cout << "Tecla no valida, introduzca una valida:\n";
			cin >> movimiento;
		}

		//CUDA
		int *tablero_gpu;
		//Reservamos memoria y copiamos tablero en GPU
		cudaMalloc((void**)&tablero_gpu, (filas * columnas) * sizeof(int));
		cudaMemcpy(tablero_gpu, tablero, (filas * columnas) * sizeof(int), cudaMemcpyHostToDevice);
		//Creamos los hilos en un solo bloque
		dim3 DimGrid(1, 1);
		dim3 DimBlock(filas, columnas);
		juegoManual << < DimGrid, DimBlock >> > (tablero_gpu, filas, columnas, movimiento);
		cudaMemcpy(tablero, tablero_gpu, sizeof(int)* filas * columnas, cudaMemcpyDeviceToHost);
		//system("cls");
		generarSemillas(tablero, filas, columnas);
		cudaFree(tablero_gpu);

	}
	//system("cls");

}