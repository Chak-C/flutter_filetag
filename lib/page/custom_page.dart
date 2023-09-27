import 'package:flutter/material.dart';
import 'package:foldtag/namer.dart';
import 'package:provider/provider.dart';

import 'package:foldtag/main.dart';
import 'package:foldtag/page_sp_fn/cupage_sp.dart';
import 'package:foldtag/support_widgets/checkblock_factory.dart';
import 'package:foldtag/support_widgets/miscellenous_widgets.dart';

class CustomPage extends StatefulWidget {
  final CustomObject customObject;

  const CustomPage({super.key, required this.customObject});

  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  final _newSectionItemController = TextEditingController();
  final _focusNode = FocusNode();

  void _addItem(CustomObject data) {
    String newItem = _newSectionItemController.text.trim();

    if (newItem.isNotEmpty) {
      setState(() {
        data.addItem(newItem);
        _newSectionItemController.clear();
        _focusNode.requestFocus();
      });
    }
  }

  Widget _objectButtons(String text, Color? textColor, Color? bgColor, Function() function) {
    return SizedBox(
      width: 100,
      child: OutlinedButton(
        onPressed: function,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: bgColor ?? Colors.transparent,
        ),
        child: Text(text, style: TextStyle(color: textColor ?? Colors.black),)
      ),
    );
  }
  @override
  void dispose() {
    _newSectionItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var colorScheme = Theme.of(context).colorScheme;
    CustomObject pageData = widget.customObject;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: DefaultTitle(
                  title: pageData.sectionName,
                  description: pageData.description,
                )
              ),
            ),
            _objectButtons('Remove', null, null, //TODO remove or change this, currently redundant
              () {
                setState(() {
                  
                });
              }
            ),
            const SizedBox(width: 10),
            _objectButtons('Reset', null, null,
              () {
                setState(() {
                  pageData.resetItem();
                  appState.updateCustomeDestination(pageData);
                });
              }
            ),
            const SizedBox(width: 40),
            _objectButtons('Delete Page', Colors.white, Colors.red,
              () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Confirmation'),
                      content: const Text('Customized tags cannot be recovered. Please proceed with caution.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Closes the dialog
                          },
                        ),
                        TextButton(
                          child: const Text('Confirm'),
                          onPressed: () {
                            setState(() {
                              appState.removeCustomDestination(pageData);
                            });
                            Navigator.of(context).pop(); // Closes the dialog
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            ),
            const SizedBox(width: 20),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 220,
            child: TextFormField(
              controller: _newSectionItemController,
              focusNode: _focusNode,
              onEditingComplete: () => _addItem(pageData),
              decoration: InputDecoration(
                labelText: 'Add new item:',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _addItem(pageData)
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: GridView(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400/80,
              crossAxisSpacing: 50,
            ),
            children: [
              for (var item in pageData.items)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black.withOpacity(0.3),
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                        color: colorScheme.secondary,
                        onPressed: () {
                          setState(() {
                            pageData.removeItem(item);
                            appState.included.contains(item) ? appState.toggleIncluded(item) : null;
                          });
                        },
                      ),
                      Expanded(
                        child: CBFactory(
                          item: AttributeObject(
                            section: pageData.sectionName,
                            attribute: item,
                            format: '${item[0]}${item[item.length-1]}'
                          ), 
                          description: '', 
                          displaySynonym: false,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}