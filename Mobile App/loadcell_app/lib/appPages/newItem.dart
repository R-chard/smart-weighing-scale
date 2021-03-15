import "package:flutter/material.dart";
import "package:loadcellapp/backend/font.dart";
import "package:loadcellapp/backend/productSpecs.dart";
import "itemList.dart";

class NewLoad extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewLoadState();
  }
}

class NewLoadState extends State<NewLoad> {

  String _label;
  String _maxW;
  String _minW;
  String _maxV;
  bool acceptableMaxW = true;

  List<String> options = ["------ Item type ------", "Liquid/Granular Solids/Gas","Large Solids"];
  String selectedOption;
  List<DropdownMenuItem<String>> menuItems;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget widgetsToShow;

   @override
    void initState(){
    super.initState();
    selectedOption = options[0];
    menuItems = buildDropDownList(options);
    widgetsToShow = Container();
   }

  List<DropdownMenuItem<String>> buildDropDownList(List<String> options) {
    List<DropdownMenuItem<String>> listItems = List();
    for (String option in options) {

      Widget icon;

      switch (option){
        case "Liquid/Granular Solids/Gas":
          icon = Image.asset("lib/assets/images/wine_bottle_icon.png");
          break;
        case "Large Solids":
          icon = Image.asset("lib/assets/images/container_icon.png");
          break;
        default:
          icon = Container();
      }

      listItems.add(
        DropdownMenuItem(
          value: option,
          child: Container(
            child: ListTile(
            leading: Container(
              constraints: BoxConstraints.tightFor(width:50,height:50),
              child: icon
            ),
              title:Text(
               option,
               style: Font.style(16, Colors.black54),
              )
            ),
            constraints: BoxConstraints.tightFor(width:280, height:60),
          ),
      )
      );
    }
    return listItems;
  }

   @override
   Widget build(BuildContext context) {
     // Need product min/ max W, min/Max V
     return Scaffold(
      backgroundColor: Colors.amber[300],
      appBar: AppBar(
        title: Text("Add New Item",
        style:Font.style(20,Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.amber[700],
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children :<Widget>[
                Padding(padding:EdgeInsets.symmetric(vertical: 50)),
                Container(
                  decoration:BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  constraints: BoxConstraints.tightFor(width:320, height: 70),
                  alignment:Alignment.center,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.amber[700]
                    ),
                    child:DropdownButtonHideUnderline(
                      child:DropdownButton(
                        value: selectedOption,
                        items: menuItems,
                        onChanged: (String newChoice){
                          setState((){
                            selectedOption = newChoice;
                            selectedBuild(selectedOption);
                            // change the widgets built
                          });
                        },
                  )))),
                widgetsToShow,
              ]
            )
          )
        ),
        alignment: Alignment.topCenter,
      )
     );
   }

   selectedBuild(String selectedOption){
     if (selectedOption == options[0]){
       setState((){
         widgetsToShow = Container();
       });
     }
     else if (selectedOption == options[1]){
       setState((){
         widgetsToShow = _addNewLiquid();
       });
     }
     else if (selectedOption == options[2]){
       setState((){
         widgetsToShow = _addNewSolids();
       });
     }
   }

   Widget _buildSubmitButton(){
     return RaisedButton(
       child: Text("Submit", style: Font.style(20,Colors.white)),
       color: Colors.amber[700],
       padding: EdgeInsets.symmetric(vertical:18,horizontal:40),
       shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(25)),
       onPressed:() {
         if (!_formKey.currentState.validate()){
           return;
         }
         _formKey.currentState.save();
         ProductSpecs specs = ProductSpecs(_label,_maxW,_minW,_maxV);
         specs.setItemSpecs().then((dataSaved){
           // only load when data is saved to database
           Navigator.push(context, MaterialPageRoute(
               builder: (context) => LoadList()));
         });
       }
     );

   }

   Widget _addNewSolids(){
     return SingleChildScrollView(
       child: Column(
         children: <Widget>[
            Padding(padding:EdgeInsets.symmetric(vertical:50)),
            Text("Coming soon!",style: Font.style(18, Colors.black54),)
         ],
       )
     );
   }

   Widget _addNewLiquid(){
     return SingleChildScrollView(
       child: Column(
         children: <Widget>[
           Padding(padding:EdgeInsets.symmetric(vertical:10)),
           _buildName(),
           Padding(padding:EdgeInsets.symmetric(vertical:10)),
           _buildMaxWeight(),
           Padding(padding:EdgeInsets.symmetric(vertical:10)),
           _buildMinWeight(),
           Padding(padding:EdgeInsets.symmetric(vertical:10)),
           _buildCapacity(),
           Padding(padding:EdgeInsets.symmetric(vertical:20)),
           _buildSubmitButton()
         ]
       )
     );
   }

   Widget _buildName(){
     return TextFormField(
       decoration: InputDecoration(
           icon: Icon(Icons.person_outline),
           hintText:"Brand/Model",
           hintStyle: Font.style(17,Colors.black54),
           errorStyle: Font.style(15,Colors.red),
           enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:Colors.black54))
         ),
         validator:(String value){
           if (value.isEmpty){
             return "Name is required";
           }
           return null;
         },
         onSaved: (String value){
           _label = value[0].toUpperCase() + value.substring(1);
           // Capitalises name
         }
     );
   }

  Widget _buildMaxWeight(){
    return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.hourglass_full),
          hintText: "Weight(kg) when full",
          hintStyle: Font.style(17,Colors.black54),
          errorStyle: Font.style(15,Colors.red),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color:Colors.black54)),
        ),
        validator:(String value){
          if (value.isEmpty){
            return "Maximum weight is required";
          }
          else if (double.tryParse(value) == null){
            return "That is not an acceptable weight";
          }
          _maxW = value;
          acceptableMaxW = true;
          return null;
        },
        onSaved: (String value){
          _maxW = value;
        }
    );
  }

  Widget _buildMinWeight(){
    return TextFormField(
        decoration: InputDecoration(
            icon: Icon(Icons.hourglass_empty),
            hintText: "Weight(kg) when empty",
            hintStyle: Font.style(17,Colors.black54),
            errorStyle: Font.style(15,Colors.red),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:Colors.black54))
        ),
        validator:(String value){
          if (value.isEmpty){
            return "Minimum weight is required";
          }
          else if (double.tryParse(value) == null) {
            return "That is not an acceptable weight";
          }
          else if(acceptableMaxW){
            if (double.parse(value) > double.parse(_maxW)){
              return "Min weight cannot be > than maximum!";
            }
          }
          return null;
        },
        onSaved: (String value){
          _minW = value;
        }
    );
  }

  Widget _buildCapacity(){
    return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.hourglass_full),
          hintText: "Capacity(ml)",
          hintStyle: Font.style(17,Colors.black54),
          errorStyle: Font.style(15,Colors.red),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color:Colors.black54)),
        ),
        validator:(String value){
          if (value.isEmpty){
            return "Maximum volume is required";
          }
          else if (double.tryParse(value) == null){
            return "That is not an acceptable volume";
          }
          else if (double.parse(value) <0){
              return "Capacity cannot be below 0!";
          }
          return null;
        },
        onSaved: (String value){
          _maxV = value.toString();
        }
    );
  }
}
