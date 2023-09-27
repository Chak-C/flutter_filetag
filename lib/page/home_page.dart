import 'package:flutter/material.dart';
import 'package:foldtag/page_sp_fn/cupage_sp.dart';
import 'package:provider/provider.dart';


import 'package:foldtag/page_sp_fn/hpage_fns.dart';
import 'package:foldtag/main.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var colorScheme = Theme.of(context).colorScheme;

    final currentCSV = appState.currentCSV;
    final selectedColumns = appState.selectedColumns;
    final itemList = appState.destinationList;
    final scanLength = appState.scannableDestination;

    final List<Widget> contentList = getDestinationPages(currentCSV, selectedColumns, scanLength, itemList);

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: contentList[selectedIndex],
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return Column( 
              children: [
                Expanded(child: mainArea),
                SafeArea( 
                  child: BottomNavigationBar(
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      for(var item in itemList)
                          BottomNavigationBarItem(
                            icon: const Icon(Icons.circle_outlined), 
                            label: item.toString(),
                          ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                    selectedItemColor: colorScheme.inversePrimary,
                    unselectedItemColor: Colors.black26,
                  ),
                )
              ]
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: SizedBox(
                    width: 200.0,
                    child: NavigationRail(
                      extended: true,
                      destinations: [
                        const NavigationRailDestination(
                          icon: Icon(Icons.home), 
                          label: Text('Home'),
                        ),
                        for(var item in itemList)
                          NavigationRailDestination(
                            icon: const Icon(Icons.circle_outlined), 
                            label: item is CustomObject 
                              ? Text(item.sectionName) 
                              : Text(item),
                          ),
                        const NavigationRailDestination(
                          icon: Icon(Icons.add),
                          label: Text(''),
                        )
                      ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                    indicatorColor: colorScheme.inversePrimary,
                    ),
                  ),
              ),
              Expanded(child: mainArea)
              ],
            );
          }
        }
      ),
    );
  }
}