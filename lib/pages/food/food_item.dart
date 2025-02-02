import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workitoff/navigation_bar.dart';
import 'package:workitoff/providers/user_provider.dart';
import 'food_item_provider.dart';
import 'package:workitoff/widgets.dart';

final BottomNavigationBar navBar = navBarGlobalKey.currentWidget;

class FoodItemPage extends StatefulWidget {
  final Function setPage;

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
    DocumentSnapshot _restuarant = Provider.of<FoodItemProvider>(context).currentRestuarant;
    return Container(
      decoration: getBasicGradient(),
      child: WillPopScope(
        onWillPop: () {
          widget.setPage(0);
          return Future.value(false); // Dont actually go back. I only want to run the function above
        },
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Container(
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      widget.setPage(0);
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _restuarant == null ? 'Placeholder' : _restuarant.documentID,
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  SearchBar(controller: _searchController, hintText: 'Search', topMargin: 5, bottomMargin: 6),
                  FoodItems(restaurant: _restuarant, searchText: searchText, setPage: widget.setPage)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodItems extends StatefulWidget {
  final DocumentSnapshot restaurant;
  final String searchText;
  final Function setPage;

  FoodItems({
    Key key,
    @required this.restaurant,
    @required this.searchText,
    @required this.setPage,
  }) : super(key: key);

  _FoodItemsState createState() => _FoodItemsState();
}

Widget _enterMealsButton(
  BuildContext context,
  AnimationController controller,
  bool isButtonDisabled,
  int count,
  Function resetCart,
  List<String> meals,
  List<dynamic> quantities,
  FoodItems widget,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: controller, curve: Curves.linear),
    child: Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      width: MediaQuery.of(context).size.width,
      child: FlatButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        color: const Color(0xff4ff7d3),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Text("Enter Meal ($count)", style: TextStyle(fontSize: 18.0)),
        onPressed: () {
          return isButtonDisabled
              ? null
              : _mealDialog(
                  context,
                  controller,
                  resetCart,
                  meals,
                  quantities,
                  widget.setPage,
                  widget.restaurant.documentID,
                );
        },
      ),
    ),
  );
}

Future<void> _callCloudFucntion(String userID, String restaurantName, Map mealsMap) async {
  if (mealsMap.isEmpty) return;
  String functionMap = json.encode({
    "userID": userID,
    "restaurantName": restaurantName,
    "mealsMap": mealsMap,
  });
  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'addMeals',
  );

  try {
    dynamic resp = await callable.call(json.decode(functionMap));
  } catch (e) {
    debugPrint('An error has occured');
  }
}

Future<void> _mealDialog(
  BuildContext context,
  AnimationController controller,
  Function resetCart,
  List<String> meals,
  List<dynamic> quantities,
  Function setPage,
  String restaurantName,
) async {
  WorkItOffUser user = Provider.of<WorkItOffUser>(context, listen: false);

  if (Platform.isIOS) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Log Meal?'),
          content: Text('Cart: ${meals.join(", ")} (${quantities.join(",")})'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: const Text('Empty Cart', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  resetCart();
                  Navigator.of(context).pop();
                }),
            CupertinoDialogAction(
                child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                onPressed: () => Navigator.of(context).pop()),
            CupertinoDialogAction(
              child: const Text('Log', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              onPressed: () {
                Map<String, double> _mealsMap = {};
                meals.asMap().forEach((i, meal) {
                  _mealsMap[meal] = quantities.elementAt(i).toDouble();
                });
                _callCloudFucntion(user.id, restaurantName, _mealsMap);
                resetCart();
                setPage(0);
                // TODO: Scroll to top of page
                Navigator.of(context).pop();
                navBar.onTap(0);
              },
            ),
          ],
        );
      },
    );
  } else if (Platform.isAndroid) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Meal?'),
          content: Text('Cart: ${meals.join(", ")} (${quantities.join(",")})'),
          actions: <Widget>[
            FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.grey[200],
                textColor: Colors.black,
                child: Text('Empty Cart'),
                onPressed: () {
                  resetCart();
                  Navigator.of(context).pop();
                }),
            FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.grey[200],
                textColor: Colors.black,
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop()),
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.grey[200],
              textColor: Colors.black,
              child: const Text('Log', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Map<String, double> _mealsMap = {};
                meals.asMap().forEach((i, meal) {
                  _mealsMap[meal] = quantities.elementAt(i).toDouble();
                });
                _callCloudFucntion(user.id, restaurantName, _mealsMap);
                resetCart();
                setPage(0);
                // TODO: Scroll to top of page
                Navigator.of(context).pop();
                navBar.onTap(0);
              },
            ),
          ],
        );
      },
    );
  }
}

class _FoodItemsState extends State<FoodItems> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  List<String> listOfMeals = [];
  List<dynamic> quantityOfMeals = [];
  bool isButtonDisabled = true;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addToCart(String meal, dynamic quantity) {
    setState(() {
      count++;
      listOfMeals.add(meal);
      quantityOfMeals.add(quantity);
      _animationController.forward();
      isButtonDisabled = false;
    });
  }

  void _resetCart() {
    setState(() {
      Provider.of<FoodItemProvider>(context, listen: false).currentRestuarant = null;
      listOfMeals.clear();
      quantityOfMeals.clear();
      _animationController.reverse();
      isButtonDisabled = true;
      count = 0;
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
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              ListView.builder(
                // shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (BuildContext contect, int index) {
                  if (widget.restaurant.data['meals'] == null || widget.restaurant.data['meals'].toString() == '{}') {
                    return Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: const Center(child: Text('No Meals Found.')),
                    );
                  }

                  Map<String, Map> categories = widget.restaurant.data['meals'].cast<String, Map>();
                  List<Widget> widgetList = [];

                  categories.forEach((categtory, mealMap) {
                    List<Widget> mealList = [];

                    Map<String, int> meals = mealMap.cast<String, int>();
                    meals.forEach((String meal, int cals) {
                      String searchText = widget.searchText;

                      //Only reutrn the food items that are being searched for
                      if (searchText == null ||
                          searchText == '' ||
                          meal.toLowerCase().contains(searchText.toLowerCase())) {
                        mealList.add(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Material(
                              color: Colors.transparent,
                              child: ExpansionBtn(meal: meal, key: Key('$meal'), addToCart: _addToCart),
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
                            ListTile(
                              title: Text(categtory, style: const TextStyle(color: Color(0xff4ff7d3), fontSize: 22)),
                            ),
                            Column(children: mealList)
                          ],
                        ),
                      );
                    }
                  });
                  return Column(children: widgetList);
                },
              ),
              _enterMealsButton(context, _animationController, isButtonDisabled, count, _resetCart, listOfMeals,
                  quantityOfMeals, widget)
            ],
          ),
        ),
      ),
    );
  }
}

class ExpansionBtn extends StatefulWidget {
  final String meal;
  final Function addToCart;
  ExpansionBtn({Key key, @required this.meal, this.addToCart}) : super(key: key);

  _ExpansionBtnState createState() => _ExpansionBtnState();
}

class _ExpansionBtnState extends State<ExpansionBtn> {
  int _quantity = 1;

  void _setQuantity(int newQuantity) {
    setState(() {
      _quantity = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(accentColor: Colors.white.withOpacity(0.7), unselectedWidgetColor: Colors.white.withOpacity(0.7)),
      child: ExpansionTile(
        onExpansionChanged: (bool state) {},
        title: Text(widget.meal, style: const TextStyle(color: Colors.white, fontSize: 14)),
        children: [
          const SizedBox(height: 2),
          Container(
            height: 25,
            width: 150,
            child: FlatButton(
              padding: const EdgeInsets.all(0),
              color: Colors.purple.withOpacity(0.5),
              onPressed: () {
                _showLogDialog(context, _setQuantity, _quantity);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white),
                      children: <TextSpan>[
                        const TextSpan(text: 'Quantity '),
                        TextSpan(text: _quantity == 0 ? '1/2' : _quantity.toString()),
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
                widget.addToCart(widget.meal, _quantity == 0 ? 0.5 : _quantity);
                showDefualtFlushBar(
                    context: context,
                    text: '${_quantity == 0 ? '1/2' : _quantity.toString()} ${widget.meal} added to cart.');
              },
              child: const Text('Add To Meal', style: TextStyle(color: Colors.white)),
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
            title: Text(index == 0 ? '1/2' : index.toString(), style: const TextStyle(color: Colors.black)),
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
