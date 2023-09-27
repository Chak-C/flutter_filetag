import 'package:flutter/material.dart';
import 'package:foldtag/page/selection_page.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class LoadPage extends StatelessWidget {
  const LoadPage({super.key});

  void navigateToSelectionPage(BuildContext context) {
    try {
      Navigator.push(
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
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Container(
      color: const Color.fromARGB(255, 192, 139, 228),
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: theme.colorScheme.primary.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(20),
    
                  child: Text(
                    'Upload CSV.',
                    style: style,
                  )
                )
              ),
              ElevatedButton(
                onPressed: () async {
                  appState.loadCSV();
                  
                  await Future.delayed(const Duration(milliseconds: 200));

                  if(appState.currentCSV != null) {
                    // ignore: use_build_context_synchronously
                    navigateToSelectionPage(context);
                  }
                },
                child: const Text('CSV. NOW.'),
              ),
            ],
          ),
        ),
    );
  }
}