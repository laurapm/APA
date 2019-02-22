#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <cuda.h>
#include <device_functions.h>
#include <cuda_runtime_api.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <Windows.h>
#include <iostream>
#include <time.h>
#include <fstream>

using namespace std;
//Funciones que van a usarse a lo largo de la ejecución del programa
//CPU
void generarTablero(int *tablero, int filas, int columnas, int dificultad);
void imprimirTablero(int *tablero, int filas, int columnas);
void imprimirColumnas(int columnas);
void modoManual(int *tablero, int filas, int columnas, int dificultad);
void guardarPartida(int *tablero, int nFilas, int nCols, int nDificultad);
void cargarPartida();
//GPU
__global__ void ToyBlastManual(int *tablero, int filas, int columnas, int fila, int columna, int bomba);
__device__ void compruebaPiezas(int * tablero, int columna, int fila, int filas, int columnas, int anterior);

__device__ void compruebaArriba(int *tablero, int columna, int fila, int filas, int columnas, int anterior);
__device__ void compruebaAbajo(int *tablero, int columna, int fila, int filas, int columnas, int anterior);

__device__ void compruebaDerecha(int *tablero, int columna, int fila, int filas, int columnas, int anterior);
__device__ void compruebaIzquierda(int *tablero, int columna, int fila, int filas, int columnas, int anterior);

__device__ void compruebaArribaDerecha(int *tablero, int columna, int fila, int filas, int columnas, int anterior);
__device__ void compruebaAbajoDerecha(int *tablero, int columna, int fila, int filas, int columnas, int anterior);

__device__ void compruebaArribaIzquierda(int *tablero, int columna, int fila, int filas, int columnas, int anterior);
__device__ void compruebaAbajoIzquierda(int *tablero, int columna, int fila, int filas, int columnas, int anterior);


int main(void) {
	//Almacenamos las propiedades de la tarjeta para no exceder el numero de hilos posibles en el tablero
	int *tablero;
	int filas = 0;
	int columnas = 0;
	int dificultad = 0;
	//Preguntamos si quiere cargar un juego guardado anteriormente o si quiere empezar de nuevo
	cout << "Quieres continuar una partida anterior o empezar de nuevo? (c: cargar / n: nueva partida)\n";
	char partida = 'a';
	cin >> partida;
	while (partida != 'c' && partida != 'n') {
		cout << "Introduce un valor valido para iniciar el juego\n";
		cin >> partida;
	}
	if (partida == 'n') {
		//Recogemos los datos de filas y columnas del tablero que vamos a usar
		cout << "Seleccione el numero de filas con las que desea jugar: \n";
		cin >> filas;
		cout << "Seleccione el numero de columnas con las que desea jugar: \n";
		cin >> columnas;
		//Tablero mínimo de 8 por 8
		while (filas < 8) {
			cout << "El numero de filas con las que desea jugar es demasiado pequeño, el minimo aceptado es 8: \n";
			cin >> filas;
		}
		while (columnas < 8) {
			cout << "El numero de columnas con las que desea jugar es demasiado pequeño, el minimo aceptado es 8: \n";
			cin >> columnas;
		}
		//Seleccionamos el nivel de dificultad
		cout << "Seleccione el nivel de dificultad: \n";
		cin >> dificultad;
		//Si no entra dentro de los dos niveles que se recogen en la práctica los pedimos en bucle hasta que se cumpla 
		while (dificultad != 1 && dificultad != 2) {
			cout << "Seleccione el nivel de dificultad, solo puede elegirse 1 o 2: \n";
			cin >> dificultad;
		}
		//Reservamos la memoria del tablero y lo inicializamos con generar tablero
		tablero = new int[filas * columnas];
		generarTablero(tablero, filas, columnas, dificultad);
		modoManual(tablero, filas, columnas, dificultad);
	}
	else {
		cargarPartida();
	}
	system("PAUSE");
}


//Generamos el tablero con números aleatorios en función de la dificultad
void generarTablero(int *tablero, int filas, int columnas, int dificultad) {
	srand(time(0));
	for (int i = 0; i < (filas * columnas); i++) {
		if (dificultad == 1) {
			tablero[i] = rand() % 5 + 1;
		}
		else {
			tablero[i] = rand() % 6 + 1;
		}
	}
}


//Rellenar tablero cuando hemos explotado bloques
void rellenarTablero(int *tablero, int filas, int columnas, int dificultad) {
	srand(time(0));
	for (int i = 0; i < (filas * columnas); i++) {
		if (tablero[i] == 0) {
			switch (dificultad) {
			case 1:
				tablero[i] = rand() % 5 + 1;
				break;
			case 2:
				tablero[i] = rand() % 6 + 1;
				break;
			}
		}
	}
}

//Función que imprime el número de columnas que va a tener el tablero para que sea más facil elegir piezas
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
			//Damos color en función del número imprimido
			int bloque = tablero[i * filas + k];
			switch (bloque) {
			case 1:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
				break;
			case 2:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 4);
				break;
			case 3:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 11);
				break;
			case 4:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 2);
				break;
			case 5:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 5);
				break;
			case 6:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 6);
				break;
			case 7:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 3);
				break;
			case 8:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 3);
				break;
			case 9:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 3);
				break;
			}
			cout << "| " << bloque << " |";
		}
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
		cout << "\n";
	}
}

__device__ void compruebaPiezas(int * tablero, int columna, int fila, int filas, int columnas, int anterior)
{
	//compruebaPiezas(tablero, columnaHilo, filaHilo, filas, columnas, anterior);
	//Aquí vamos a indicarle hacia donde tiene que buscar en función de la posición del tablero en la cual nos encontremos
	//Primero comprobamos que no sea un tipo de bomba, en nuestro caso, las bombas van a ser 7 8 y 9 
	//7 elimina la fila, 8 la columna y 9 es el TNT
	if (tablero[(fila * columnas) + columna] != 7 && tablero[(fila * columnas) + columna] != 8 && tablero[(fila * columnas) + columna] != 9) {
		//EMPEZAMOS CON LAS PIEZAS DE LAS CUATRO ESQUINAS
		//SI ESTAMOS EN LA SUPERIOR IZQUIERDA SOLO PODEMOS COMPROBAR HACIA ABAJO, DERECHA Y DIAGONAL DERECHA
		if (fila == 0 && columna == 0) {
			compruebaDerecha(tablero, columna, fila, filas, columnas, anterior);
			compruebaAbajo(tablero, columna, fila, filas, columnas, anterior);
		}
		//SI ESTAMOS EN LA SUPERIOR DERECHA SOLO PODEMOS COMPROBAR HACIA ABAJO, IZQUIERDA Y DIAGONAL IZQUIERDA
		if (fila == 0 && columna == (columnas - 1)) {
			compruebaIzquierda(tablero, columna, fila, filas, columnas, anterior);
			compruebaAbajo(tablero, columna, fila, filas, columnas, anterior);
		}
		//SI ESTAMOS EN LA INFERIOR IZQUIERDA SOLO PODEMOS COMPROBAR HACIA ARRIBA, DERECHA Y DIAGONAL DERECHA
		if (fila == (filas - 1) && columna == 0) {
			compruebaDerecha(tablero, columna, fila, filas, columnas, anterior);
			compruebaArriba(tablero, columna, fila, filas, columnas, anterior);
		}
		//SI ESTAMOS EN LA INFERIOR DERECHA SOLO PODEMOS COMPROBAR HACIA ARRIBA, IZQUIERDA Y DIAGONAL IZQUIERDA
		if (fila == (filas - 1) && columna == (columnas - 1)) {
			compruebaArriba(tablero, columna, fila, filas, columnas, anterior);
			compruebaIzquierda(tablero, columna, fila, filas, columnas, anterior);
		}
		//UNA VEZ COMPROBADAS LAS ESQUINAS, AUN TENEMOS OTROS CUATRO CASOS ESPECIALES, ESTAR EN LA FILA DE ARRIBA, FILA DE ABAJO, COLUMNA DE LA IZQ Y COLUMNA DE LA DERECHA
		//SI ESTAMOS EN LA FILA DE ARRIBA SOLO PODEMOS IR HACIA IZQ, DERECHA, DIAGONAL DERECHA, DIAGONAL IZQUIERDA Y HACIA ABAJO
		if (fila == 0) {
			compruebaIzquierda(tablero, columna, fila, filas, columnas, anterior);
			compruebaDerecha(tablero, columna, fila, filas, columnas, anterior);
			compruebaAbajo(tablero, columna, fila, filas, columnas, anterior);
		}
		//SI ESTAMOS EN LA FILA DE ABAJO SOLO PODEMOS IR HACIA IZQ, DERECHA, DIAGONAL DERECHA, DIAGONAL IZQUIERDA Y ARRIBA
		if (fila == (filas - 1)) {
			compruebaIzquierda(tablero, columna, fila, filas, columnas, anterior);
			compruebaDerecha(tablero, columna, fila, filas, columnas, anterior);
			compruebaArriba(tablero, columna, fila, filas, columnas, anterior);
		}
		//SI ESTAMOS EN LA COLUMNA IZQUIERDA SOLO SE COMPRUEBA HACIA DERECHA, ARRIBA, ABAJO, DIAGONAL DERECHA Y DIAGONAL IZQ
		if (columna == 0) {
			compruebaDerecha(tablero, columna, fila, filas, columnas, anterior);
			compruebaArriba(tablero, columna, fila, filas, columnas, anterior);
			compruebaAbajo(tablero, columna, fila, filas, columnas, anterior);

		}
		//SI ESTAMOS EN LA COLUMNA DERECHA SOLO SE COMPRUEBA HACIA IZQUIERDA, ARRIBA, ABAJO, DIAGONAL DERECHA Y DIAGONAL IZQ
		if (columna == (columnas - 1)) {
			compruebaIzquierda(tablero, columna, fila, filas, columnas, anterior);
			compruebaArriba(tablero, columna, fila, filas, columnas, anterior);
			compruebaAbajo(tablero, columna, fila, filas, columnas, anterior);

		}
		//CUALQUIER OTRO CASO
		else {
			compruebaArriba(tablero, columna, fila, filas, columnas, anterior);
			compruebaAbajo(tablero, columna, fila, filas, columnas, anterior);
			compruebaDerecha(tablero, columna, fila, filas, columnas, anterior);
			compruebaIzquierda(tablero, columna, fila, filas, columnas, anterior);
		}
	}
	else { //BOMBAS
		//7 elimina la fila, 8 la columna y 9 es el TNT
		if (tablero[(fila * columnas) + columna] == 7) {
			compruebaDerecha(tablero, columna, fila, filas, columnas, 7);
			compruebaIzquierda(tablero, columna, fila, filas, columnas, 7);
		}
		else if (tablero[(fila * columnas) + columna] == 8) {
			compruebaAbajo(tablero, columna, fila, filas, columnas, 8);
			compruebaArriba(tablero, columna, fila, filas, columnas, 8);
		}
		else if (tablero[(fila * columnas) + columna] == 9) {
			compruebaAbajo(tablero, columna, fila, filas, columnas, 9);
			compruebaArriba(tablero, columna, fila, filas, columnas, 9);
			compruebaDerecha(tablero, columna, fila, filas, columnas, 9);
			compruebaIzquierda(tablero, columna, fila, filas, columnas, 9);
			compruebaAbajoDerecha(tablero, columna, fila, filas, columnas, 9);
			compruebaAbajoIzquierda(tablero, columna, fila, filas, columnas, 9);
			compruebaArribaDerecha(tablero, columna, fila, filas, columnas, 9);
			compruebaArribaIzquierda(tablero, columna, fila, filas, columnas, 9);
		}
	}
}


__device__ void compruebaArriba(int *tablero, int columna, int fila, int filas, int columnas, int anterior) {
	if (anterior == 8) {
		for (int i = 0; (fila - i) >= 0; i++) {
			tablero[((fila - i) * columnas) + columna] = 0;
		}
	}
	else if (anterior == 9) {
		tablero[(fila * columnas) + columna] = 0;
		if (fila != 0) {
			tablero[((fila - 1) * columnas) + columna] = 0;
		}
	}
	else {
		if (tablero[((fila - 1) * columnas) + columna] == anterior) {
			tablero[((fila - 1) * columnas) + columna] = 0;
			tablero[(fila * columnas) + columna] = 0;
			compruebaPiezas(tablero, columna, fila - 1, filas, columnas, anterior);
		}
	}
}

__device__ void compruebaAbajo(int *tablero, int columna, int fila, int filas, int columnas, int anterior) {
	if (anterior == 8) {
		for (int i = 0; (fila + i) < filas; i++) {
			tablero[((fila + i) * columnas) + columna] = 0;
		}
	}
	else if (anterior == 9) {
		tablero[(fila * columnas) + columna] = 0;
		if (fila != (filas - 1)) {
			tablero[((fila + 1) * columnas) + columna] = 0;
		}
	}
	else {
		if (tablero[((fila + 1) * columnas) + columna] == anterior) {
			tablero[((fila + 1) * columnas) + columna] = 0;
			tablero[(fila * columnas) + columna] = 0;
			compruebaPiezas(tablero, columna, fila + 1, filas, columnas, anterior);
		}
	}
}

__device__ void compruebaDerecha(int *tablero, int columna, int fila, int filas, int columnas, int anterior) {
	if (anterior == 7) {
		for (int i = 0; (fila + i) < columnas; i++) {
			tablero[(fila  * columnas) + i] = 0;
		}
	}
	else if (anterior == 9) {
		tablero[(fila * columnas) + columna] = 0;
		if (columna != (columnas - 1)) {
			tablero[(fila * columnas) + columna + 1] = 0;
		}
	}
	else {
		if (tablero[(fila * columnas) + (columna + 1)] == anterior) {
			tablero[(fila * columnas) + (columna + 1)] = 0;
			tablero[(fila * columnas) + columna] = 0;
			compruebaPiezas(tablero, columna + 1, fila, filas, columnas, anterior);
		}
	}
}

__device__ void compruebaIzquierda(int *tablero, int columna, int fila, int filas, int columnas, int anterior) {
	if (anterior == 7) {
		for (int i = 0; (fila - i) >= 0; i++) {
			tablero[(fila  * columnas) - i] = 0;
		}
	}
	else if (anterior == 9) {
		tablero[(fila * columnas) + columna] = 0;
		if (columna != 0) {
			tablero[(fila * columnas) + columna - 1] = 0;
		}
	}
	else {
		if (tablero[(fila * columnas) + (columna - 1)] == anterior) {
			tablero[(fila * columnas) + (columna - 1)] = 0;
			tablero[(fila * columnas) + columna] = 0;
			compruebaPiezas(tablero, columna - 1, fila, filas, columnas, anterior);
		}
	}
}

__device__ void compruebaArribaDerecha(int *tablero, int columna, int fila, int filas, int columnas, int anterior) {
	//en columna = columnas -1 y en fila = 0
	if (columna != columnas - 1 && fila != 0) {
		tablero[((fila - 1) * columnas) + columna + 1] = 0;
	}
}
__device__ void compruebaAbajoDerecha(int *tablero, int columna, int fila, int filas, int columnas, int anterior) {
	//en columna = columnas - 1 y en fila = filas - 1
	if (columna != columnas - 1 && fila != filas - 1) {
		tablero[((fila + 1) * columnas) + columna + 1] = 0;
	}
}

__device__ void compruebaArribaIzquierda(int *tablero, int columna, int fila, int filas, int columnas, int anterior) {
	//en columna = 0 y en fila = 0
	if (columna != 0 && fila != 0) {
		tablero[((fila - 1) * columnas) + columna - 1] = 0;
	}
}
__device__ void compruebaAbajoIzquierda(int *tablero, int columna, int fila, int filas, int columnas, int anterior) {
	//en columna = 0 y en fila = filas -1
	if (columna != 0 && fila != filas - 1) {
		tablero[((fila + 1) * columnas) + columna - 1] = 0;
	}
}


__global__ void ToyBlastManual(int *tablero, int filas, int columnas, int columna, int fila, int bomba) {
	__shared__ int Tablero_Compartida[5000];
	//Recogemos la fila y la columna del hilo
	int columnaHilo = blockIdx.y * blockDim.y + threadIdx.y;
	int filaHilo = blockIdx.x*blockDim.x + threadIdx.x;
	//int posy = blockIdx.x * blockDim.x + threadIdx.x;
	//int posx = blockIdx.y * blockDim.y + threadIdx.y;
	int coordenadaHilo = columnaHilo*columnas + filaHilo;
	int ficha = fila * columnas + columna;

	Tablero_Compartida[coordenadaHilo] = tablero[coordenadaHilo];
	__syncthreads();
	int contador = 0;
	__syncthreads();
	if (coordenadaHilo == ficha) {
		int anterior = Tablero_Compartida[coordenadaHilo];
		compruebaPiezas(Tablero_Compartida, columnaHilo, filaHilo, filas, columnas, anterior);
		for (int i = 0; i < filas * columnas; i++) {
			if (Tablero_Compartida[i] == 0) {
				contador++;
			}
		}
		if (contador >= 6 && anterior != 9 && anterior != 7 && anterior != 8) {
			Tablero_Compartida[ficha] = 9;
		}
		if (contador == 5) {
			Tablero_Compartida[ficha] = bomba; //Tengo que pasarle la bomba ya generada porque con curand me descuadraba todas las comprobaciones
		}
	}
	__syncthreads();
	//Sube los ceros que hemos colocado al comprobar la posicion pedida por teclado bajando hacia abajo los bloques
	if (columnaHilo < columnas && filaHilo < filas) {
		if (columnaHilo < columnas&& filaHilo < filas) {
			for (int i = 1; i < filas; i++) {

				if (tablero[(filas - i)*columnas + columnaHilo] == 0) {
					if (tablero[(filas - (i + 1))*columnas + columnaHilo] == 0) {
						int j = i;
						while (tablero[(filas - (j + 1))*columnas + columnaHilo] == 0 && j < filas) {
							j++;
						}
						tablero[(filas - i)*columnas + columnaHilo] = tablero[(filas - (j + 1))*columnas + columnaHilo];
						tablero[(filas - (j + 1))*columnas + columnaHilo] = 0;
					}
					else {
						tablero[(filas - i)*columnas + columnaHilo] = tablero[(filas - (i + 1))*columnas + columnaHilo];
						tablero[(filas - (i + 1))*columnas + columnaHilo] = 0;
					}
				}
				__syncthreads();

			}
		}
	}
	__syncthreads();
	tablero[coordenadaHilo] = Tablero_Compartida[coordenadaHilo];

}

void guardarPartida(int *tablero, int filas, int columnas, int dificultad) {
	ofstream doc;
	doc.open("partida.txt");
	doc << filas << "\n";
	doc << columnas << "\n";
	doc << dificultad << "\n";
	for (int i = 0; i < filas * columnas; i++) {
		doc << tablero[i] << " ";
	}
	doc.close();
	system("cls");
	cout << "Guardado correctamente.\n\n";
}

void cargarPartida() {
	const string fichero = "partida.txt";
	ifstream leer;
	leer.open(fichero.c_str());
	int  d, *tablero;
	int i = 0;
	int n = 48;
	int f = 0;
	int c = 0;
	char fila[80];
	if (!leer.fail()) {
		leer.getline(fila, 80, '\n');
		while (n > 47 && n < 58) {
			n = (int)fila[i];
			i++;
			if (n > 47 && n < 58) {
				f = f * 10 + (n - 48);
			}
		}

	}
	n = 48;
	i = 0;
	if (!leer.fail()) {
		leer.getline(fila, 80, '\n');
		while (n > 47 && n < 58) {
			n = (int)fila[i];
			i++;
			if (n > 47 && n < 58) {
				c = c * 10 + (n - 48);
			}
		}

	}
	if (!leer.fail()) {
		leer.getline(fila, 80, '\n');
		d = (int)fila[0] - 48;
	}


	tablero = new int[f*c];
	for (int i = 0; i < f * c; i++) {
		leer.getline(fila, 80, ' ');
		tablero[i] = (int)fila[0] - 48;
	}
	leer.close();
	modoManual(tablero, f, c, d);
}

//Modo de juego manual
void modoManual(int *tablero, int filas, int columnas, int dificultad) {
	system("cls");
	cudaError_t cudaStatus;
	int fila = 1, columna = 1;
	while (fila != 0 || columna != 0) {
		system("cls");
		imprimirTablero(tablero, filas, columnas);
		cout << "Introduce la fila en la que esta la ficha que deseas eliminar (0 para salir): \n";
		cin >> fila;
		while (fila < 0 && fila > filas) {
			cout << "Numero de fila no valido, introduzca uno en rango 1 - " << filas << ":\n";
			cin >> fila;
		}
		cout << "Introduce la columna en la que esta la ficha que deseas eliminar (0 para salir): \n";
		cin >> columna;
		while (columna < 0 && columna > columnas) {
			cout << "Numero de columna no valido, introduzca uno en rango 1 - " << columnas << ":\n";
			cin >> columna;
		}
		//Aqui empieza la fiesta con CUDA. 
		int *tablero_gpu;
		//Reservamos memoria y copiamos el tablero en la GPU
		cudaMalloc((void**)&tablero_gpu, (filas * columnas) * sizeof(int));
		cudaMemcpy(tablero_gpu, tablero, (filas * columnas) * sizeof(int), cudaMemcpyHostToDevice);
		int mayor = 0;
		if (filas > columnas) {
			mayor = filas;
		}
		else {
			mayor = columnas;
		}
		cudaDeviceProp deviceProp;
		cudaGetDeviceProperties(&deviceProp, 0);
		int TILE_WIDTH = (int)sqrt((float)deviceProp.maxThreadsPerBlock);
		int nbloques = (mayor + TILE_WIDTH - 1) / TILE_WIDTH;
		dim3 DimGrid(nbloques, nbloques);
		dim3 DimBlock(TILE_WIDTH, TILE_WIDTH);
		ToyBlastManual << < DimGrid, DimBlock >> > (tablero_gpu, filas, columnas, columna - 1, fila - 1, (rand() % 3) + 7);
		cudaStatus = cudaGetLastError();
		if (cudaStatus == cudaSuccess) {
			cudaMemcpy(tablero, tablero_gpu, sizeof(int)* filas * columnas, cudaMemcpyDeviceToHost);
			rellenarTablero(tablero, filas, columnas, dificultad);
			cudaFree(tablero_gpu);
		}
		else {
			fprintf(stderr, "Fallo en kernel\n");
			break;
		}
	}
	if (cudaStatus == cudaSuccess) {
		system("cls");
		cout << "Deseas guardar la partida? (s/n)\n";
		char guardar = 'a';
		cin >> guardar;
		while (guardar != 's' && guardar != 'n') {
			system("cls");
			cout << "Valor no valido, quieres guardar la partida? (s/n): \n";
			cin >> guardar;
		}
		if (guardar == 's') {
			guardarPartida(tablero, filas, columnas, dificultad);
		}
		else {
			cout << "Saliendo sin guardar...\n \n";
		}
	}
	else {
		system("pause");
	}
}