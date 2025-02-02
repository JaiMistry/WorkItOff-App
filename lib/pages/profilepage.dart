// import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:workitoff/providers/navbar_provider.dart';
import 'package:workitoff/providers/user_provider.dart';

import 'package:workitoff/widgets.dart';
// import 'package:workitoff/auth/auth.dart';

class StandardTextInputField extends StatefulWidget {
  final String label;
  final String failedValidateText;
  final TextEditingController controller;

  StandardTextInputField({Key key, this.label: '', this.failedValidateText: '', @required this.controller})
      : super(key: key);

  _StandardTextInputFieldState createState() => _StandardTextInputFieldState();
}

class _StandardTextInputFieldState extends State<StandardTextInputField> {
  final _focusNode = FocusNode();
  Color _labelColor = Colors.grey;

  @override
  void initState() {
    _focusNode.addListener(_updateLabelColor);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_updateLabelColor); // Clean up listener to prevent memory leak
    _focusNode.dispose(); // Clean up the focus node when the Form is disposed.
    super.dispose();
  }

  void _updateLabelColor() {
    setState(() {
      _focusNode.hasFocus ? _labelColor = Color(0xff4ff7d3) : _labelColor = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Text(widget.label, style: TextStyle(color: _labelColor)),
          ),
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            validator: (string) {
              if (string.isEmpty || !isNumeric(string)) {
                return widget.failedValidateText;
              }
              return null;
            },
            inputFormatters: [LengthLimitingTextInputFormatter(3)],
            keyboardType: TextInputType.number,
            cursorColor: const Color(0xff4ff7d3),
            decoration: InputDecoration(
              focusedBorder: const UnderlineInputBorder(
                borderSide: const BorderSide(style: BorderStyle.none),
                borderRadius: const BorderRadius.all(Radius.zero),
              ),
              filled: true,
              fillColor: const Color(0xffd1d1d1).withOpacity(0.15),
              labelStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.all(8.0),
              enabledBorder: const OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.zero),
                borderSide: const BorderSide(style: BorderStyle.none),
              ),
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class GenderRadio extends StatefulWidget {
  final String initialVal;
  GenderRadio({Key key, this.initialVal: ''}) : super(key: key);

  _GenderRadioState createState() => _GenderRadioState();
}

class _GenderRadioState extends State<GenderRadio> {
  int _selected = 0; // 0 = male, 1 = female, 2+ = none
  Map<int, Color> _genderMapping = {0: Colors.white, 1: Colors.white}; // Handles whether item is selected or not

  @override
  void initState() {
    widget.initialVal == 'female' ? _onRadioChanged(1) : _onRadioChanged(0);
    super.initState();
  }

  @override
  void didUpdateWidget(GenderRadio oldWidget) {
    widget.initialVal == 'female' ? _onRadioChanged(1) : _onRadioChanged(0);
    super.didUpdateWidget(oldWidget);
  }

  void _onRadioChanged(int value) {
    setState(() {
      _selected = value;
      _genderMapping[value] = Color(0xff4ff7d3); // Change the slected item color
      value == 0 ? _genderMapping[1] = Colors.white : _genderMapping[0] = Colors.white; // Unslected item
    });
  }

  List<Widget> makeRadios() {
    List<String> twoGenders = ['Male', 'Female'];
    List<Widget> list = List<Widget>();

    for (int i = 0; i < twoGenders.length; i++) {
      list.add(Material(
        color: Colors.transparent,
        child: Theme(
          data: ThemeData.dark(),
          child: RadioListTile(
            value: i,
            controlAffinity: ListTileControlAffinity.trailing,
            dense: true,
            title: Text(twoGenders.elementAt(i), style: TextStyle(fontSize: 14.0, color: _genderMapping[i])),
            activeColor: const Color(0xff4ff7d3),
            groupValue: _selected,
            onChanged: (val) {
              Provider.of<GenderProvider>(context).gender = val == 1 ? 'female' : 'male';
              _onRadioChanged(val);
            },
          ),
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: makeRadios(),
      ),
    );
  }
}

class BuildProfileForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController ageController;
  final TextEditingController weightController;
  final String initialGender;
  BuildProfileForm({
    Key key,
    @required this.formKey,
    @required this.ageController,
    @required this.weightController,
    @required this.initialGender,
  }) : super(key: key);

  _BuildProfileFormState createState() => _BuildProfileFormState();
}

class _BuildProfileFormState extends State<BuildProfileForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            StandardTextInputField(
              label: 'Weight',
              failedValidateText: 'Enter your weight.',
              controller: widget.weightController,
            ),
            const SizedBox(height: 15.0),
            StandardTextInputField(
              label: 'Age',
              failedValidateText: 'Enter your age.',
              controller: widget.ageController,
            ),
            Container(
              padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0, bottom: 19.0),
              alignment: Alignment.centerLeft,
              child: const Text('Gender', style: TextStyle(color: Color(0xff4ff7d3))),
            ),
            GenderRadio(initialVal: widget.initialGender)
          ],
        ),
      ),
    );
  }
}

class WebsiteLinks extends StatelessWidget {
  const WebsiteLinks({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Container(
            child: const Text(
              "Visit our website and contact us to suggest new restaurants or workouts you'd like to see!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.0),
            ),
          ),
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              alignment: Alignment.centerLeft,
              child: const Text("Website", style: TextStyle(color: Color(0xff4ff7d3))),
            ),
            onTap: () async {
              if (await canLaunch("https://workitoffapp.com")) {
                await launch("https://workitoffapp.com");
              }
            },
          ),
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              alignment: Alignment.centerLeft,
              child: Container(
                child: const Text("Terms of Service", style: TextStyle(color: Color(0xff4ff7d3))),
              ),
            ),
            onTap: () async {
              if (await canLaunch("https://workitoffapp.com/terms.html")) {
                await launch("https://workitoffapp.com/terms.html");
              }
            },
          ),
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              alignment: Alignment.centerLeft,
              child: const Text("Privacy Policy", style: TextStyle(color: Color(0xff4ff7d3))),
            ),
            onTap: () async {
              if (await canLaunch("https://workitoffapp.com/privacy.html")) {
                await launch("https://workitoffapp.com/privacy.html");
              }
            },
          ),
        ],
      ),
    );
  }
}

class GenderProvider with ChangeNotifier {
  String _gender = '';

  set gender(String newGender) {
    _gender = newGender;
    notifyListeners();
  }

  String get gender => _gender;
}

class ProfilePageData extends StatefulWidget {
  ProfilePageData({Key key}) : super(key: key);

  _ProfilePageDataState createState() => _ProfilePageDataState();
}

class _ProfilePageDataState extends State<ProfilePageData> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _ageController.dispose(); // Clean up controller when widget is disposed
    _weightController.dispose(); // Clean up controller when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WorkItOffUser user = Provider.of<WorkItOffUser>(context);
    _weightController.text = user != null ? user.weight.toString() : '0';
    _ageController.text = user != null ? user.age.toString() : '0';
    return ChangeNotifierProvider(
      builder: (context) => GenderProvider(),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: const Text('Profile', style: TextStyle(fontSize: 18.0)),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: NoOverscrollBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    BuildProfileForm(
                      formKey: _formKey,
                      ageController: _ageController,
                      weightController: _weightController,
                      initialGender: user != null ? user.gender : 'male',
                    ),
                    const WebsiteLinks(),
                  ],
                ),
              ),
            ),
          ),
          UpdateProfileBtn(
            formKey: _formKey,
            ageController: _ageController,
            weightController: _weightController,
          )
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: getBasicGradient(),
      child: Container(
        constraints: const BoxConstraints.expand(),
        child: ProfilePageData(),
      ),
    );
  }
}

class UpdateProfileBtn extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController ageController;
  final TextEditingController weightController;

  UpdateProfileBtn({
    Key key,
    @required this.formKey,
    @required this.ageController,
    @required this.weightController,
  }) : super(key: key);

  _UpdateProfileBtnState createState() => _UpdateProfileBtnState();
}

class _UpdateProfileBtnState extends State<UpdateProfileBtn> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: 350), vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    String gender = Provider.of<GenderProvider>(context).gender;
    int age = int.parse(widget.ageController.text);
    int weight = int.parse(widget.weightController.text);

    await Provider.of<WorkItOffUser>(context).updateProfile(age: age, gender: gender, weight: weight).then((onValue) {
      showDefualtFlushBar(context: context, text: 'Profile Updated!');
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      showDefualtFlushBar(context: context, text: 'Connection timed out.');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<NavBarProvider>(context).currentPage == 3) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    MediaQueryData mQ = MediaQuery.of(context);
    double padding = mQ.viewInsets.bottom != 0.0 ? mQ.viewInsets.bottom : mQ.padding.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: padding),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _animationController, curve: Curves.linear),
        child: Container(
          width: double.infinity,
          child: FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Removed all padding
            padding: EdgeInsets.zero,
            color: const Color(0xff4ff7d3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
            child: const Text("Update Profile", style: TextStyle(fontSize: 18.0)),
            onPressed: () {
              // If the form validates
              if (widget.formKey.currentState.validate()) {
                _updateProfile();
              }
            },
          ),
        ),
      ),
    );
  }
}
