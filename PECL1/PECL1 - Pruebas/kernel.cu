#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <conio.h>
#include <time.h>
#include <stdio.h>
#include <fstream>
#include <windows.h>

using namespace std;

void generarTablero(int *tablero, int filas, int columnas);
void imprimirTablero(int *tablero, int filas, int columnas);
void imprimirColumnas(int columnas);
void generarSemillas(int *tablero, int filas, int columnas);

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

	//Reservamos la memoria del tablero y lo inicializamos con generar tablero
	tablero = new int[filas * columnas];
	generarTablero(tablero, filas, columnas);
	imprimirTablero(tablero, filas, columnas);

    
	system("PAUSE");
}

//Generar tablero con números aleatorios
void generarTablero(int *tablero, int filas, int columnas){
	srand(time(0));
	int tamaño = filas * columnas;
	for (int i = 0; i < tamaño; i++){
		tablero[i] = 0;
	}
	generarSemillas(tablero, filas, columnas);
}

//Genera los números para jugar en el tablero
void generarSemillas(int *tablero, int filas, int columnas){
	int tamaño = filas * columnas;
	int contador = 3;
	while (contador > 0){
		int aux = rand() % 3;
		int i = rand() % tamaño + 1;
		cout << "POSICION: " << i;
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
			contador--;
		}
	}
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
				default:
					SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7); //Gris
			}
			cout << "| " << bloque << " |";
		}
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
		cout << "\n";
	}
}