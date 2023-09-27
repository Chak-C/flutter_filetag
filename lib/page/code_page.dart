import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foldtag/main.dart';
import 'package:foldtag/namer.dart';
import 'package:provider/provider.dart';

class CodePage extends StatefulWidget {
  const CodePage({super.key, required this.attributeMap});

  // map from id to attribute names
  final Map<int,AttributeObject> attributeMap;

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var colorScheme = Theme.of(context).colorScheme;

    final bool itemsExist = appState.included.isNotEmpty;

    // TODO hardcoded sectino order
    final List<String> sectionOrder = ['Origin','Character','Position','Hair','Tags','Safe'];
    
    //TODO finialise code generating logic
    appState.code = appState.included.isEmpty 
      ? '' 
      : generateCode(widget.attributeMap, appState.included, sectionOrder);

    ButtonStyle buttonStyle = itemsExist
      ? ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.black),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.transparent)
          )
        )
      )
      : ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey),
        foregroundColor: MaterialStateProperty.all(Colors.grey),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey)
          )
        )
      );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          const SizedBox(height: 10),
          CodeCard(code: appState.code),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: itemsExist
                  ? () {
                    appState.resetIncluded();
                  }
                  : null, 
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Reset'),
                style: buttonStyle
              ),
    // Unload button
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  appState.unloadCSV();
                },
                icon: const Icon(Icons.videogame_asset_off_outlined, color: Color.fromARGB(245, 255, 255, 255)),
                label: const Text('Unload', style: TextStyle(color: Color.fromARGB(245, 255, 255, 255)),),
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(colorScheme.error),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.transparent)
                    ),
                  ),
                ),
              ),
            ]
          ),
          const Spacer(flex: 2),
        ],
      )
    );
  }
}


class CodeCard extends StatelessWidget {
  const CodeCard({
    Key? key,
    required this.code,
  }) : super(key: key);

  final String code;

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard: $text')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );

    if(code.isEmpty) {
      return Card(
        color: theme.colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Select attributes in other pages.',
            style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
            semanticsLabel: "code",
          ),
        ),
      );
    }
    var appState = context.watch<AppState>();

    return Card(
      color: theme.colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onTap: () {
            _copyToClipboard(context, code.toLowerCase());
            appState.copyComplete();
          },
          child: Text(
            code.toLowerCase(),
            style: style,
            semanticsLabel: "code",
          ),
        ),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard: $text')),
    );
  }

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final history = appState.history;

    appState.historyListKey = _key;
    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(
        Rect.fromPoints(const Offset(0,0), Offset(bounds.width, bounds.height * 2))
      ),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: const EdgeInsets.only(top: 100),
        initialItemCount: history.length,
        itemBuilder: (context, index, animation) {
          final code = history[index];
          
          return HistoryTile(
            text: code, 
            animation: animation, 
            function: () => _copyToClipboard(context, code),
          );
        },
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  final String text;
  final Animation<double> animation;
  final void Function()? function;

  const HistoryTile({super.key, required this.text, required this.animation, this.function});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: Center(
        child: TextButton.icon(
          onPressed: function,
          icon: const SizedBox(),
          label: Text(
            text.toLowerCase(),
            semanticsLabel: text.toLowerCase(),
          ),
        ),
      ),
    );
  }
}