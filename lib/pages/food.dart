import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

// import 'package:transparent_image/transparent_image.dart';

import 'package:workitoff/widgets.dart';

String _filter; // user input in the searchbar

class FoodPage extends StatefulWidget {
  // const FoodPage({Key key}) : super(key: key);

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  TextEditingController _searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _filter = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SearchBar(hintText: 'Search', controller: _searchController, bottomMargin: 6),
          Expanded(
            child: FoodBody(),
          ),
        ],
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff170422), Color(0xff9B22E6)],
          stops: [0.75, 1],
        ),
      ),
    );
  }
}

Widget _builderEnterCaloriesButton() {
  return Column(
    children: <Widget>[
      Text("Can't find your cheat meal?", style: TextStyle(fontSize: 20, color: Color(0xff4ff7d3))),
      SizedBox(height: 12),
      Container(
        alignment: Alignment.center,
        width: 180,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xff9B22E6), Color(0xff4ff7d3)],
            stops: [0.01, 0.7],
          ),
        ),
        child: InkWell(
          child:
              Text('Enter Calories', style: TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold)),
          onTap: () {},
        ),
      ),
    ],
  );
}

class FoodBody extends StatefulWidget {
  FoodBody({Key key}) : super(key: key);

  _FoodBodyState createState() => _FoodBodyState();
}

class _FoodBodyState extends State<FoodBody> {
  Widget _makeFoodCard(BuildContext context, DocumentSnapshot restaurant) {
    // if (restaurant == null) {
    //   return Container();
    // }

    String imageUrl = restaurant.data['image_url'];
    if (imageUrl == null) {
      imageUrl = 'https://via.placeholder.com/500x500?text=Error+Loading+Image';
    }
    return Container(
      padding: EdgeInsets.all(7),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => FoodItemPage(restaurant)));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            color: Colors.white,
            child: InkWell(
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(),
                errorWidget: (context, url, error) => Container(child: Center(child: Text('Error Loading Image..'))),
                // placeholder: kTransparentImage,
                imageUrl: imageUrl,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                fadeInDuration: Duration(milliseconds: 250),
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
      padding: EdgeInsets.symmetric(horizontal: 7),
      child: ScrollConfiguration(
        behavior: NoOverscrollBehavior(),
        child: ListView(
          padding: EdgeInsets.only(top: 20.0),
          children: <Widget>[
            _builderEnterCaloriesButton(),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('food').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData | snapshot.hasError) {
                  return Container();
                }

                return GridView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
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

  FoodItems({Key key, this.restaurant, this.searchText}) : super(key: key);

  _FoodItemsState createState() => _FoodItemsState();
}

List<Widget> _buildExpansionButtons(BuildContext context, int quantity, Function setQuantity) {
  return [
    SizedBox(height: 2),
    Container(
      height: 25,
      width: 150,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        color: Colors.purple.withOpacity(0.5),
        onPressed: () {
          _showLogDialog(context, setQuantity, quantity);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.white),
                children: <TextSpan>[
                  TextSpan(text: 'Quantity '),
                  TextSpan(text: quantity == 0 ? '1/2' : quantity.toString()),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.3))
          ],
        ),
      ),
    ),
    SizedBox(height: 10),
    Container(
      height: 25,
      width: 150,
      child: FlatButton(
        color: Colors.teal.withOpacity(0.5),
        onPressed: () {},
        child: Text('Add To Meal', style: TextStyle(color: Colors.white)),
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
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Material(
                          color: Colors.transparent,
                          child: Theme(
                            data: ThemeData(accentColor: Colors.white, unselectedWidgetColor: Colors.white),
                            child: ExpansionTile(
                              onExpansionChanged: (bool state) {},
                              title: Text(meal, style: TextStyle(color: Colors.white, fontSize: 14)),
                              // trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white),
                              children: _buildExpansionButtons(context, quantity, _setQuantity),
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
  final DocumentSnapshot restaurant;

  FoodItemPage(this.restaurant);

  @override
  _FoodItemPageState createState() => _FoodItemPageState();
}

class _FoodItemPageState extends State<FoodItemPage> {
  TextEditingController _searchController = new TextEditingController();
  String searchText;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchText = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff170422),
        title: Text(widget.restaurant.documentID),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff170422), Color(0xff9B22E6)],
            stops: [0.75, 1],
          ),
        ),
        child: Column(
          children: <Widget>[
            SearchBar(controller: _searchController, hintText: 'Search', topMargin: 5, bottomMargin: 6),
            FoodItems(restaurant: widget.restaurant, searchText: searchText)
          ],
        ),
      ),
    );
  }
}

class QuantityRadioList extends StatefulWidget {
  final Function setQuantity;
  final int quantity;
  QuantityRadioList(this.setQuantity, this.quantity);

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
        padding: EdgeInsets.all(0),
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
        contentPadding: EdgeInsets.all(0),
        titlePadding: EdgeInsets.all(5),
        content: Container(
          height: 250,
          width: 200,
          alignment: Alignment.center,
          child: QuantityRadioList(setQuantity, quantity),
        ),
        actions: <Widget>[
          FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.grey[200],
              textColor: Colors.black,
              child: Text('Cancel', style: TextStyle(fontSize: 16)),
              onPressed: () => Navigator.of(context).pop()),
          FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.grey[200],
              textColor: Colors.black,
              child: Text('Select', style: TextStyle(fontSize: 16)),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
    },
  );
}
