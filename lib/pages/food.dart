import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';

class FoodPage extends StatefulWidget {
  // const FoodPage({Key key}) : super(key: key);

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  TextEditingController _searchController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _buildSearchBar(),
          // _builderEnterCaloriesButton(),
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

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.only(top: 40.0, left: 8.0, right: 8.0),
      // padding: EdgeInsets.only(bottom: 0.0),
      decoration: BoxDecoration(border: Border.all(width: 1.0), color: Colors.transparent),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: Color(0xff5a5a5a)),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, size: 20, color: Colors.grey),
            onPressed: () => _searchController.clear(),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none)),
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

Widget _builderEnterCaloriesButton() {
  return Column(
    children: <Widget>[
      SizedBox(height: 20),
      Text("Can't find your cheat meal?", style: TextStyle(fontSize: 20, color: Color(0xff4ff7d3))),
      SizedBox(height: 12),
      Container(
        alignment: Alignment.center,
        width: 180,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xff9B22E6), Color(0xff4ff7d3)],
            stops: [0.1, 1],
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
    if (restaurant == null) {
      return Container();
    }

    String imageUrl = restaurant.data['image_url'];
    if (imageUrl == null) {
      imageUrl = 'https://via.placeholder.com/500x500?text=Error+Loading+Image';
    }
    return Container(
      padding: EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          print(restaurant.documentID);
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => FoodItemPage(restaurant)));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            color: Colors.white,
            child: InkWell(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: imageUrl,
                width: 175,
                height: 175,
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
      padding: EdgeInsets.only(left: 10, right: 10),
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('food').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData | snapshot.hasError) {
            return Container();
            // return Text('Loading...');
          }
          // print(snapshot.data.documents.length);

          // snapshot.data.documents.forEach((place) {
          //   print(place.documentID);
          //   print(place.data);
          // });

          return ScrollConfiguration(
            behavior: NoOverscrollBehavior(),
            child: ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot restaurant = snapshot.data.documents[index];
                DocumentSnapshot nextRestaurant;
                // String restaurantName = restaurant.documentID.toString();
                // print(index);
                // print(snapshot.data.documents.length);
                if (index + 1 < snapshot.data.documents.length) {
                  nextRestaurant = snapshot.data.documents[index + 1];
                }

                if (index.isEven || index == snapshot.data.documents.length) {
                  return Row(
                    mainAxisAlignment: nextRestaurant != null ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: <Widget>[
                      _makeFoodCard(context, restaurant),
                      _makeFoodCard(context, nextRestaurant),
                    ],
                  );
                }

                return Container();
              },
            ),
          );
        },
      ),
    );
  }
}

//*  FOOD ITEM PAGE //*

class FoodItemPage extends StatelessWidget {
  final DocumentSnapshot restaurant;

  FoodItemPage(this.restaurant);
  // const FoodItemPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff170422),
        title: Text(restaurant.documentID),
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
      ),
    );
  }
}

class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
