import 'package:flutter/material.dart';
import "package:loadcellapp/backend/displayPref.dart";
import "package:loadcellapp/backend/font.dart";
import "package:loadcellapp/backend/data.dart";

class SettingsPage extends StatefulWidget {
  @override createState() =>
      SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>{

  List<DropdownMenuItem<String>> appPrefMenuItems;
  List<DropdownMenuItem<String>> scalePrefMenuItems;
  List<DropdownMenuItem<String>> userMenuItems;

  String selectedUser;
  String selectedAppPref;
  String selectedScalePref;

  Map<String,String> userNamesToFBkeys;

  @override
  void initState(){
    super.initState();

    userMenuItems = buildDropDownList(["--Loading--"]);
    selectedUser = "--Loading--";
    // Default values displayed on app while data is loading

    Data.getFBkeysToScaleLabel().then((map){
      setState((){
        userNamesToFBkeys = map;
        List<String> _userNames = List<String>();

          map.keys.forEach((key){
            _userNames.add(key);
          });

        userMenuItems = buildDropDownList(_userNames);
        selectedUser = _userNames[0];
      });
    });

    appPrefMenuItems = buildDropDownList(["Weight","Percentage","Volume"]);
    scalePrefMenuItems = buildDropDownList(["Weight","Percentage","Volume"]);

    DisplayPref.getAppPreference().then((value){
      setState((){
        selectedAppPref = value;
      });
    });

    DisplayPref.getScalePreference().then((value){
      setState((){
        selectedScalePref = value;
      });
    });

  }

  List<DropdownMenuItem<String>> buildDropDownList(List<String> preferences){
    List<DropdownMenuItem<String>> items = List();
    for (String preference in preferences){
      items.add(
        DropdownMenuItem(
          value: preference,
          child: Text(preference,
          style: Font.style(15, Colors.white),
          )
          ),
        );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.amber[300],
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        centerTitle: true,
        title: Text("Settings",style:Font.style(20.0, Colors.white)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
      children:<Widget>[
        Padding(padding: EdgeInsets.symmetric(vertical: 45)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    "Change Display on Mobile App to",
                    style:Font.style(18.0, Colors.black54,),
                    textAlign: TextAlign.center),
                  constraints: BoxConstraints.tightFor(width:170),
                  margin: EdgeInsets.symmetric(vertical:5)
                ),
                Container(
                  child: Image.asset("lib/assets/images/smartphone.png"),
                  constraints: BoxConstraints.tightFor(width:150,height:150),
                  margin: EdgeInsets.symmetric(vertical:5)
                ),
                Container(
                  decoration:BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  constraints: BoxConstraints.tightFor(width:165),
                  alignment:Alignment.center,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.amber[700]
                    ),
                    child:DropdownButton(
                    value: selectedAppPref,
                    items: appPrefMenuItems,
                    onChanged: (String newPref){
                      setState((){
                        selectedAppPref = newPref;
                      });
                    },
                  ))),
                ],
            ),
            Padding(padding:EdgeInsets.symmetric(horizontal: 15)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    "Change Display on Smart Scale to",
                    style:Font.style(18.0, Colors.black54,),
                    textAlign: TextAlign.center),
                  constraints: BoxConstraints.tightFor(width:170),
                  margin: EdgeInsets.symmetric(vertical:5)
                ),
                Container(
                  child: Image.asset("lib/assets/images/digital_scale.png"),
                  constraints: BoxConstraints.tightFor(width:150,height:150),
                  margin: EdgeInsets.symmetric(vertical:5),
                ),
                Container(
                  decoration:BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  constraints: BoxConstraints.tightFor(width:165),
                  alignment:Alignment.center,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.amber[700]
                    ),
                    child:DropdownButton(
                      value: selectedScalePref,
                      items: scalePrefMenuItems,
                      onChanged: (String newPref){
                        setState((){
                          selectedScalePref = newPref;
                        });
                      },
                      ))),
                Container(
                  child: Text(
                    "for the Smart Scale",
                    style: Font.style(18.0, Colors.black54),
                    ),
                  padding: EdgeInsets.only(top:15),
                ),
                Container(
                  child: Text(
                    "labelled:",
                    style: Font.style(18.0, Colors.black54),
                  ),
                  padding: EdgeInsets.only(bottom:15),
                ),
                Container(
                    decoration:BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    constraints: BoxConstraints.tightFor(width:165),
                    alignment:Alignment.center,
                    child: Theme(
                        data: Theme.of(context).copyWith(
                            canvasColor: Colors.amber[700]
                        ),
                        child:DropdownButton(
                          value: selectedUser,
                          items: userMenuItems,
                          onChanged: (String newPref){
                            setState((){
                              selectedUser = newPref;
                            });
                          },
                        )))
              ],
            ),
          ]
        ),
        Padding(padding: EdgeInsets.symmetric(vertical:50)),
         _buildApplyChanges(_scaffoldKey),
      ])
    );
  }

  Widget _buildApplyChanges( GlobalKey<ScaffoldState> _scaffoldKey){
    return FlatButton(
      child: Container(
          child: Text("Apply Changes",
            style:Font.style(17,Colors.white),
            textAlign: TextAlign.center,
          ),
          constraints: BoxConstraints.tightFor(width:350, height:60),
          alignment: Alignment.center
      ),
      color: Colors.amber[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      onPressed: (){
        DisplayPref.setAppPreferance(selectedAppPref);
        DisplayPref.setScalePreferance(selectedScalePref, userNamesToFBkeys[selectedUser]);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Changes Applied Successfully", style:Font.style(12,Colors.white)),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.amber[700]
        ));
      },
    );
  }

}