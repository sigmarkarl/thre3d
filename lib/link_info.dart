import 'dart:collection';

class LinkInfo {
  LinkInfo(this.linkStrength, this.linkOffset);

  double getStrength() {
    return linkStrength;
  }

  double getOffset() {
    return linkOffset;
  }

  Set<String> linkTitles = HashSet<String>();
  double linkStrength;
  double linkOffset;
}
