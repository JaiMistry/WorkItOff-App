import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workitoff/widgets.dart';
import 'food_item.dart';
import 'food_item_provider.dart';
import 'food_grid.dart';

class FoodPage extends StatefulWidget {
  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  TextEditingController _searchController = new TextEditingController();
  String _restuarantSearchFilter;
  int _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_setSearchFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_setSearchFilter);
    _searchController.dispose();
    super.dispose();
  }

  void _setSearchFilter() {
    setState(() {
      _restuarantSearchFilter = _searchController.text;
    });
  }

  void _setPage(int newPageId) {
    if (_selectedPage == newPageId) {
      return;
    }

    setState(() {
      _selectedPage = newPageId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (ctx) => FoodItemProvider(),
      child: IndexedStack(
        index: _selectedPage,
        children: <Widget>[
          Container(
            decoration: getBasicGradient(),
            child: Column(
              children: <Widget>[
                SearchBar(hintText: 'Search', controller: _searchController, bottomMargin: 6),
                Expanded(child: FoodBody(restuarantSearchFiler: _restuarantSearchFilter, setPage: _setPage)),
              ],
            ),
          ),
          FoodItemPage(setPage: _setPage),
        ],
      ),
    );
  }
}