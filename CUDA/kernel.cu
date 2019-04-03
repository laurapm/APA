#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <device_functions.h>
#include <cuda_runtime_api.h>
#include <conio.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <windows.h>

using namespace std;

//Funciones que van a utilizarse a lo largo del programa
//CPU
void generarTablero(int *tablero, int filas, int columnas, int dificultad);
void imprimirTablero(int *tablero, int filas, int columnas);
void imprimirColumnas(int columnas);
void comprobarLleno(int *tablero, int filas, int columnas, int dificultad, bool &salida);
void generarSemillas(int *tablero, int filas, int columnas, int dificultad);
void guardarPartida(int *tablero, int filas, int columnas, int dificultad);
void cargarPartida();
void modoManual(int *tablero, int filas, int columnas, int dificultad);

//GPU
__global__ void juegoManual(int *tablero, int fila, int columna, int filas, int columnas, char movimiento);
__device__ void compruebaSemillas(int *tablero, int filas, int columnas, char movimiento);
__device__ void compruebaArriba(int *tablero, int fila, int columna, int filas, int columnas, char movimiento);
__device__ void compruebaAbajo(int *tablero, int fila, int columna, int filas, int columnas, char movimiento);
__device__ void compruebaDerecha(int *tablero, int fila, int columna, int filas, int columnas, char movimiento);
__device__ void compruebaIzquierda(int *tablero, int fila, int columna, int filas, int columnas, char movimiento);
__device__ void moverCeros(int *tablero, int fila, int columna, int filas, int columnas, char movimiento);

int main(void){

	//Almacenamos las propiedades de la tarjeta para no exceder el numero de hilos posibles en el tablero
	cudaDeviceProp prop;
	cudaGetDeviceProperties(&prop, 0);

	//Propiedades del tablero
	int *tablero;
	int filas = 0;
	int columnas = 0;
	int dificultad = 0;
	char modo_juego;

	//Preguntamos si quiere cargar un juego guardado anteriormente o si quiere empezar de nuevo
	cout << "Quieres continuar una partida anterior o empezar de nuevo? (C: Cargar / N: Nueva partida)\n";
	char partida = 'X';
	cin >> partida;
	while (partida != 'C' && partida != 'N') {
		cout << "Introduce un valor valido para iniciar el juego\n";
		cin >> partida;
	}
	if (partida == 'N'){
		//Recogemos los datos de filas y columnas del tablero que vamos a usar
		cout << "Seleccione el numero de filas con las que desea jugar: \n";
		cin >> filas;
		cout << "Seleccione el numero de columnas con las que desea jugar: \n";
		cin >> columnas;

		//Tablero mínimo de 4 por 4
		while (filas < 4) {
			cout << "El numero de filas con las que desea jugar es demasiado pequeño, el minimo aceptado es 4: \n";
			cin >> filas;
		}
		while (columnas < 4) {
			cout << "El numero de columnas con las que desea jugar es demasiado pequeño, el minimo aceptado es 4: \n";
			cin >> columnas;
		}
		while (prop.maxThreadsPerBlock < (filas * columnas)) {
			cout << "Has excedido el limite de semillas posibles para el tablero, introduce las filas y las columnas de nuevo: \n";
			cout << "Seleccione el numero de filas con las que desea jugar: \n";
			cin >> filas;
			cout << "Seleccione el numero de columnas con las que desea jugar: \n";
			cin >> columnas;
		}

		cout << "Elija dificultad: \n1. Bajo, se lanzaran 15 semillas de 2, 4 y 8 \n"
			"2. Dificil, se lanzaran 8 semillas de 2 y 4 \n";
		cin >> dificultad;


		while (!(dificultad == 1 || dificultad == 2)){
			cout << "Dificultad no válida \n";
			cout << "Selecccione 1 si desea jugar con nivel o 2 si desea jugar con nivel dificil \n";
			cin >> dificultad;
		}

		cout << "Elija modo de juego: \n A. Automático \n M. Manual \n";
		cin >> modo_juego;
		while (!(modo_juego == 'M' || modo_juego == 'A')){
			cout << "Modo de juego no válido \n";
			cout << "Selecccione A para jugar en modo automático o M para manual \n";
			cin >> modo_juego;
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

//Generar tablero con números aleatorios
void generarTablero(int *tablero, int filas, int columnas, int dificultad){
	srand(time(0));
	int tamaño = filas * columnas;
	for (int i = 0; i < tamaño; i++){
		tablero[i] = 0;
	}
	generarSemillas(tablero, filas, columnas, dificultad);
}

void comprobarLleno(int *tablero, int filas, int columnas, int dificultad, bool &salida){

	int tamaño = filas * columnas;
	int contador, posicion = 0;
	if (dificultad == 1){
		contador = 15;
		while (contador > 0 && posicion < tamaño){
			if (tablero[posicion] == 0) contador--;
			posicion++;
		}
		if (contador == 0) generarSemillas(tablero, filas, columnas, dificultad);
		else{
			cout << "Juego terminado\n";
			//exit(0);
			salida = true;
		}
	}
	if (dificultad == 2){
		contador = 8;
		while (contador > 0 && posicion < tamaño){
			if (tablero[posicion] == 0) contador--;
			posicion++;
		}
		if (contador == 0) generarSemillas(tablero, filas, columnas, dificultad);
		else{
			cout << "Juego terminado\n";
			//exit(0);
			salida = true;
		}
	}

}

//Genera los números para jugar en el tablero
void generarSemillas(int *tablero, int filas, int columnas, int dificultad){
	if (dificultad == 1){
	int semillas = 0;
	int valores[3] = { 2, 4, 8 };
	while (semillas < 15){
	int posicion = rand() % (filas*columnas + 1);
	int valor = rand() % 3;
	if (tablero[posicion] == 0){
	tablero[posicion] = valores[valor];
	semillas++;
	}
	}
	}
	if (dificultad == 2){
	int semillas = 0;
	int valores[3] = { 2, 4 };
	while (semillas < 8){
	int posicion = rand() % (filas*columnas + 1);
	int valor = rand() % 2;
	if (tablero[posicion] == 0){
	tablero[posicion] = valores[valor];
	semillas++;
	}
	}
	}/*
	int tamaño = filas * columnas;
	int contador = 0;
	while (contador < 3){
		int aux = rand() % 3;
		int i = rand() % tamaño;
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
	}*/
}

//Función que imprime el número de columnas que va a tener el tablero para que sea más facil elegir semillas
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
			case 2:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 14); //Amarillo
				break;
			case 4:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 12); //Rojo
				break;
			case 8:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 13); //Morado
				break;
			case 16:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 9); //Azul
				break;
			default:
				SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7); //Blanco
			}
			if (bloque < 10) cout << "| " << bloque << " |";
			else cout << "| " << bloque << "|";
		}
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
		cout << "\n";
	}
}

//En función del movimiento, llama a la comprobación correspondiente
__device__ void compruebaSemillas(int *tablero, int fila, int columna, int filas, int columnas, char movimiento){

	switch (movimiento){
	case 'W':
		compruebaAbajo(tablero, fila, columna, filas, columnas, movimiento);
		break;
	case 'S':
		compruebaArriba(tablero, fila, columna, filas, columnas, movimiento);
		break;
	case 'D':
		compruebaIzquierda(tablero, fila, columna, filas, columnas, movimiento);
		break;
	case 'A':
		compruebaDerecha(tablero, fila, columna, filas, columnas, movimiento);
		break;
	}

}

//Desplaza los números respecto a los ceros que haya, en función del movimiento
__device__ void moverCeros(int *tablero, int fila, int columna, int filas, int columnas, char movimiento){
	if (movimiento == 'W'){
		for (int i = filas - 1; i > 0; i--){
			for (int j = i; j > 0; j--){
				if (tablero[(j * columnas) + columna] != 0 && tablero[((j - 1) * columnas) + columna] == 0){
					tablero[((j - 1) * columnas) + columna] = tablero[(j * columnas) + columna];
					tablero[(j * columnas) + columna] = 0;
				}
			}
		}
	}
	else if (movimiento == 'S'){
		for (int i = 0; i < filas - 1; i++){
			for (int j = i; j < filas - 1; j++){
				if (tablero[(j * columnas) + columna] != 0 && tablero[((j + 1) * columnas) + columna] == 0){
					tablero[((j + 1) * columnas) + columna] = tablero[(j * columnas) + columna];
					tablero[(j * columnas) + columna] = 0;
				}
			}
		}
	}
	else if (movimiento == 'D'){
		for (int i = 0; i < columnas - 1; i++){
			for (int j = i; j < columnas - 1; j++){
				if (tablero[fila * columnas + j] != 0 && tablero[fila * columnas + (j + 1)] == 0 && tablero[fila * columnas + (j + 1)] != columnas){
					tablero[fila * columnas + (j + 1)] = tablero[fila * columnas + j];
					tablero[fila * columnas + j] = 0;
				}
			}
		}
	}

	else if (movimiento == 'A'){
		for (int i = columnas - 1; i > 0; i--){
			for (int j = i; j > 0; j--){
				if (tablero[fila * columnas + j] != 0 && tablero[fila * columnas + (j - 1)] == 0){
					tablero[fila * columnas + (j - 1)] = tablero[fila * columnas + j];
					tablero[fila * columnas + j] = 0;
				}
			}
		}
	}
}

//Comprueba hacia arriba
__device__ void compruebaArriba(int *tablero, int fila, int columna, int filas, int columnas, char movimiento){

	moverCeros(tablero, fila, columna, filas, columnas, movimiento);
	if (tablero[(fila * columnas) + columna] != 0 && tablero[(fila * columnas) + columna] == tablero[((fila - 1) * columnas) + columna]){
		tablero[(fila * columnas) + columna] = tablero[(fila * columnas) + columna] * 2;
		tablero[((fila - 1) * columnas) + columna] = 0;
		moverCeros(tablero, fila, columna, filas, columnas, movimiento);
	}
}

//Comprueba hacia abajo
__device__ void compruebaAbajo(int *tablero, int fila, int columna, int filas, int columnas, char movimiento){

	moverCeros(tablero, fila, columna, filas, columnas, movimiento);
	if (tablero[(fila * columnas) + columna] != 0 && tablero[(fila * columnas) + columna] == tablero[((fila + 1) * columnas) + columna]){
		tablero[(fila * columnas) + columna] = tablero[(fila * columnas) + columna] * 2;
		tablero[((fila + 1) * columnas) + columna] = 0;
		moverCeros(tablero, fila, columna, filas, columnas, movimiento);
	}

}

//Comprueba hacia la derecha
__device__ void compruebaDerecha(int *tablero, int fila, int columna, int filas, int columnas, char movimiento){

	moverCeros(tablero, fila, columna, filas, columnas, movimiento);
	if (tablero[(fila * columnas) + columna] != 0 && tablero[(fila * columnas) + columna] == tablero[(fila * columnas) + (columna + 1)]){
		tablero[(fila * columnas) + columna] = tablero[(fila * columnas) + columna] * 2;
		tablero[(fila * columnas) + (columna + 1)] = 0;
		moverCeros(tablero, fila, columna, filas, columnas, movimiento);
	}

}

//Comprueba hacia la izquierda
__device__ void compruebaIzquierda(int *tablero, int fila, int columna, int filas, int columnas, char movimiento){

	moverCeros(tablero, fila, columna, filas, columnas, movimiento);
	if (tablero[(fila * columnas) + columna] != 0 && tablero[(fila * columnas) + columna] == tablero[(fila * columnas) + (columna - 1)]){
		tablero[(fila * columnas) + columna] = tablero[(fila * columnas) + columna] * 2;
		tablero[(fila * columnas) + (columna - 1)] = 0;
		moverCeros(tablero, fila, columna, filas, columnas, movimiento);
	}

}

__global__ void juegoManual(int *tablero, int filas, int columnas, char movimiento){

	//Guardamos la columna y la fila del hilo
	int columnaHilo = threadIdx.x;
	int filaHilo = threadIdx.y;

	compruebaSemillas(tablero, filaHilo, columnaHilo, filas, columnas, movimiento);

	__syncthreads();

}

//Guarda la partida con el tablero, las filas, las columnas y la dificultad
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

//Carga la partida guardada
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

void modoManual(int *tablero, int filas, int columnas, int dificultad){

	//system("cls");
	char movimiento = ' ';
	bool salida = false;
	while (movimiento != 'Z' && salida == false){
		imprimirTablero(tablero, filas, columnas);
		cout << "Pulsa W, A, S o D para mover los numeros (Z para salir): \n";
		cin >> movimiento;
		//while (movimiento != (ARRIBA || ABAJO || IZQUIERDA || DERECHA)) {
		while (movimiento != 'W' && movimiento != 'S' && movimiento != 'A' && movimiento != 'D' && movimiento != 'Z') {
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
		comprobarLleno(tablero, filas, columnas, dificultad, salida);
		cudaFree(tablero_gpu);

	}
	//system("cls");
	cout << "Deseas guardar la partida? (S/N)\n";
	char guardar = 'x';
	cin >> guardar;
	while (guardar != 'S' && guardar != 'N') {
		system("cls");
		cout << "Valor no valido, quieres guardar la partida? (S/N): \n";
		cin >> guardar;
	}
	if (guardar == 'S') {
		guardarPartida(tablero, filas, columnas, dificultad);
	}
	else {
		cout << "Saliendo sin guardar...\n \n";
	}
}