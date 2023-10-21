/// Support functions for tick_page.dart
/// 
/// Functions;

/// Check if item satisfies search tokens
bool checkSearchTokens(List<dynamic> data, int attributeIndex, int synonymIndex, String searchText) {
  if(checkString(data[attributeIndex], searchText)) {
    return true;
  }
  if(checkString(data[synonymIndex], searchText)) {
    return true;
  }
  return false;
}

bool checkString(dynamic testedItem, String checkString) {
  return testedItem.toString().toLowerCase().contains(checkString.toLowerCase());
}

///next function