import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foldtag/main.dart';
import 'package:foldtag/page_sp_fn/cupage_sp.dart';
import 'package:foldtag/support_widgets/miscellenous_widgets.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final newSectionController = TextEditingController();
  final newDesciptionController = TextEditingController();

  var flash = false;
  var error = '';

  @override
  void dispose() {
    newSectionController.dispose();
    newDesciptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    final GlobalKey<FlashingBoxState> flashingBoxKey = GlobalKey<FlashingBoxState>();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: DefaultTitle(
            title: 'Add new page',
            description: 'Create and include tags not included in the provided file',
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 220,
            child: TextFormField(
              controller: newSectionController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Section Name',
              )        
            ),
          ),
        ),         
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 220,
            child: TextFormField(
              controller: newDesciptionController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Section Description',
              )
            ),
          ),
        ),
        const SizedBox(height: 40,),
        Center(
          child: SizedBox(
            child: ElevatedButton(
              onPressed: () {
                CustomObject newSection = CustomObject(
                  sectionName: newSectionController.text, 
                  description: newDesciptionController.text
                );
                switch (newSection.checkValid(appState.destinationList)) {
                  case 'Empty':
                    setState(() {
                      error = 'No section name';
                      flash = true;
                    });
                    break;
                  case 'Exists':
                    setState(() {
                      error = 'Section name in use';
                      flash = true;
                    });
                    break;
                  case 'Valid':
                    setState(() {
                      flash = false;
                      appState.addCustomDestination(newSection);
                    });
                    break;
                  default:
                    throw UnimplementedError('Add page case not covered');
                }
              },
              child: const Text('Create Section'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          child: Builder(
            builder: (context) {
              return Stack(
                children: [
                  Text(error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                  if(flash)
                    Visibility(
                      visible: flash,
                      child: Positioned(top: 0, right: 0, left: 0, bottom: 0, child: FlashingBox(key: flashingBoxKey, width: 70),),
                    )
                ]
              );
            }
          ),
        ),
      ],
    );
  }
}