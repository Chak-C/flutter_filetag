import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class LoadPage extends StatelessWidget {
  const LoadPage({super.key});

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
                onPressed: () {
                  appState.loadCSV();
                },
                child: const Text('CSV. NOW.'),
              ),
            ],
          ),
        ),
    );
  }
}