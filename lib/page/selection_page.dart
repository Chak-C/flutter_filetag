import 'package:flutter/material.dart';
import 'package:foldtag/main.dart';
import 'package:foldtag/page/home_page.dart';
import 'package:foldtag/support_widgets/miscellenous_widgets.dart';
import 'package:provider/provider.dart';

class SelectionState extends ChangeNotifier {
  List<int?> selectedColumns = List.generate(6, (index) => null);

  void changeSelection(int dropdownNumber, int? columnIndex) {
    selectedColumns[dropdownNumber] = columnIndex;
  }
}

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});
  
  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {

  void navigateToHomePage(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      // Handle and log any errors
    }
  }

  void reloadCurrentPage(BuildContext context) {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SelectionPage()),
      );
    } catch (e) {
      // Handle and log any errors
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DropRow(prefix: 'ID', dropdownNumber: 0),
            const SizedBox(height: 20),
            const DropRow(prefix: 'Category', dropdownNumber: 1),
            const SizedBox(height: 20),
            const DropRow(prefix: 'Attribute', dropdownNumber: 2),
            const SizedBox(height: 20),
            const DropRow(prefix: 'Attribute Synonym', dropdownNumber: 3),
            const SizedBox(height: 20),
            const DropRow(prefix: 'Description', dropdownNumber: 4),
            const SizedBox(height: 20),
            const DropRow(prefix: 'Code', dropdownNumber: 5),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                appState.flashError = true;
                appState.columnIndexFinalProcess();
                Future.delayed(const Duration(milliseconds: 200));

                if (appState.selectionError.every((e) => e == '')) {
                  navigateToHomePage(context);
                } else {
                  reloadCurrentPage(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(8.0),
                fixedSize: const Size(200, 50),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Visibility(
              visible: appState.flashError,
              child: SizedBox(
                child: Text(
                  appState.selectionError.firstWhere((element) => element != '', orElse: () => '')
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Combination of SectionSelect and Prefix text using Row widget
class DropRow extends StatelessWidget {
  const DropRow({
    super.key, 
    this.prefix,
    required this.dropdownNumber
  });

  final String? prefix;
  final int dropdownNumber;

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    int? selectedIndex = appState.selectedColumns[dropdownNumber];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefix != null)
          SizedBox(
            width: 140,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                '$prefix: ',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ),
          ),
        SectionSelect(
          dropdownNumber: dropdownNumber,
          initialIndex: selectedIndex ?? 0
        ),
      ],
    );
  }
}

/// Custom dropdown menu for selecting columns for analysis.
class SectionSelect extends StatefulWidget {
  const SectionSelect({
    super.key,
    required this.dropdownNumber,
    required this.initialIndex
  });
  final int dropdownNumber;
  final int initialIndex;
  
  @override
  State<SectionSelect> createState() => _SectionSelectState();
}

class _SectionSelectState extends State<SectionSelect> {
  var selectedIndex = 0; 
  
  // changes the column selection in dropdown menus
  void changeSelection(AppState appState, int dropdownNumber, int? columnIndex) {
    appState.selectedColumns[dropdownNumber] = columnIndex;
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var colorScheme = Theme.of(context).colorScheme;

    final List<String> dropdownList = ['Null'] + appState.currentCSV!.getHeaders();
    final GlobalKey<FlashingBoxState> flashingBoxKey = GlobalKey<FlashingBoxState>();

    String selectedHeader = dropdownList[selectedIndex];

    const double width = 220;
    final theme = Theme.of(context);
    final color = theme.colorScheme.secondary;

    
    return Row(
      children: [
        SizedBox(
          width: width,
          child: PopupMenuButton(
            initialValue: selectedHeader,
            onSelected: (item) {
              appState.flashError = false;
              setState(() {
                selectedIndex = dropdownList.indexOf(item);
                changeSelection(appState, widget.dropdownNumber, selectedIndex);
              });
            },
            itemBuilder: (BuildContext context) {
              return dropdownList.map((String item) {
                return PopupMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 16),),
                );
              }).toList();
            },
            child: Stack(
              children: [
                Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 3, color: color),
                  color: colorScheme.onPrimary
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedHeader,
                        style: const TextStyle(fontSize: 16,)
                        ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                if(appState.flashError)
                  Visibility(
                    visible: appState.selectionError[widget.dropdownNumber].isNotEmpty,
                    child: Positioned(top: 0, right: 0, left: 0, bottom: 0, child: FlashingBox(key: flashingBoxKey, width: 220),)
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}