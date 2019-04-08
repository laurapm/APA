
import scala.util.Random
import java.io.File;
import java.io.FileWriter;

object juego2048 {
  
  /*****TABLERO******/
  def main(args: Array[String]){
    println("------------ 1 6 3 8 4 ------------ ")
    println (" Este juego consiste en una versión del famoso 2048")
    println ("Para empezar a jugar, seleccione un nivel: ")
    println ("1.- FACIL \n2.- MEDIO \n3.- DIFICIL \n4.- EXPERTO")
    
    val dificultad = readInt()
    val tablero = tamTablero(dificultad)
    val filas = tablero._1
    val columnas = tablero._2
    val tableroVacio = List()
//(tablero:List[Int], filas:Int, columnas:Int, dificultad:Int)
    dificultad match{
     case 1=>jugar(crearTablero(filas*columnas),filas,columnas,dificultad)
     case 2=>jugar(crearTablero(filas*columnas),filas,columnas,dificultad)
     case 3=>jugar(crearTablero(filas*columnas),filas,columnas,dificultad)
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
  
  def crearTablero(tam:Int):List[Int] = {
     if (tam==0) return 0::Nil
     else
       return 0::crearTablero(tam-1)
  }
  //Metodo para generar el tablero en base a una matriz
  def generarSemillas(tablero:List[Int], dificultad:Int, tam:Int, posicion:Int):List[Int]= dificultad match{
    case 1 => {
      //val posicion = Random.nextInt(tam+1)
      if (tablero == Nil) return tablero
      else{
        if (tablero.head == posicion) {
          return 2::tablero.tail
        }
        else{
          return tablero.head::generarSemillas(tablero.tail, dificultad, tam, posicion)
        }
      }
    }
  /*  case 2 => {
      val valores = 2* (Random.nextInt(2)+1) //valores 2,4
    }*/
  }
  
//  def generarSemillas(tablero:List[Int], tam:Int, dificultad:Int, semillas: Int):List[Int]= {
  //  val aux = random.nextInt(tam+1)
    //if (dificultad ==1){
      
    //}
  //}
    
  def imprimir_cabeceras(dificultad:Int)= dificultad match{
    case 1 => {
      println("	1	2	3	4")
      println("	|	|	|	|")
    }
    case 2 =>{
      println("	1	2		3		4		5		6		7		8		9")
      println("	|	|		|		|		|		|		|		|		|")
    }
    case 3 =>{
      println("	1	2		3		4		5		6		7		8		9		10	11	12	13	14")
      println("	|	|		|		|		|		|		|		|		|		 |	 |	 |	 |	 |")
    }
    case 4 =>{
      println("	1	2		3		4		5		6		7		8		9		10	11	12	13	14	15	16	17")
      println("	|	|		|		|		|		|		|		|		|		 |	 |	 |	 |	 |	 |   |   |")
    }
  }
  
  def imprimir_tablero(filas:Int, fil:Int, columnas:Int, col:Int, dificultad:Int, tablero:List[Int]): Unit= {
    if(tablero==Nil) println("")
    else if (col == 0){
      if(fil ==0){
        imprimir_cabeceras(dificultad)
        imprimir_tablero(filas, fil+1, columnas, col, dificultad, tablero.tail)
      }
      else {
            if(fil<=filas && fil!=0){
              printf((fil) + "---" + dar_color (tablero.head)) 
              println("")
              imprimir_tablero(filas, fil+1, columnas, col, dificultad, tablero.tail)
            }
      }
    }
    else if (col < columnas) imprimir_tablero(filas, fil+1, columnas, col+1, dificultad, tablero.tail)
    else{
      println("") 
      println(imprimir_tablero(filas, fil+1, columnas, 0, dificultad, tablero.tail))
    }
  }
  
 def dar_color(valores:Int):String ={
   if (valores == 2) return "A"
   else if (valores == 4) return "R"
   else if (valores == 8) return "N"
   else return "*"
 }
 
 def colorear(dificultad:Int):Int={
      if(dificultad==1) return 4
      else if(dificultad==2) return 5
      else  return 6
        
  }
  
  
  def jugar(tablero:List[Int], filas:Int, columnas:Int, dificultad:Int) = dificultad match{
    case 1 => imprimir_tablero(filas,0,columnas,0, dificultad, tablero)
  }
}
  

