 object movimientos{
def moverGen(tablero: List[Int], columnas: Int, posicion: Int):List[Int] ={
  
  val m1 = moverDer(tablero, columnas, 0)
  val sum = sumar(m1, columnas, 0)
  val m2 = moverDer(sum, columnas, 0)
  return m2
  
}
 
 def moverDer (tablero: List[Int], columnas:Int, posicion:Int):List[Int] = {
   if (tablero==Nil) return Nil
   else return moverDerAux(cogerN(columnas,tablero), columnas, posicion):::moverDer(quitar(columnas,tablero), columnas, posicion)
 }
  
def moverDerAux(tablero: List[Int], columnas: Int, posicion: Int):List[Int] ={
   if(tablero.tail == Nil) return tablero
   else if((posicion+1) % columnas == 0){
     
     return tablero.head :: moverDer(tablero.tail, columnas, posicion+1)
     
   }
   else if(tablero.head != 0 ){
     if (tablero.tail.head == 0){
       val aux = tablero.head :: tablero.tail.tail
       return 0 :: moverDerAux(aux, columnas, posicion+1)
     }
     else{
       if (tablero.reverse.head ==0) return 0::moverDerAux((tablero.reverse.tail).reverse, columnas, posicion+1)
       else return tablero.head::moverDerAux(tablero.tail, columnas, posicion+1)
     } 
   }
   else{
     
     return tablero.head :: moverDerAux(tablero.tail, columnas, posicion+1)
     
   }
 }

def sumar(tablero: List[Int], columnas: Int, posicion: Int): List[Int]={
  if(tablero.tail == Nil) return tablero
  else if((posicion+1) % columnas == 0){
     return tablero.head :: sumar(tablero.tail, columnas, posicion+1)
  }
  else{
    if(tablero.head != 0 && tablero.tail.head == tablero.head){
      val sum = tablero.head * 2
      val tab = sum :: tablero.tail.tail
      if(tab.tail == Nil) return 0::tab
      else{
        if(tab.head == tab.tail.head) return 0::tab.head::sumar(tab.tail, columnas, posicion+2)
        else return 0 :: sumar(tab, columnas, posicion+1)
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
  return aux.reverse
}

def moverAbajo(tablero: List[Int], columnas: Int, tam: Int, posicion: Int):List[Int] ={
  val tras = traspuesta(tablero, columnas, tam, posicion)
  val mov = moverDer(tras, columnas, posicion)
  return traspuesta(moverGen(traspuesta(tablero, columnas, tam, posicion), columnas, posicion), columnas, tam, posicion)
  
}

def moverArriba(tablero: List[Int], columnas: Int, tam: Int, posicion: Int):List[Int] ={
  val tras = traspuesta(tablero, columnas, tam, posicion)
  val mov = moverIzq(tras, columnas, posicion)
  return traspuesta(moverIzq(traspuesta(tablero, columnas, tam, posicion), columnas, posicion), columnas, tam, posicion)
  //return traspuesta(moverAbajo(traspuesta(tablero, columnas, tam, posicion), columnas, tam, posicion), columnas, tam, posicion)
    
}

/* ANTIGUO MÉTODO PARA MOVER A LA DERECHA
 * def moverDer2(tablero: List[Int],  columnas: Int, posicion: Int):List[Int] ={
   
   if(tablero == Nil) return Nil
   else if((posicion+1) % columnas == 0){
     return tablero.head :: moverDer2(tablero.tail, columnas, posicion+1)
   }
   else if(tablero.head != 0 && tablero.tail.head == 0){
     
     val aux = (tablero.head::tablero.tail.tail)
     val tab2 = 0 :: moverDer2(aux, columnas, posicion+1)
     return moverDer2(tab2,  columnas, posicion)
     
   }
   else if(tablero.head != 0 && tablero.tail.head == tablero.head){
     
     val num = tablero.head * 2
     val tab2 =  0 :: moverDer2(num::tablero.tail.tail, columnas, posicion+1)
     return moverDer2(tab2, columnas, posicion)
   
   }
   else return tablero.head :: moverDer2(tablero.tail,columnas, posicion+1)
   
 }*/


                               /* MÉTODOS AUXILIARES DE UN MAESTR*/
  
 def traspuesta (tablero:List[Int], columnas: Int, tam:Int, pos:Int):List[Int]={
   if (tablero == Nil)
     return tablero
   else{
     if (pos>=tam) return traspuesta(tablero.tail, columnas, tam-1, 0)
     else if (tam == columnas) return Nil
     else coger(pos, tablero)::traspuesta(tablero, columnas, tam, pos+columnas)
   }
 }
 
  def cogerN(n:Int, l:List[Int]):List[Int] ={
   if (n==0) return Nil
   else{
      return l.head::cogerN(n-1, l.tail)
   }
 }
 
 def quitar(n:Int, l:List[Int]):List[Int] ={
   if (l == Nil) return Nil
   else{
     if (n==0) return l
     else quitar(n-1, l.tail)
   }
 }
 
 def coger(n:Int, tablero:List[Int]):Int={
   if (n==0) return tablero.head
   else coger(n-1, tablero.tail)
 }
 
 def mover (movimiento:Int, tablero:List[Int], columnas:Int, dificultad:Int) = movimiento match {
   case 2 => moverAbajo(tablero, columnas, columnas*columnas, 0)
   case 4 => moverIzq(tablero, columnas,0)
   case 6 => moverGen(tablero, columnas,0)
   case 8 => moverArriba(tablero, columnas, columnas*columnas, 0)
   case _ => println ("Movimiento no válido")
   }
 }