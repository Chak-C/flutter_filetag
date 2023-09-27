class CustomObject {
  List<dynamic> items = [];
  String sectionName;
  String description;

  CustomObject({required this.sectionName, required this.description});

  String checkValid(List<dynamic> destinations) {
    if(sectionName.isEmpty) return 'Empty';
    if(existsIn(destinations)) return 'Exists';
    return 'Valid';
  }

  bool existsIn(List<dynamic> destinations) {
    return destinations.any((element) => element.toString() == sectionName);
  }

  void addItem(var item) {
    items.insert(0, item);
  }

  void removeRecentItem() {
    items.isNotEmpty ? items.removeAt(0) : null;
  }

  //long press
  void removeItem(var item) {
    items.remove(item);
  }

  void resetItem() {
    items = [];
  }

  @override
  String toString() {
    return sectionName;
  }
}

