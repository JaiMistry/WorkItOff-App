// import 'dart:ui' as prefix0;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
// import 'package:workitoff/navigation_bar.dart';

// import 'package:transparent_image/transparent_image.dart';

import 'package:workitoff/widgets.dart';

// ? https://medium.com/coding-with-flutter/flutter-case-study-multiple-navigators-with-bottomnavigationbar-90eb6caa6dbf
// This is probably the way to do it.

class FoodItemProvider extends ChangeNotifier {
  DocumentSnapshot _currentRestaurant;

  set currentRestuarant(DocumentSnapshot snap) {
    _currentRestaurant = snap;
    notifyListeners();
  }

  DocumentSnapshot get currentRestuarant {
    return _currentRestaurant;
  }
}

// class FoodPage

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
      // TODO: Instantiate widgets, this might preserve state better
      child: IndexedStack(
        index: _selectedPage,
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                SearchBar(hintText: 'Search', controller: _searchController, bottomMargin: 6),
                Expanded(child: FoodBody(restuarantSearchFiler: _restuarantSearchFilter, setPage: _setPage)),
              ],
            ),
            decoration: const BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [Color(0xff170422), Color(0xff9B22E6)],
                stops: const [0.75, 1],
              ),
            ),
          ),
          FoodItemPage(setPage: _setPage),
        ],
      ),
    );
  }
}

Widget _builderEnterCaloriesButton() {
  return Column(
    children: <Widget>[
      const Text("Can't find your cheat meal?", style: TextStyle(fontSize: 20, color: Color(0xff4ff7d3))),
      const SizedBox(height: 12),
      Container(
        alignment: Alignment.center,
        width: 180,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: const [Color(0xff9B22E6), Color(0xff4ff7d3)],
            stops: const [0.01, 0.7],
          ),
        ),
        child: InkWell(
          child: const Text(
            'Enter Calories',
            style: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          onTap: () {},
        ),
      ),
    ],
  );
}

class FoodBody extends StatefulWidget {
  final String restuarantSearchFiler; // user input in the searchbar
  final Function setPage;

  FoodBody({Key key, @required this.restuarantSearchFiler, @required this.setPage}) : super(key: key);

  _FoodBodyState createState() => _FoodBodyState();
}

class _FoodBodyState extends State<FoodBody> {
  Widget _makeFoodCard(BuildContext context, DocumentSnapshot restaurant) {
    String imageUrl = restaurant.data['image_url'];
    if (imageUrl == null) {
      imageUrl = 'https://via.placeholder.com/500x500?text=Error+Loading+Image';
    }
    return Container(
      padding: const EdgeInsets.all(7),
      child: InkWell(
        onTap: () {
          Provider.of<FoodItemProvider>(context)._currentRestaurant = restaurant;
          widget.setPage(1);
          // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => FoodItemPage(restaurant: restaurant)));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            color: Colors.white,
            child: InkWell(
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(),
                errorWidget: (context, url, error) =>
                    Container(child: const Center(child: Text('Error Loading Image..'))),
                // placeholder: kTransparentImage,
                imageUrl: imageUrl,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                fadeInDuration: const Duration(milliseconds: 250),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getFoodCards(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Widget> _foodCards = [];

    snapshot.data.documents.forEach((DocumentSnapshot restaurant) {
      String _filter = widget.restuarantSearchFiler; // user input in the searchbar
      String restaurantName = restaurant.documentID.toLowerCase();
      if (_filter == null || _filter == '' || restaurantName.contains(_filter.toLowerCase())) {
        // If there is no filter applied or part of the string is in the restaurant name, then return it. Else nothing.
        _foodCards.add(_makeFoodCard(context, restaurant));
      }
    });

    return _foodCards;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: ScrollConfiguration(
        behavior: NoOverscrollBehavior(),
        child: ListView(
          padding: const EdgeInsets.only(top: 20.0),
          children: <Widget>[
            _builderEnterCaloriesButton(),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('food').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.hasError) {
                  return Container();
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff4ff7d3)),
                    ),
                  );
                }

                return GridView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  children: _getFoodCards(snapshot),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//
//*  FOOD ITEM PAGE //*
//

class FoodItems extends StatefulWidget {
  final DocumentSnapshot restaurant;
  final String searchText;

  FoodItems({Key key, @required this.restaurant, @required this.searchText}) : super(key: key);

  _FoodItemsState createState() => _FoodItemsState();
}

List<Widget> _buildExpansionButtons(BuildContext context, int quantity, Function setQuantity, String meal) {
  return [
    const SizedBox(height: 2),
    Container(
      height: 25,
      width: 150,
      child: FlatButton(
        padding: const EdgeInsets.all(0),
        color: Colors.purple.withOpacity(0.5),
        onPressed: () {
          _showLogDialog(context, setQuantity, quantity);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: <TextSpan>[
                  const TextSpan(text: 'Quantity '),
                  TextSpan(text: quantity == 0 ? '1/2' : quantity.toString()),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.3))
          ],
        ),
      ),
    ),
    const SizedBox(height: 10),
    Container(
      height: 25,
      width: 150,
      child: FlatButton(
        color: Colors.teal.withOpacity(0.5),
        onPressed: () {
          showDefualtFlushBar(context: context, text: '$quantity $meal added to cart.');
        },
        child: const Text('Add To Meal', style: TextStyle(color: Colors.white)),
      ),
    )
  ];
}

class _FoodItemsState extends State<FoodItems> {
  int quantity = 1;

  void _setQuantity(int newQuantity) {
    setState(() {
      quantity = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.restaurant == null) {
      return Container();
    }
    return Container(
      child: Expanded(
        child: ScrollConfiguration(
          behavior: NoOverscrollBehavior(),
          child: ListView.builder(
            // shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (BuildContext contect, int index) {
              if (widget.restaurant.data['meals'] == null || widget.restaurant.data['meals'].toString() == '{}') {
                return Container(padding: EdgeInsets.only(top: 20), child: Center(child: Text('No Meals Found.')));
              }

              Map<String, Map> categories = widget.restaurant.data['meals'].cast<String, Map>();
              List<Widget> widgetList = [];

              categories.forEach((categtory, mealMap) {
                List<Widget> mealList = [];

                Map<String, int> meals = mealMap.cast<String, int>();
                meals.forEach((String meal, int cals) {
                  String searchText = widget.searchText;

                  //Only reutrn the food items that are being searched for
                  if (searchText == null || searchText == '' || meal.toLowerCase().contains(searchText.toLowerCase())) {
                    mealList.add(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Material(
                          color: Colors.transparent,
                          child: Theme(
                            data: ThemeData(accentColor: Colors.white, unselectedWidgetColor: Colors.white),
                            child: ExpansionTile(
                              onExpansionChanged: (bool state) {},
                              title: Text(meal, style: TextStyle(color: Colors.white, fontSize: 14)),
                              // trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white),
                              children: _buildExpansionButtons(context, quantity, _setQuantity, meal),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                });

                // Only return the category if there are food items within
                if (mealList.length > 0) {
                  widgetList.add(
                    Column(
                      children: <Widget>[
                        ListTile(title: Text(categtory, style: TextStyle(color: Color(0xff4ff7d3), fontSize: 22))),
                        Column(
                          children: mealList,
                        )
                      ],
                    ),
                  );
                }
              });

              return Column(children: widgetList);
            },
          ),
        ),
      ),
    );
  }
}

class FoodItemPage extends StatefulWidget {
  final Function setPage;
  // final DocumentSnapshot restaurant;

  FoodItemPage({@required this.setPage});

  @override
  _FoodItemPageState createState() => _FoodItemPageState();
}

class _FoodItemPageState extends State<FoodItemPage> {
  TextEditingController _searchController = new TextEditingController();
  String searchText;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_setSearchText);
  }

  @override
  void dispose() {
    _searchController.removeListener(_setSearchText);
    _searchController.dispose();
    super.dispose();
  }

  void _setSearchText() {
    setState(() {
      searchText = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot _restuarant = Provider.of<FoodItemProvider>(context)._currentRestaurant;
    // TODO This solution breaks the android back button from working in other parts of the app
    return WillPopScope(
      onWillPop: () {
        widget.setPage(0);
        return Future.value(false); // Dont actually go back. I only want to run the function above
      },
      child: Column(
        children: <Widget>[
          AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                widget.setPage(0);
              },
            ),
            backgroundColor: Color(0xff170422),
            title: Text(_restuarant == null ? 'Placeholder' : _restuarant.documentID),
            elevation: 0,
          ),
          Flexible(
            child: Container(
              decoration: const BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [Color(0xff170422), Color(0xff9B22E6)],
                  stops: const [0.75, 1],
                ),
              ),
              child: Column(
                children: <Widget>[
                  SearchBar(controller: _searchController, hintText: 'Search', topMargin: 5, bottomMargin: 6),
                  FoodItems(restaurant: _restuarant, searchText: searchText)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class QuantityRadioList extends StatefulWidget {
  final Function setQuantity;
  final int quantity;
  QuantityRadioList({@required this.setQuantity, @required this.quantity});

  _QuantityRadioListState createState() => _QuantityRadioListState();
}

class _QuantityRadioListState extends State<QuantityRadioList> {
  int _selected = 1;

  @override
  void initState() {
    _selected = widget.quantity;
    super.initState();
  }

  void onRadioChanged(int value) {
    setState(() {
      _selected = value;
      widget.setQuantity(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: 101,
        itemBuilder: (BuildContext context, int index) {
          return RadioListTile(
            dense: true,
            groupValue: _selected,
            value: index,
            title: Text(index == 0 ? '1/2' : index.toString(), style: TextStyle(color: Colors.black)),
            onChanged: (int value) {
              onRadioChanged(value);
            },
          );
        },
      ),
    );
  }
}

Future<void> _showLogDialog(BuildContext context, Function setQuantity, int quantity) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        // title: Container(color: Colors.black, width: 100, height: 1), //Looks ugly, but is in app
        contentPadding: const EdgeInsets.all(0),
        titlePadding: const EdgeInsets.all(5),
        content: Container(
          height: 250,
          width: 200,
          alignment: Alignment.center,
          child: QuantityRadioList(setQuantity: setQuantity, quantity: quantity),
        ),
        actions: <Widget>[
          FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.grey[200],
            textColor: Colors.black,
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            onPressed: () {
              setQuantity(quantity);
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.grey[200],
            textColor: Colors.black,
            child: const Text('Select', style: TextStyle(fontSize: 16)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
