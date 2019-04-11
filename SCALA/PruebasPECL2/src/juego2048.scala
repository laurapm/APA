
import scala.util.Random
import java.io.File;
import java.io.FileWriter;

object juego2048 {
  
def main(args: Array[String]){
    println("------------ 1 6 3 8 4 ------------ ")
    println (" Este juego consiste en una versión del famoso 2048")
    println ("Para empezar a jugar, seleccione un nivel: ")
    println ("1.- FÁCIL \n2.- MEDIO \n3.- DIFÍCIL \n4.- EXPERTO")
    printf (">> ")
    
    val dificultad = readInt()
    val tablero = tamTablero(dificultad)
    val filas = tablero._1
    val columnas = tablero._2
    val tableroVacio = List()
//(tablero:List[Int], filas:Int, columnas:Int, dificultad:Int)
    dificultad match{
     case 1=>jugar2(crearTablero(filas*columnas),filas,columnas,dificultad, false, 2)
     case 2=>jugar2(crearTablero(filas*columnas),filas,columnas,dificultad, false, 4)
     case 3=>jugar2(crearTablero(filas*columnas),filas,columnas,dificultad, false, 6)
     case 4=>jugar2(crearTablero(filas*columnas),filas,columnas,dificultad, false, 6)
     case _ => println("Dificultad no válida")
    }  
  }

                                            /*****TABLERO******/
  //función encargada de asingar unas dimensiones al tablero
  //en función de la dificultad elegida
  
  def tamTablero(dificultad:Int): (Int, Int) = dificultad match {
    case 1 =>  (4,4)
    case 2 =>  (9,9)
    case 3 =>  (14,14)
    case 4 =>  (17,17)
    //case default => println("La dificultad seleccionada no es válida")
  }
  //función ecaragada de crear un tablero vacío en función de la 
  //dificultad indicada
  def crearTablero(tam:Int):List[Int] = {
     if (tam == 0)  Nil
     else
        0::crearTablero(tam-1)
  }
  
  //Método que genera una semilla y la introduce en el tablero
  /*def generarSemillas(tablero:List[Int], dificultad:Int, posicion:Int):List[Int]= dificultad match{
    case 1 => {
      //val posicion = Random.nextInt(tam+1)
      if (tablero == Nil)  tablero
      else{
        if (posicion == 0 ) {
           2::tablero.tail
        }
        else{
           tablero.head::generarSemillas(tablero, dificultad, posicion-1)
        }
      }
    }
  case 2 => {
      val valores = 2* (Random.nextInt(2)+1) //valores 2,4
      if (tablero == Nil) tablero
      else{
        if (posicion==0)
          valores::generarSemillas(tablero.tail, dificultad, posicion)
        else
          tablero.head::generarSemillas(tablero, dificultad, posicion-1)
      }
    }
  }*/
  
  def generarSemillas(tablero:List[Int], columnas:Int, posicion:Int, dificultad:Int, numSemillas:Int):List[Int]= {
    
    val valor = 2 * (Random.nextInt(dificultad)+1)
    if(numSemillas>1){
      if (tablero == Nil)  tablero
      else{
        if (posicion == 0) {
          if (tablero.head==0) valor:: generarSemillas(tablero.tail, columnas, Random.nextInt(columnas*columnas+1), dificultad, numSemillas-1)
          else generarSemillas(tablero, columnas, Random.nextInt(columnas*columnas+1), dificultad, numSemillas)
        }
        else{
           tablero.head::generarSemillas(tablero, columnas, posicion-1, dificultad, numSemillas)
        }
      }
    }
    else{
      if (tablero == Nil)  tablero
      else{
        if (posicion == 0) {
          if (tablero.head==0) valor:: tablero.tail
          else generarSemillas(tablero, columnas, Random.nextInt(columnas*columnas+1), dificultad, numSemillas)
        }
        else{
           tablero.head::generarSemillas(tablero, columnas, posicion-1, dificultad, numSemillas)
        }
      }
    }
  }
  
//  def generarSemillas(tablero:List[Int], tam:Int, dificultad:Int, semillas: Int):List[Int]= {
  //  val aux = random.nextInt(tam+1)
    //if (dificultad ==1){
      
    //}
  //}
    
  //Método para imprimir el número de las columnas 
  //con la finalidad de agilizar el testeo de datos
  
  
                                            /**IMPRIMIR EL TABLERO ****/
  def imprimir_cabeceras(dificultad:Int)= dificultad match{
    case 1 => {
      println("	1	2	3	4")
      println("	|	|	|	|")
    }
    case 2 =>{
      println("	1	2	3	4	5	6	7	8	9")
      println("	|	|	|	|	|	|	|	|	|")
    }
    case 3 =>{
      println("	1	2	3	4	5	6	7	8	9	1	2	3	4")
      println("	|	|	|	|	|	|	|	|	|	|	|	|	|")
    }
    case 4 =>{
      println("	1	2	3	4	5	6	7	8	9	1	2	3	4	5	6	7")
      println("	|	|	|	|	|	|	|	|	|	|	|	|	|	|	|	|")
    }
  }
  
  def imprimir_tablero(filas:Int, fil:Int, columnas:Int, col:Int, dificultad:Int, tablero:List[Int]): Unit= {
    
    if(tablero == Nil) println("")
    else if(fil == 0){
      
      imprimir_cabeceras(dificultad)
      imprimir_tablero(filas, fil+1, columnas, col, dificultad, tablero)
      
    }
    else{
      
      if(col == 0){  //Caso primera columna
        
        if(fil <= filas && fil!= 0){
              printf((fil) + "---|   " + tablero.head + "   |")
              imprimir_tablero(filas, fil, columnas, col+1, dificultad, tablero.tail)
        }
        
      }
      else if(col == columnas-1){ //Caso última columna
        
        println("   " + tablero.head + "   |")
        imprimir_tablero(filas, fil+1, columnas, 0, dificultad, tablero.tail)
        
      }
      else{  //Resto de casos
        
        printf("   " + tablero.head + "   |")
        imprimir_tablero(filas, fil, columnas, col+1, dificultad, tablero.tail)
        
      }
      
    }
    
  }
  
 def dar_color(valores:Int):String ={
   if (valores == 2)  "A"
   else if (valores == 4)  "R"
   else if (valores == 8)  "N"
   else  "*"
 }
 
 def colorear(dificultad:Int):Int={
      if(dificultad == 1)  4
      else if(dificultad == 2)  5
      else   6
        
  }
 
                              /*MOVIMIENTOS DEL JUEGO*/
def moverGen(tablero: List[Int], columnas: Int, posicion: Int):List[Int] ={
  
  val m1 = moverDer(tablero, columnas, 0)
  val sum = sumar(m1, columnas, 0)
  val m2 = moverDer(sum, columnas, 0)
  m2
  
}
 
 def moverDer (tablero: List[Int], columnas:Int, posicion:Int):List[Int] = {
   if (tablero==Nil)  Nil
   else  moverDerAux(cogerN(columnas,tablero), columnas, posicion):::moverDer(quitar(columnas,tablero), columnas, posicion)
 }
  
def moverDerAux(tablero: List[Int], columnas: Int, posicion: Int):List[Int] ={
   if(tablero.tail == Nil) return tablero
   else if((posicion+1) % columnas == 0){
      tablero.head :: moverDer(tablero.tail, columnas, posicion+1)
   }
   else if(tablero.head != 0 ){
     if (tablero.tail.head == 0){
       val aux = tablero.head :: tablero.tail.tail
       return 0 :: moverDerAux(aux, columnas, posicion+1)
     }
     else{
       if (tablero.reverse.head ==0) return 0::moverDerAux((tablero.reverse.tail).reverse, columnas, posicion+1)
       else  tablero.head::moverDerAux(tablero.tail, columnas, posicion+1)
     } 
   }
   else{
      tablero.head :: moverDerAux(tablero.tail, columnas, posicion+1)
   }
 }

def sumar(tablero: List[Int], columnas: Int, posicion: Int): List[Int]={
  if(tablero.tail == Nil)  tablero
  else if((posicion+1) % columnas == 0){
      tablero.head :: sumar(tablero.tail, columnas, posicion+1)
  }
  else{
    if(tablero.head != 0 && tablero.tail.head == tablero.head){
      val sum = tablero.head * 2
      val tab = sum :: tablero.tail.tail
      if(tab.tail == Nil)  0::tab
      else{
        if(tab.head == tab.tail.head)  0::tab.head::sumar(tab.tail, columnas, posicion+2)
        else  0 :: sumar(tab, columnas, posicion+1)
      }
    }
    else return tablero.head :: sumar(tablero.tail, columnas, posicion+1)
  }
} 
def moverIzq(tablero: List[Int], columnas: Int, posicion: Int):List[Int] ={
  
  //imprimir_tablero(columnas,0,columnas,0, 1, tablero.reverse)
  val aux = moverGen(tablero.reverse, columnas, 0)
  //imprimir_tablero(columnas,0,columnas,0, 1, aux)
  //imprimir_tablero(columnas,0,columnas,0, 1, aux.reverse)
   aux.reverse
}

def moverAbajo(tablero: List[Int], columnas: Int, tam: Int, posicion: Int):List[Int] ={
  val tras = traspuesta(tablero, columnas, tam, posicion)
  val mov = moverDer(tras, columnas, posicion)
   traspuesta(moverGen(traspuesta(tablero, columnas, tam, posicion), columnas, posicion), columnas, tam, posicion)
  
}

def moverArriba(tablero: List[Int], columnas: Int, tam: Int, posicion: Int):List[Int] ={
  val tras = traspuesta(tablero, columnas, tam, posicion)
  val mov = moverIzq(tras, columnas, posicion)
   traspuesta(moverIzq(traspuesta(tablero, columnas, tam, posicion), columnas, posicion), columnas, tam, posicion)
  //return traspuesta(moverAbajo(traspuesta(tablero, columnas, tam, posicion), columnas, tam, posicion), columnas, tam, posicion)
    
}                       /* MÉTODOS AUXILIARES DE UN MAESTR*/
  
 def traspuesta (tablero:List[Int], columnas: Int, tam:Int, pos:Int):List[Int]={
   if (tablero == Nil)
      tablero
   else{
     if (pos>=tam)  traspuesta(tablero.tail, columnas, tam-1, 0)
     else if (tam == columnas)  Nil
     else coger(pos, tablero)::traspuesta(tablero, columnas, tam, pos+columnas)
   }
 }
 
  def cogerN(n:Int, l:List[Int]):List[Int] ={
   if (n==0)  Nil
   else{
      return l.head::cogerN(n-1, l.tail)
   }
 }
 
 def quitar(n:Int, l:List[Int]):List[Int] ={
   if (l == Nil)  Nil
   else{
     if (n==0)  l
     else quitar(n-1, l.tail)
   }
 }
 
 def coger(n:Int, tablero:List[Int]):Int={
   if (n==0)  tablero.head
   else coger(n-1, tablero.tail)
 }
 
 def mover (movimiento:Int, tablero:List[Int], columnas:Int, dificultad:Int, puntuacion:Int) = movimiento match {
   
   case 0 => Nil
   case 2 => moverAbajo(tablero, columnas, columnas*columnas, 0)
   case 4 => moverIzq(tablero, columnas,0)
   case 6 => moverGen(tablero, columnas,0)
   case 8 => moverArriba(tablero, columnas, columnas*columnas, 0)
   case _ => println ("Movimiento no válido"); tablero//jugar(tablero, columnas, columnas, dificultad)
 }
 
 def tableroLleno(tablero:List[Int]):Boolean ={
   if (tablero == Nil)  true
   else{
     if (tablero.head == 0)  false
     else tableroLleno(tablero.tail)
   }
 }
 
 def jugar2(tablero:List[Int], filas:Int, columnas:Int, dificultad:Int, malo: Boolean, semillas: Int): Unit = {
   
   /*AQUÍ VA LA PUNTUACIÓN*/
   val puntuacion = 0
   val posicion = Random.nextInt(filas*columnas+1)
   
   if(malo != true){
     
     /*AQUÍ VA EL GENERAR SEMILLAS*/
     val tablerogen = generarSemillas(tablero, dificultad, posicion, dificultad, semillas)
     imprimir_tablero(filas, 0, columnas, 0, dificultad, tablerogen)
     println("Ingresa el movimiento que deseas hacer ( ↑ = 8, → = 6, ↓ = 2, ← = 4, salir = 0 )")
     printf(">> ")
     val movimiento = readInt()
     val tab = mover(movimiento, tablerogen, columnas, dificultad, puntuacion)
     if(tab == Nil || tableroLleno(tab)) println("Juego finalizado. ¡Gracias por jugar!")
     else if(tab == tablero){
       
       if(dificultad == 4) jugar2(tab, filas, columnas, dificultad, true, semillas)
       else jugar2(tab, filas, columnas, dificultad, true, semillas-1)
     }
     else jugar2(tab, filas, columnas, dificultad, false, semillas)
     
   }
   else{
     
     println("Ingresa el movimiento que deseas hacer ( ↑ = 8, → = 6, ↓ = 2, ← = 4, salir = 0 )")
     printf(">> ")
     val movimiento = readInt()
     val tab = mover(movimiento, tablero, columnas, dificultad, puntuacion)
     if(tab == Nil || tableroLleno(tab)) println("Juego finalizado. ¡Gracias por jugar!")
     else if(tab == tablero){
       
       if(dificultad == 4) jugar2(tab, filas, columnas, dificultad, true, semillas)
       else jugar2(tab, filas, columnas, dificultad, true, semillas-1)
     }
     else jugar2(tab, filas, columnas, dificultad, false, semillas)
   }
   
 }
/*
  def jugar(tablero:List[Int], filas:Int, columnas:Int, dificultad:Int) = {
      //val tablerogen = List(4,2,0,2,4,2,0,2,4,2,0,2,4,2,0,2)
      //val tablerogen = List(4,4,4,4,2,2,2,2,8,8,8,8,0,0,0,0)
     //val tablerogen = List(4,2,4,0,2,8,4,2,2,4,8,0,2,0,4,2)
    //val puntuacion = calcularPuntos(tablero, columnas)
    //println("Puntuacion : ")
    //print(puntuacion)
      val tablerogen = generarSemillas(tablero, dificultad, 0)
      imprimir_tablero(filas,0,columnas,0, dificultad, tablerogen)
      if (tablerogen != Nil && tableroLleno(tablerogen)==false){
        //val movimiento = readInt()
        //jugar(mover(movimiento,tablerogen, columnas, dificultad), filas, columnas, dificultad)
        
        println (tableroLleno(tablerogen))
        println(cogerN(columnas,tablerogen))
        println("Mover derecha")
        imprimir_tablero(filas, 0, columnas, 0, dificultad, moverGen( tablerogen,columnas,0))
                
        println ("Matriz izquierda")
       imprimir_tablero(filas, 0, columnas, 0, dificultad, moverIzq(tablerogen, columnas, 0))
       
       println("Mover arriba")
       imprimir_tablero(filas, 0, columnas, 0, dificultad, moverArriba(tablerogen,columnas, filas*columnas, 0))
       
       println("Mover abajo:"  )
       imprimir_tablero(filas, 0, columnas, 0, dificultad, moverAbajo(tablerogen,columnas, filas*columnas, 0))
       }
      
  }*/
}
