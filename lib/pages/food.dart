import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';

class FoodPage extends StatelessWidget {
  // const FoodPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FoodBody(),
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

class FoodBody extends StatefulWidget {
  FoodBody({Key key}) : super(key: key);

  _FoodBodyState createState() => _FoodBodyState();
}

class _FoodBodyState extends State<FoodBody> {
  Widget _makeFoodCard(DocumentSnapshot restaurant) {
    if (restaurant == null) {
      return Container();
    }

    String imageUrl = restaurant.data['image_url'];
    if (imageUrl == null) {
      imageUrl = 'https://via.placeholder.com/500x500?text=Error+Loading+Image';
    }
    return Container(
      padding: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              // Center(child: CircularProgressIndicator()),
              Center(
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: imageUrl,
                  width: 175,
                  height: 175,
                  fit: BoxFit.contain,
                  fadeInDuration: Duration(milliseconds: 400),
                ),
              ),
            ],
          ),
          // child: Image.network(
          //   imageUrl,
          //   width: 175,
          //   height: 175,
          //   fit: BoxFit.contain,
          // ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
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
                      _makeFoodCard(restaurant),
                      _makeFoodCard(nextRestaurant),
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

class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
