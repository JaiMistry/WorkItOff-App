import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
                return GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot restaurant =
                        snapshot.data.documents[index];
                    return _filter == null || _filter == ''
                        ? _makeFoodCard(context, snapshot.data.documents[index])
                        : restaurant.documentID.toLowerCase().contains(_filter.toLowerCase())
                            ? _makeFoodCard(context, restaurant)
                            : Container();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//*  FOOD ITEM PAGE //*

class FoodItems extends StatefulWidget {
  final DocumentSnapshot restaurant;
  FoodItems({Key key, this.restaurant}) : super(key: key);

  _FoodItemsState createState() => _FoodItemsState();
}

List<Widget> _buildExpansionButtons() {
  return [
    SizedBox(height: 3),
    Container(
      height: 30,
      width: 150,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        color: Colors.purple.withOpacity(0.5),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.white),
                children: <TextSpan>[
                  TextSpan(text: 'Quantity '),
                  TextSpan(text: '1'),
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
      height: 30,
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
                  mealList.add(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: ExpansionTile(
                          title: Text(meal, style: TextStyle(color: Colors.white, fontSize: 14)),
                          trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white),
                          children: _buildExpansionButtons(),
                        ),
                      ),
                    ),
                  );
                });

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
            FoodItems(
              restaurant: widget.restaurant,
            )
          ],
        ),
      ),
    );
  }
}
