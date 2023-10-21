import 'package:flutter/material.dart';

import 'package:foldtag/csv_analysis.dart';
import 'package:foldtag/namer.dart';
import 'package:foldtag/page_sp_fn/tpage_fns.dart';
import 'package:foldtag/support_widgets/miscellenous_widgets.dart';
import 'package:foldtag/support_widgets/search_bar.dart';
import '../support_widgets/checkblock_factory.dart';

class TickPage extends StatefulWidget {
  const TickPage({super.key, required this.sectionRows, required this.selectedColumns});

  final LoadedCSV sectionRows; //rows of data in same section
  final List<int?> selectedColumns;

  @override
  State<TickPage> createState() => _TickPageState();
}

class _TickPageState extends State<TickPage> {
  //switch for description and synonym
  List<bool> isSelected = [false, false];
  
  //controller for search bar
  late TextEditingController searchController;

  //stores loaded csv
  late List<List<dynamic>> currentData = widget.sectionRows.currentCSV;

  //stores filtered search
  late List<List<dynamic>> filteredData = [];
  
  //stores column index for corresponding roles
  late int categoryIndex, attributeIndex, synonymIndex, descriptionIndex, formatIndex;
  
  //cannot be null by columnIndexFinalProcess()
  void _updateIndexes() {
    categoryIndex = widget.selectedColumns[1]!;
    attributeIndex = widget.selectedColumns[2]!;
    synonymIndex = widget.selectedColumns[3]!;
    descriptionIndex = widget.selectedColumns[4]!;
    formatIndex = widget.selectedColumns[5]!;
  }

  void filterData(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        filteredData = currentData;
      });
      return;
    }
    setState(() {
      filteredData = currentData.where((item) {
        return checkSearchTokens(item, attributeIndex, synonymIndex, searchText);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _updateIndexes();
    filteredData = widget.sectionRows.currentCSV;
    searchController = TextEditingController();
  }

  @override
  void didUpdateWidget(TickPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update indexes and reset filteredData when widget updates (tab changes)
    _updateIndexes();
    setState(() {
      // Initialize filteredData with all data for the new tab initially
      filteredData = widget.sectionRows.currentCSV;
      currentData = widget.sectionRows.currentCSV;
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<List<dynamic>> currentData = widget.sectionRows.currentCSV;


    final List<bool> desynOption = [descriptionIndex != -1, synonymIndex != -1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title (section/category name) and subtitle (description, if applicable) text for check box pages
              Padding(
                padding: const EdgeInsets.all(20),
                child: DefaultTitle(
                  title: currentData[0][categoryIndex],
                  description: descriptionIndex != -1 ? currentData[0][descriptionIndex] : '',
                ),
              ),
              // Buttons to toggle description and synonym
              Padding(
                padding: const EdgeInsets.only(top: 10,right: 30),
                child: ToggleButtons(
                  isSelected: isSelected,
                  onPressed: (int index) {
                    if(desynOption[index]) {
                      setState(() {
                        isSelected[index] = !isSelected[index];
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Option unavailable for the loaded CSV')),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(4.0),
                  borderColor: Colors.black,
                  selectedBorderColor: Colors.black,
                  children: List.generate(2, (index) => Row(
                    children: [
                      if(isSelected[index])
                        const Icon(Icons.check, color: Colors.black),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          index == 0 ? 'Description' : 'Synonyms',
                          style: desynOption[index] 
                            ? const TextStyle(fontWeight: FontWeight.bold) 
                            : const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough),
                        ),
                      ),
                    ],
                  ))
                ),
              ),
            ],
          ),
          TickPageSearchBar(onSearch: filterData, searchController: searchController),
          // Gridview of checkboxes
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio:  400/80,
              ),
              children: [
                for (var item in filteredData)
                  if(item[attributeIndex].toString().isNotEmpty)
                    CBFactory(
                      item: AttributeObject(
                        section: currentData[0][categoryIndex],
                        attribute: item[attributeIndex].toString(),
                        format: item[formatIndex].toString()
                      ), 
                      description: isSelected[0] ? item[descriptionIndex].toString() : '',
                      displaySynonym: isSelected[1],
                      synonym: desynOption[1] ? item[synonymIndex] : [],
                    ),
              ],
            ),
          ),
        ],
      );
  }
}