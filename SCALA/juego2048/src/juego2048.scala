
import scala.util.Random
import java.io.File;
import java.io.FileWriter;

object juego2048 {
  
  /*****TABLERO******/
  def main(args: Array[String]){
    println("------------ 1 6 3 8 4 ------------ ")
    println (" Este juego consiste en una versión del famoso 2048")
    println ("Para empezar a jugar, seleccione un nivel: ")
    println ("1.- FACIL \n 2.- MEDIO \n 3.- DIFICIL \n 4.- EXPERTO")
    
    val dificultad = readInt()
    val tablero = tamTablero(dificultad)
    val filas = tablero._1
    val columnas = tablero._2
    val tableroVacio = List()
//(tablero:List[Int], filas:Int, columnas:Int, dificultad:Int)
    dificultad match{
     case 1=>jugar(generarTablero(tableroVacio,filas*columnas,4),filas,columnas,dificultad)
     case 2=>jugar(generarTablero(tableroVacio,filas*columnas,5),filas,columnas,dificultad)
     case 3=>jugar(generarTablero(tableroVacio,filas*columnas,6),filas,columnas,dificultad)
    }
    
  }
  
  //función encargada de asingar unas dimensiones al tablero
  //en función de la dificultad elegida
  
  def tamTablero(dificultad:Int): (Int, Int) = dificultad match {
    case 1 => return (4,4)
    case 2 => return (9,9)
    case 3 => return (14,14)
    case 4 => return (17,17)
    //case default => println("La dificultad seleccionada no es válida")
  }
  
  //Metodo para generar el tablero en base a una matriz
  def generarTablero(matriz:List[Int],tam:Int,bloques:Int):List[Int]={
    	val elem = new Random
     	if(tam-1>0){
     	  return 1+elem.nextInt(bloques)::generarTablero(matriz,tam-1,(bloques))
     	}
     	else return 1+elem.nextInt(bloques)::matriz
  }
  
//  def generarSemillas(tablero:List[Int], tam:Int, dificultad:Int, semillas: Int):List[Int]= {
  //  val aux = random.nextInt(tam+1)
    //if (dificultad ==1){
      
    //}
  //}
    
  def imprimir_cabeceras(dificultad:Int)= dificultad match{
    case 1 => {
      println("1	2	3	4")
      println("|	|	|	|")
    }
    case 2 =>{
      println("1	2		3		4		5		6		7		8		9")
      println("|	|		|		|		|		|		|		|		|")
    }
    case 3 =>{
      println("1	2		3		4		5		6		7		8		9		10	11	12	13	14")
      println("|	|		|		|		|		|		|		|		|		 |	 |	 |	 |	 |")
    }
    case 4 =>{
      println("1	2		3		4		5		6		7		8		9		10	11	12	13	14	15	16	17")
      println("|	|		|		|		|		|		|		|		|		 |	 |	 |	 |	 |	 |   |   |")
    }
  }
  
  def imprimir_tablero(filas:Int, fil:Int, columnas:Int, col:Int, dificultad:Int, tablero:List[Int]): Unit= {
    if(tablero==Nil) println("")
    else if (col == 0){
      if(fil ==1) imprimir_cabeceras(dificultad)
      else {
            println(fil + "---") 
            imprimir_tablero(filas, fil, columnas, col+1, dificultad, tablero.tail)
      }
    }
    else if (col < columnas) imprimir_tablero(filas, fil, columnas, col+1, dificultad, tablero.tail)
    else{
      println("") 
      println(imprimir_tablero(filas, fil+1, columnas, 0, dificultad, tablero))
    }
  }
  
  def jugar(tablero:List[Int], filas:Int, columnas:Int, dificultad:Int) = dificultad match{
    case 1 => imprimir_tablero(filas,0,columnas,0, dificultad,tablero)
  }
}
  

