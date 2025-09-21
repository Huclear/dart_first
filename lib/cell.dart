import 'side.dart';

class Cell
{
    Side? sign = null;
    int xAxis;
    int yAxis;

    Cell(this.xAxis, this.yAxis);

    @override
  bool operator ==(Object other) {
    if(identical(this, other)) return true;
    if(other.runtimeType != this.runtimeType) return false;

    final Cell otherCell = other as Cell;
    return otherCell.xAxis == this.xAxis && otherCell.yAxis == this.yAxis;
  }

  @override
  String toString() {
    return "$xAxis:$yAxis";
  }
}