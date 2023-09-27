import 'package:foldtag/namer.dart';

LoadedCSV testcsv = _testSetup();

// testing env

void main() {
  _testSetup();
}


class LoadedCSV extends Iterable {
  List<List<dynamic>> currentCSV;

  LoadedCSV({
    required this.currentCSV
  });

  /// Using an index indicating where navigation bar items are located in the csv, retrieve the unique items from the matrix.
  List<dynamic> getNavigationIdentifiers(int ind) {
    List<List<dynamic>> tran = transpose();

    try {
      dynamic navCol = currentCSV[0][ind];
      
      Set navValue = Set.from(tran[ind]);
      navValue.remove(navCol);
      return navValue.toList();
    } catch(e) {
      return [];
    }
  }

  /// Takes in a matrix object and transposes it.
  List<List<dynamic>> transpose() {
    if (currentCSV.isEmpty) {
      return [];
    }

    int numRows = currentCSV.length;
    int numCols = currentCSV[0].length;

    List<List<dynamic>> result = List.generate(numCols, (colIndex) {
      return List.generate(numRows, (rowIndex) {
        return currentCSV[rowIndex][colIndex];
      });
    });

    return result;
  }

  /// Convert specified column into list form, separator is defaulted ',' unless further specified.
  /// 
  /// Used for synonyms
  void convertColumnToList(int columnIndex, String? separator) {
    separator = separator ?? ',';

    for(int i = 1; i < currentCSV.length; i++) {
      String temp = currentCSV[i][columnIndex].toString();
      if(temp != '') {
        currentCSV[i][columnIndex] = temp.split(',').map((item) => item.trim()).toList();
      } else {
        currentCSV[i][columnIndex] = <String>[];
      }
    }
  }

  /// Used to check if selected columns are valid for their corresponding roles. If selections 
  /// are valid then it will set the indexes for the LoadedCSV object. 
  /// 
  /// 0: ID selection, 1: Category selection, 2: Attribute selection, 3: Synonym selection (nullable), 4: Description (nullable), 5: Code selection
  List<String> confirmValidColumnSelection(List<int?> selectedColumns) {
    List<String> errors = List.generate(6, (index) => '');

    int? id = selectedColumns[0];
    int? category = selectedColumns[1];
    int? attribute = selectedColumns[2];
    int? code = selectedColumns[5];

    if(id == null || category == null || attribute == null || code == null ||
       id == 0 || category == 0 || attribute == 0 || code == 0) {
      return List.generate(6, (index) {
        if(index == 3 || index == 4) {
          return '';
        }
        if(selectedColumns[index] == null || selectedColumns[index] == 0) {
          return 'Null Error';
        }
          return '';
       });
    } else {
      // No column can handle multiple roles
      Set<int> columns = <int>{};
      for(int i = 0; i < selectedColumns.length; i++) {
        if(selectedColumns[i] != null && !columns.contains(selectedColumns[i])) {
          columns.add(selectedColumns[i]!);
        } else {
          if(i == 3 || i == 4) {
            continue;
          }
          errors[i] = 'Overlap Error';
          return errors;
        }
      }
      
      LoadedCSV csvDataList = LoadedCSV( currentCSV:
        currentCSV.where((row) =>
          row.isNotEmpty && row[id-1] != 0
        ).toList()
      );

      List<List<dynamic>> columnData = csvDataList.transpose();

      // Note: 0 is Null, first column selected in dropodown menu is 1, so -1 is needed
      // i.e. if the first column of the CSV is selected as ID, id = 1 in selectedColumns[0] but
      //     appears in columnData[0].

      // ID: No duplicate non-zero values
      if(Set.from(columnData[id-1]).length != columnData[id-1].length) {
        errors[0] = 'Duplicate Error';
        return errors;
      }
      // Code: Cannot be empty
      if(columnData[code-1].contains('')) {
        errors[5] = 'Empty Error';
        return errors;
      }
      // Category: Cannot be empty
      if(columnData[category-1].contains('')) {
        errors[1] = 'Empty Error';
        return errors;
      }
      // Attribute: Cannot be empty
      if(columnData[attribute-1].contains('')) {
        errors[2] = 'Empty Error';
        return errors;
      }
    }

    return errors;
  }

  /// Retrieve all rows with the section attribute provided.
  /// 
  /// Returns: LoadedCSV object
  LoadedCSV getSection(String section, int sectionIndex) {

    List<List<dynamic>> extractedRows = [];

    for(List<dynamic> row in currentCSV) {
      if(row[sectionIndex] == section) {
        extractedRows.add(row);
      }
    }

    return LoadedCSV(currentCSV: extractedRows);
  }

  /// Reduce CSV into a map from ID to attribute objects.
  /// 
  /// Parameters:
  ///   primaryIndex: representing column index for section
  ///   secondaryIndex: representing column index for attribute
  ///   tertiaryIndex: representing column index for format
  Map<int,AttributeObject> extractIDMap(int primaryIndex, int secondaryIndex, int tertiaryIndex) {
    Map<int, AttributeObject> columnMap = {};

    for (int rowIndex = 0; rowIndex < currentCSV.length; rowIndex++) {
      List<dynamic> row = currentCSV[rowIndex];
      
      if (row[secondaryIndex] is String && row[secondaryIndex].isNotEmpty) {
        columnMap[rowIndex] = AttributeObject(
          section: row[primaryIndex],
          attribute: row[secondaryIndex],
          format: row[tertiaryIndex]
        );
      }
    }
    return columnMap;
  }

  /// Retrieve headers in loaded csv
  /// 
  /// Returns: List<dynamic> object
  List<String> getHeaders() {
    return currentCSV[0].map((item) => item.toString()).toList();
  }
  
  @override
  // TODO: implement iterator
  Iterator get iterator => throw UnimplementedError();
}

bool checkColumnNull(List<int?> selection) {
  //representing columns ID, Category, Attributes and Attribute Code, these selections cannot be null
  List<dynamic> test = [0,1,2,5];
  selection.indexOf(null);

  return test.any((index) => [null,0,-1].contains(selection[index]));
}

Map<int, String> getIndexToSection(List<dynamic> uniqueSection) {
  Map<int, String> sectionMap = {};

  for(int i = 0; i < uniqueSection.length; i++) {
    sectionMap[i] = uniqueSection[i];
  }

  return sectionMap;
}

/// Create and return a sample csv environment
LoadedCSV _testSetup() {
  List<List<dynamic>> temp = [
    ['ID', 'Section', 'Name', 'Description', 'Synonym', 'Format'],
    [0, 'Origin', '', 'Genesis of the material, inspiration of the content', '', ''],
    [0, 'Position', '', '90% will be posing threats to your social status, might as well be more specific then.', '', ''],
    [0, 'Hair', '', 'Fairly generic ay? Pink, white, traditional black... choose whatever and pray you have it.', '', ''],
    [0, 'Tags', '', 'The fun part', '', ''],
    [0, 'Safe', '', 'Well... If you say so.', '', ''],
    [1, 'Origin', 'Azur Lane', 'Ships personified into melons', '', 'AE'],
    [2, 'Origin', 'Genshin', 'Ships personified into melons', '', 'AE'],
  ];

  return LoadedCSV(currentCSV: temp);
}