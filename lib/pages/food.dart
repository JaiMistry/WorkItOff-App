import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FoodPage extends StatelessWidget {
  // const FoodPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FoodBody();
  }
}

class FoodBody extends StatefulWidget {
  FoodBody({Key key}) : super(key: key);

  _FoodBodyState createState() => _FoodBodyState();
}

class _FoodBodyState extends State<FoodBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('food').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData | snapshot.hasError) {
            return LinearProgressIndicator();
            // return Text('Loading...');
          }

          print(snapshot.data.documents.length);

          snapshot.data.documents.forEach((place) {
            print(place.documentID);
            print(place.data);
          });
          
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot resturant = snapshot.data.documents[index];
              String resturantName = resturant.documentID.toString();

              return ListTile(
                title: Row(
                  children: <Widget>[
                    Text(resturantName),
                    Image.network(resturant.data['image_url'], width: 200.0,)
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
