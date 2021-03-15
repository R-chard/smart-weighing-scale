import 'package:flutter/material.dart';
import 'package:loadcellapp/backend/font.dart';
import 'package:loadcellapp/backend/productSpecs.dart';
import 'package:loadcellapp/main.dart';
import 'newItem.dart';

class LoadList extends StatefulWidget {
  @override createState() =>
      LoadListState();
}

class LoadListState extends State<LoadList> {
  List<ProductSpecs> specs = List<ProductSpecs>();
  List<String> keyList = List<String>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState(){
    super.initState();
    ProductSpecs.getKeyList().then((_keyList){
      if (_keyList != null){
        buildSpecs(_keyList);
      }
    });
  }

  buildSpecs(List<String> _keylist){
    _keylist.forEach((key){
      setState((){
        keyList.add(key);
      });

      ProductSpecs.getItemSpecs(key).then((_specs){
        setState((){
          specs.add(_specs);
        });

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:_scaffoldKey,
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
        title: Text("Item List",style:Font.style(20.0, Colors.white)),
        actions: [IconButton(
        icon: Icon(Icons.add),
        tooltip: "Add new load",
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
          builder: (context) => NewLoad()));
        }
        )],
        centerTitle: true,
        backgroundColor: Colors.amber[700],
      ),
      body: ListView.builder(
        itemCount: keyList == null ? 0 : keyList.length,
        itemBuilder: (context, int index)=>
            _renderListBody(context, index)
      )
    );

  }

  Widget _renderListBody(BuildContext context, int index){

    String itemRemoved;
    return Dismissible(
        key: Key(keyList[index]),
        onDismissed: (direction) {
          setState(() {
            itemRemoved = keyList[index];
            ProductSpecs.removeKey(itemRemoved);
            keyList.removeAt(index);
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Removed $itemRemoved", style:Font.style(12,Colors.white)),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.amber[700]
          ));
        },
        child:Card(
          child: ListTile(
            title: Container(
              child:Text(
                keyList[index],
                style: Font.style(18, Colors.black),
              ),
              padding: EdgeInsets.symmetric(vertical:10),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                styleText("Maximum weight: ","${specs[index].maxW}kg\n"),
                styleText("Manimum weight: ","${specs[index].minW}kg\n"),
                styleText("Capacity: ","${specs[index].capacity}ml")
              ]
            ),
            trailing: _generateWineBottle(index)
            ),
        )
    );
  }

  Widget _generateWineBottle(int index){
    // creates an image from the list of bottle images
    if (index >5){
      // currently only 6 wine bottles
      index -= 6;
    }
    return Container(
      constraints: BoxConstraints.tightFor(height:100, width: 80),
      child: Image.asset("lib/assets/images/wine_bottles/wine${index+1}.png")
    );
  }

  Widget styleText(String frontString, String backString){
    return Container(
      constraints: BoxConstraints.tightFor(height:20),
      child:RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: frontString,
              style: Font.style(15, Colors.black45)),
            TextSpan(
                text: backString,
                style: Font.style(16, Colors.green[500])),
          ]
        )
      )
    );
  }
}