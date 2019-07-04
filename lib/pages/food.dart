import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';

import 'package:workitoff/widgets.dart';

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
          Container(
            padding: EdgeInsets.only(bottom: 6),
            child: SearchBar(hintText: 'Search', controller: _searchController),
          ),
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
      padding: EdgeInsets.all(7),
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
                    DocumentSnapshot restaurant = snapshot.data.documents[index];
                    return _makeFoodCard(context, restaurant);
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
