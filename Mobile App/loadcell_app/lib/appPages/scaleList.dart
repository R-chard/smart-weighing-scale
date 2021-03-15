import "package:flutter/material.dart";
import 'package:loadcellapp/backend/productSpecs.dart';
import "package:loadcellapp/backend/font.dart";
import "package:loadcellapp/backend/data.dart";
import "package:loadcellapp/backend/displayPref.dart";
import "newScale.dart";
import "package:loadcellapp/main.dart";
import "package:percent_indicator/linear_percent_indicator.dart";

class SmartScaleList extends StatefulWidget {
  @override createState() =>
      SmartScaleListState();
}

class SmartScaleListState extends State<SmartScaleList>{
  // TODO: make refreshKey work

  GlobalKey<RefreshIndicatorState> refreshKey;
  String appPref;

  @override
  void initState() {
    super.initState();

    DisplayPref.getAppPreference().then((preference) {
      setState(() {
        appPref = preference;
      });
    });
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor:Colors.amber[300],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage())
            );
          }
        ),
        title: Text("Smart Scale List",style:Font.style(20.0, Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => NewScale()));
            }
          )
        ],
        centerTitle: true,
        backgroundColor: Colors.amber[700],
      ),
       body: RefreshIndicator(
         child:FutureBuilder(
           future: Data.getData(),
             // retrieves data from database in the form of a data array
           builder: (BuildContext context, AsyncSnapshot snapshot) {
             // snapshot is the data you get when future function is completed
             if (!snapshot.hasData) {
               return Container(
                 child: Center(
                   child: Text("Loading...",
                     style:Font.style(20,Colors.white))
                   )
               );
             } else {
               return ListView.builder(
                   itemCount: snapshot.data.length,
                   itemBuilder: (BuildContext context, int index)=>
                       _renderListBody(context, index, snapshot)
               );
             }
           }
         ),
          key: refreshKey,
         onRefresh: refreshPage,
       )
    );
  }

  Future<void> refreshPage() async{
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  Widget _renderListBody(BuildContext context,int index, AsyncSnapshot snapshot) {

    String displayText;

    switch (appPref) {
      case "Weight":
        displayText = "Weight of item:";
        break;
      case "Percentage":
        displayText = "Percentage left:";
        break;
      case "Volume":
        displayText = "Volume left:";
        break;
      default:
        setState((){
          displayText = "Error";
        });
        break;
    }

    return Card(
      color: Colors.white,
      child: Opacity(
        opacity: 1.0,
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top:10)),
              Text(
                snapshot.data[index].label,
                style:Font.style(18,Colors.black54)),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              _genProductDetails("Item Name:", snapshot.data[index].productSpecs.itemName),
              _genProductDetails("Remarks:", snapshot.data[index].remarks),
              _genProductDetails(displayText, ""),
              Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 10)),
              _generateBar(snapshot.data[index].weight, snapshot.data[index].productSpecs)
            ]
          ) //leading: ,
      ))
    );
  }

  Widget _genProductDetails(String frontString, String backString){

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          constraints: BoxConstraints.tightFor(width: 150),
          child: Text(
            frontString,
            style: Font.style(15,Colors.black45)
          )
        ),
        Container(
          constraints: BoxConstraints.tightFor(width: 200),
          child:Text(
            backString,
            style: Font.style(16,Colors.black54)
          )
        )
      ]
    );
  }

  Widget _generateBar(String weight, ProductSpecs pSpecs){

    String displayText;

    if (double.tryParse(weight) == null){
      return Container(
        padding: EdgeInsets.symmetric(vertical:15),
        constraints: BoxConstraints.tightFor(width:400),
        child: Text(
          "Scale not Connected",
          style: Font.style(16, Colors.black45),
          textAlign: TextAlign.center)
      );
    }
    // weight might not been set yet. In which case it would just be "loading"

    else {
      double _weight = double.parse(weight);
      double maxW = double.parse(pSpecs.maxW);
      double minW = double.parse(pSpecs.minW);
      double capacity = double.parse(pSpecs.capacity);

      double percent = (_weight - minW) / (maxW - minW);
      double volume = percent * capacity;


      switch (appPref) {
        case "Weight":
          displayText = _weight.toStringAsFixed(2) + "kg";
          break;
        case "Percentage":
          displayText = (percent*100).toStringAsFixed(2) + "%";
          break;
        case "Volume":
          displayText = volume.toInt().toString() + "ml";
          break;
        default:
          setState(() {
            displayText = "Error";
          });
          break;
      }

      if (percent> 1.0){
        percent = 1.0;
      }

      else if (percent<0){
        percent = 0.0;
      }

      Color _percentColor;
      if (percent > 0.7) {
        _percentColor = Colors.green[400];
      }
      else if (percent > 0.4) {
        _percentColor = Colors.amberAccent[400];
      }
      else if (percent > 0.2) {
        _percentColor = Colors.orangeAccent[400];
      }
      else {
        _percentColor = Colors.red[400];
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal:35),
        child: LinearPercentIndicator(
            lineHeight: 25,
            width: 300,
            percent: percent,
            animation: true,
            animationDuration: 1500,
            center: Text(
                displayText,
                style: Font.style(14, Colors.white)),
            progressColor: _percentColor,
            backgroundColor: Colors.grey[400]
        ),
      );
    }
  }
}
