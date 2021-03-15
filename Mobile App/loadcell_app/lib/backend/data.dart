import "package:firebase_database/firebase_database.dart";
import "productSpecs.dart";

const String FIREBASE_URL = "https://smart-weighing-scale.firebaseio.com";
const String GOOGLE_APP_ID = "1:918817650316:android:2bd5958d504140b71feda9";
const String API_KEY = "AIzaSyB9Rg3U5D1UadKEqZZaogV-61klrO6cqRg";

class Data {

  String label;
  String remarks;
  String weight;
  ProductSpecs productSpecs;

  Data( this.label, this.remarks, this.weight, this.productSpecs);
  // default constructor used when receiving data

  static sendData(Data data, String scalePreference){
    DatabaseReference userDataRef = FirebaseDatabase.instance.reference().child("UserData").push();
    userDataRef.set({"Label":data.label, "Remarks":data.remarks, "Weight":"Loading...","Display":scalePreference});
    DatabaseReference productRef = userDataRef.child("Product");
    productRef.set({"Type":"Liquid","MaxW":data.productSpecs.maxW,
      "MinW":data.productSpecs.minW, "Capacity": data.productSpecs.capacity, "ItemName":data.productSpecs.itemName});
    String keyName = userDataRef.path.toString().substring(9);
    // The newly generated key's name is UserData/XXX. Hence cut from the 9th value
    String command = "read" + keyName;
    var exchangeRef = FirebaseDatabase.instance.reference().child("Exchange");
    exchangeRef.set({'Command': command});
  }

  static changeScalePref(String preference, String firebaseKey){
    // change scale preference of all scales currently
    DatabaseReference userDataRef = FirebaseDatabase.instance.reference().child("UserData").child(firebaseKey);
    userDataRef.update({"Display":preference});
  }

  static Future<List<Data>> () async {

    DataSnapshot snapshot = await FirebaseDatabase.instance.reference()
        .child("UserData").once();

    List<Data> database = [];
    var keys = snapshot.value.keys;
    var storedValue = snapshot.value;

    for(var indivKey in keys) {

      String weight;
      ProductSpecs productSpecs;
      if (double.tryParse(storedValue[indivKey]["Weight"]) == null) {
        weight = "Loading...";
      }
      else weight = storedValue[indivKey]["Weight"];
      // Doing a check to see if Arduino has set the value yet

      String productType = storedValue[indivKey]["Product"]["Type"];
      if (productType == "Liquid"){
        productSpecs = ProductSpecs(
          storedValue[indivKey]["Product"]["ItemName"],
          storedValue[indivKey]["Product"]["MaxW"].toString(),
          storedValue[indivKey]["Product"]["MinW"].toString(),
          storedValue[indivKey]["Product"]["Capacity"].toString()
        );
      }

      Data data = Data(storedValue[indivKey]["Label"], storedValue[indivKey]["Remarks"],
          weight, productSpecs);

      database.add(data);
    }
      return database;
    // each element in database is a data object with a user's details
  }

  static Future<Map<String,String>> getFBkeysToScaleLabel() async{
    Map<String,String> scaleLabelList = Map();

    DataSnapshot snapshot = await FirebaseDatabase.instance.reference()
        .child("UserData").once();

    var keys = snapshot.value.keys;

    for(var indivKey in keys) {
      scaleLabelList[snapshot.value[indivKey]["Label"]] = indivKey;
    }

    return scaleLabelList;
  }

}