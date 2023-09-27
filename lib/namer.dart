import 'package:collection/collection.dart';

String generateCode(Map<int, AttributeObject> attributeMap, List<AttributeObject> included, List<String> sectionOrder) {
  // order included so their ID's are in ascending order
  List<AttributeObject> orderedIncluded = sortIncluded(attributeMap, included);

  // group each attribute object by their sections and store them in a list where the lists follow the sectin order provided
  List<List<AttributeObject>> groupedOrderedInc = bySection(orderedIncluded, sectionOrder);

  // construct code using format and ordered & grouped attribute objects
  String code = '';
  for(int i = 0; i < groupedOrderedInc.length; i++) {
    if(i!=0 && groupedOrderedInc[i][0].section != 'Safe') { code += '$i'; }

    for(AttributeObject attr in groupedOrderedInc[i]) { code += attr.format; }
  }
  return code;
}

List<AttributeObject> sortIncluded(Map<int,AttributeObject> idMap, List<AttributeObject> included) {
  List<AttributeObject> entries = included.where((e) => idMap.containsValue(e)).toList();
  List<AttributeObject> excluded = included.where((e) => !idMap.containsValue(e)).toList();

  int compareObjects(AttributeObject a, AttributeObject b) {
    final int aId = idMap.keys.firstWhere((key) => idMap[key] == a);
    final int bId = idMap.keys.firstWhere((key) => idMap[key] == b);
    return aId.compareTo(bId);
  }

  entries.sort(compareObjects);
  
  return entries + excluded;
}

List<List<AttributeObject>> bySection(List<AttributeObject> sortedIncluded, List<String> sectionOrder) {
  final groupedSection = groupBy(sortedIncluded, (p0) => p0.section);

  //exclude sections that are not ticked
  final sortedGroups = sectionOrder.where((element) => groupedSection.containsKey(element));

  return sortedGroups.map((e) => groupedSection[e]!).toList();
}

class AttributeObject {
  final dynamic section;
  final dynamic attribute;
  final dynamic format;

  const AttributeObject({required this.section, required this.attribute, required this.format});

  @override
  bool operator ==(Object other) {
    if(identical(this, other))  return true;
    return other is AttributeObject && other.section == section && other.attribute == attribute;
  }

  @override
  String toString() {
    return '$section: $attribute';
  }
  
  @override
  int get hashCode {
    return section.hashCode ^ attribute.hashCode;
  }
}