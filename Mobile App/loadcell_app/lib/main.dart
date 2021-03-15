import 'package:flutter/material.dart';
import "package:loadcellapp/backend/font.dart";
import "package:loadcellapp/appPages/scaleList.dart";
import "package:loadcellapp/appPages/settings.dart";
import "package:loadcellapp/appPages/itemList.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override Widget build(BuildContext context){
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
// home screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[700],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _renderHomeScreen(context),
      ),
    );
  }

  List<Widget> _renderHomeScreen(BuildContext context) {
    var children = List<Widget>();
    children.add(
        Container(
          // Builds the title
            padding: EdgeInsets.fromLTRB(0, 80, 0, 20),
            child: Text(
              "Smart\nWeighing Scale",
              textAlign: TextAlign.center,
              style: Font.style(40.0, Colors.white)
            )
        ));
    children.add(
      Container(
        child: Image.asset("lib/assets/images/weighing_scale.png"),
        constraints: BoxConstraints.tightFor(width:280,height:280),
        padding: EdgeInsets.only(bottom:30),
      )
    );
    children.add(
      Column(
        children: <Widget>[
          _buildchild("Notifications", context),
          Padding(padding:EdgeInsetsDirectional.only(top:15)),
          _buildchild("Smart Scale List", context),
          Padding(padding:EdgeInsetsDirectional.only(top:15)),
          _buildchild("Item List", context),
          Padding(padding:EdgeInsetsDirectional.only(top:15)),
          _buildchild("Settings", context),
        ]
      ),

      );
    return children;
  }

  Widget _buildchild(String text, BuildContext context) {
    // Buttons to navigate to other pages
    var _pagetoMove;

    if (text == "Smart Scale List"){
      _pagetoMove = SmartScaleList();
    }
    else if (text == "Item List"){
      _pagetoMove = LoadList();
    }
    else if (text == "Settings"){
      _pagetoMove = SettingsPage();
    }

    return GestureDetector(
        child: Container(
          child: Text(text,
            style:Font.style(17,Colors.black54),
            textAlign: TextAlign.center,
          ),
          decoration:BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25)
          ),
          constraints: BoxConstraints.tightFor(width: 340,height: 55),
          alignment: Alignment.center,
        ),

      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => _pagetoMove));
      },
    );
  }
}