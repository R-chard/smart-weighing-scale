import "package:flutter/material.dart";
import "package:loadcellapp/backend/data.dart";
import "package:loadcellapp/backend/font.dart";
import "package:loadcellapp/backend/productSpecs.dart";
import "package:loadcellapp/backend/displayPref.dart";
import "scaleList.dart";

class NewScale extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewScaleState();
  }
}

class NewScaleState extends State<NewScale>{

  String _label;
  String _remarks;
  List<String> itemList = ["--Select Item--"];
  List<ProductSpecs> specsList = List<ProductSpecs>();
  List<DropdownMenuItem<String>> itemMenu = List<DropdownMenuItem<String>>();
  String selectedItem;
  String scalePreference;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState(){
    super.initState();
    selectedItem = itemList[0];

    DisplayPref.getScalePreference().then((preference){
      setState((){
        scalePreference = preference;
      });
    });

    ProductSpecs.getKeyList().then((keyList){
      // get stored info about user-added product
      if (keyList.isNotEmpty) {
        keyList.forEach((key) {
          setState(() {
            itemList.add(key);
          });

          ProductSpecs.getItemSpecs(key).then((_specsList) {
            setState(() {
              specsList.add(_specsList);
            });
          });
        });
      }
      setState((){
        itemMenu = buildDropDownList(itemList);
      });
    });
  }

  Widget _buildLabel(){
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.person_outline),
        hintText:"Label this Smart Scale!",
        hintStyle: Font.style(17,Colors.black54),
        errorStyle: Font.style(15,Colors.red),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:Colors.black54))
    ),
      validator:(String value){
        if (value.isEmpty){
          return "Label is required";
        }
        return null;
      },
      onSaved: (String value){
        _label = value[0].toUpperCase() + value.substring(1);
        // Capitalises name
      }
    );
  }

  Widget _buildRemarks(){
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.home),
        hintText:"Remarks(optional)",
        hintStyle: Font.style(17,Colors.black54),
        errorStyle: Font.style(15,Colors.red),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:Colors.black54))
      ),
      onSaved: (String value){
        if (value == null){
          _remarks = "nil";
        }
        else _remarks = value;
      }
    );
  }

  List<DropdownMenuItem<String>> buildDropDownList(List<String> preferences){
    List<DropdownMenuItem<String>> items = List();
    for (String preference in preferences){
      items.add(
        DropdownMenuItem(
          value: preference,
          child: Container(
            child:Text(
              preference,
              style: Font.style(17, Colors.black54),
              textAlign: TextAlign.center
            ),
          ),
        )
      );
    }
    return items;
  }

  Widget _buildDropDownMenu(){
    return Row(
      children:<Widget>[
        Container(
          child: Icon(Icons.router,color:Colors.black54),
          constraints: BoxConstraints.tightFor(width:30,height:30),
          alignment: Alignment.bottomLeft
        ),
        Padding(padding:EdgeInsets.only(right:10)),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black54,
              )
          )),
          constraints: BoxConstraints.tightFor(width:328),
          child: Theme(
            data: Theme.of(context).copyWith(
            canvasColor: Colors.amber[300]
            ),
            child:DropdownButtonHideUnderline(
              child:DropdownButton(
                value: selectedItem,
                items: itemMenu,
                onChanged: (String newPref){
                  setState((){
                    selectedItem = newPref;
                  });
                },
              )
            )
        ))]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[300],
      appBar: AppBar(
        title: Text("Setup New Scale",
          style:Font.style(20,Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.amber[700],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal:20,vertical:30),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildLabel(),
                Padding(padding:EdgeInsetsDirectional.only(top:25)),
                _buildRemarks(),
                Padding(padding:EdgeInsetsDirectional.only(top:25)),
                _buildDropDownMenu(),
                Padding(padding:EdgeInsetsDirectional.only(top:70)),
                RaisedButton(
                  child: Text("Submit", style: Font.style(20,Colors.white)),
                  color: Colors.amber[700],
                  padding: EdgeInsets.symmetric(vertical:18,horizontal:40),
                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(25)),
                  onPressed:() {
                    if (!_formKey.currentState.validate()){
                      return;
                    }
                    _formKey.currentState.save();

                    ProductSpecs _productSpecs;
                    for (int i =0; i<itemList.length; i++){
                      if (selectedItem == itemList[i]) {
                        _productSpecs = specsList[i-1];
                        // itemList has 1 item more than specsList because of "--Select Item--"
                      }
                    }
                    Data data = Data(_label,_remarks,"Loading...",_productSpecs);
                    Data.sendData(data, scalePreference);
                    // upload data to database
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => SmartScaleList()
                    ));
                },
              ),
            ]
        )))
      )
    );
  }
}