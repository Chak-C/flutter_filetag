import 'dart:io';
import 'package:csv/csv.dart';
import 'package:foldtag/namer.dart';
import 'package:foldtag/page/code_page.dart';
import 'package:provider/provider.dart';

import 'page/load_page.dart';
import 'page/home_page.dart';
import 'csv_analysis.dart';
import 'package:foldtag/page_sp_fn/cupage_sp.dart';
import 'package:foldtag/page/selection_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        
        title: 'Coded Filenames',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  // 
  // Global Variables
  //
  
  // holds uploaded csv
  LoadedCSV? currentCSV;

  // holds destinations and destinations retrieved from csv
  List<dynamic> destinationList = [];
  int scannableDestination = 0;

  // holds ticked attributes
  var included = <AttributeObject>[];

  // holds history and history list key
  var history = <String>[];
  GlobalKey? historyListKey;

  // holds designated columns and errors, used in selection_page mainly
  // 0: ID, 1: Category, 2: Attribte, 3: Synonym (nullable), 4: 
  List<int?> selectedColumns = List.generate(6, (index) => null);
  List<String> selectionError = List.generate(6, (index) => 'Null Error');
  bool flashError = false;

  // holds finalised name
  var code = '';

  //
  // Global Functions
  //

  /// updates included attributes
  void toggleIncluded(AttributeObject attribute) {
    if(included.contains(attribute)) {
      included.remove(attribute);
    } else {
      included.add(attribute);
    }
    notifyListeners();
  }

  /// removes all included attributes
  void resetIncluded() {
    included = <AttributeObject>[];
    code = '';
    notifyListeners();
  }

  void copyComplete() {
    history.insert(0, code);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);

    if(history.length > 5) {
      final item = history.last;
      history.removeLast();
      
      animatedList?.removeItem(5, (context, animation) {
        return HistoryTile(text: item, animation: animation);
      });
    } 
    
    resetIncluded();
  }

  /// user selects .csv from their device and loads into the application
  void loadCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv']
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String csvString = await file.readAsString();
      List<List<dynamic>> csvList = const CsvToListConverter().convert(csvString);
      currentCSV = LoadedCSV(currentCSV: csvList);
    }
    notifyListeners();
  }

  // user unloads .csv from the application
  void unloadCSV() {
    currentCSV = null;
    selectedColumns = List.generate(6, (index) => null);
    selectionError = List.generate(6, (index) => '');
    resetIncluded();
  }

  // finalises the validity of current column indexes with stored selectedColumns[]
  void columnIndexFinalProcess() {
    selectionError = currentCSV!.confirmValidColumnSelection(selectedColumns);

    if(selectionError.every((element) => element == '')) {
      selectedColumns = selectedColumns.map((e) => ((e) ?? 0) - 1).toList();

      destinationList = currentCSV!.getNavigationIdentifiers(selectedColumns[1]!);
      scannableDestination = destinationList.length;
      
      if(selectedColumns[3]! != -1) {
        currentCSV!.convertColumnToList(selectedColumns[3]!, ',');
      }
    }

    notifyListeners();
  }

  void addCustomDestination(CustomObject newDestination) {
    destinationList.add(newDestination);
    notifyListeners();
  }

  void removeCustomDestination(CustomObject newDestination) {
    included.removeWhere((element) => newDestination.items.contains(element));
    destinationList.removeWhere((element) => element.toString() == newDestination.sectionName);
    notifyListeners();
  }

  void updateCustomeDestination(CustomObject newDestination) {
    int index = destinationList.indexWhere((element) => element.toString() == newDestination.sectionName);
    destinationList[index] = newDestination;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  //final String title; //not used for now, add it back to required.this in super

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    if(appState.currentCSV?.currentCSV.isEmpty ?? true) {
      return const LoadPage();
    }

    if(!appState.selectionError.every((e) => e == '')) {
      return const SelectionPage();
    }

    return const HomePage();
  }
}