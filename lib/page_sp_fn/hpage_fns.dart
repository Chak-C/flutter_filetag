import 'package:flutter/material.dart';

import 'package:foldtag/csv_analysis.dart';
import 'package:foldtag/page/add_page.dart';
import 'package:foldtag/page/code_page.dart';
import 'package:foldtag/page/custom_page.dart';
import 'package:foldtag/page/tick_page.dart';

/// Support functions for home_page.dart
/// 
/// Functions;

/// Create list of widgets (that act as pages) for destination bar
List<Widget> getDestinationPages(LoadedCSV? currentCSV, List<int?> selectedColumns, int scanLength, List<dynamic> itemList) {
  final List<Widget> mainPage = [CodePage(
    attributeMap: currentCSV!.extractIDMap(
      selectedColumns[1]!,
      selectedColumns[2]!,
      selectedColumns[5]!)
    )
  ];

  final List<Widget> csvPages = List.generate(
    scanLength, 
    (index) => StatefulBuilder(
      builder: (context, setState) => TickPage(
        sectionRows: currentCSV.getSection(itemList[index], selectedColumns[1]!),
        selectedColumns: selectedColumns,
      ),
    ),
  );
  
  final List<Widget> addedPages = List.generate(
    itemList.length - scanLength, 
    (index) => Builder(
      builder: (context) => CustomPage(customObject: itemList[scanLength+index])
    ),
  );

  final List<Widget> increasePage = [const AddPage()];

  return [...mainPage, ...csvPages, ...addedPages, ...increasePage];
}