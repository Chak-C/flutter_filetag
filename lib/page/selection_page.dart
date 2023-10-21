import 'package:flutter/material.dart';
import 'package:foldtag/main.dart';
import 'package:foldtag/page/home_page.dart';
import 'package:foldtag/support_widgets/dropdown_menu.dart';
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
  
  void onContinuePressed() {
    final appState = context.read<AppState>();
    appState.flashError = true;
    appState.columnIndexFinalProcess();
    Future.delayed(const Duration(milliseconds: 100));

    if (appState.selectionError.every((e) => e == '')) {
      navigateToPage(context, const HomePage());
    } else {
      navigateToPage(context, const SelectionPage());
    }
  }

  void navigateToPage(BuildContext context, Widget page) {
    try {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
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
            for (int dropdownNumber = 0; dropdownNumber < 6; dropdownNumber++)
              Column(
                children: [
                  DropRow(prefix: _getPrefix(dropdownNumber), dropdownNumber: dropdownNumber),
                  const SizedBox(height: 20),
                ],
              ),
            ElevatedButton(
              onPressed: () {
                onContinuePressed();
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

String _getPrefix(int dropdownNumber) {
  switch(dropdownNumber) {
    case 0:
      return 'ID';
    case 1:
      return 'Category';
    case 2:
      return 'Attribute';
    case 3:
      return 'Attribute Synonym';
    case 4:
      return 'Description';
    case 5:
      return 'Code';
    default:
      return '';
  }
}

