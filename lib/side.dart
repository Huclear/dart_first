enum Side
{
    crosses,
    zeroes;

    @override
    String toString(){
      if(this == Side.crosses){
        return "X";
      }
        else {
          return "O";
        }
    }
}