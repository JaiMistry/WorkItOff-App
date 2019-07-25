import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:workitoff/navigation_bar.dart';
import 'package:workitoff/pages/food/food_item.dart';
// import 'package:workitoff/providers/progress_provider.dart';
// import 'package:workitoff/providers/user_provider.dart';

// import 'package:transparent_image/transparent_image.dart';

import 'package:workitoff/widgets.dart';

// ? https://medium.com/coding-with-flutter/flutter-case-study-multiple-navigators-with-bottomnavigationbar-90eb6caa6dbf
// This is probably the way to do it.

final BottomNavigationBar navBar = navBarGlobalKey.currentWidget;

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
            child: Column(
              children: <Widget>[
                SearchBar(hintText: 'Search', controller: _searchController, bottomMargin: 6),
                Expanded(child: FoodBody(restuarantSearchFiler: _restuarantSearchFilter, setPage: _setPage)),
              ],
            ),
            decoration: getBasicGradient(),
          ),
          FoodItemPage(setPage: _setPage),
        ],
      ),
    );
  }
}

Widget _builderEnterCaloriesButton(BuildContext context, ScrollController controller, Function setPageScrollPosition) {
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
          onTap: () {
            setPageScrollPosition(true);
          },
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
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void setPageScrollPosition(bool scrollToBottom) {
    double scrollPosition = _scrollController.position.maxScrollExtent;
    if (scrollToBottom == false) {
      scrollPosition = _scrollController.position.minScrollExtent;
    }
    _scrollController.animateTo(
      scrollPosition,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 1000),
    );
  }

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
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 20.0),
          children: <Widget>[
            _builderEnterCaloriesButton(context, _scrollController, setPageScrollPosition),
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
            Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 60.0, bottom: 35.0),
                  child: Text('Enter your own calories', style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold)),
                  alignment: Alignment.bottomCenter,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          width: 150,
                          child: TextField(
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: Colors.white.withOpacity(0.9)),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 10),
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                                fillColor: Colors.grey.withOpacity(0.2),
                                filled: true),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      RaisedButton(
                        child: Text('Enter Calories', style: TextStyle(fontSize: 20.0)),
                        onPressed: () {},
                        color: Color(0xff3ADEA7),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.0),
                Image.asset('assets/logo_transparent.png', height: MediaQuery.of(context).size.height * 0.2),
                SizedBox(height: 50.0),
                Text('We are always adding new restaurants!'),
                SizedBox(height: 10.0),
                Text(
                  'There is no relationship between the Work It Off app and the restaurants',
                  style: TextStyle(fontSize: 10.0),
                ),
                Text('displayed on this page.', style: TextStyle(fontSize: 10.0)),
                SizedBox(height: 100.0)
              ],
            )
          ],
        ),
      ),
    );
  }
}
