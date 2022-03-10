import 'corp.dart';

class Entity {
  Entity(this.id, this.country, this.x, this.y, this.z) {
    selected = false;
  }

  void setCorp(Corp c) {
    corp = c;
  }

  String country;
  String id;
  double x, y, z;
  late bool selected;
  Corp? corp;
}
