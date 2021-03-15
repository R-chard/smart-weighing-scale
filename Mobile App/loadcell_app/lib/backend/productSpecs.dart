import "package:shared_preferences/shared_preferences.dart";

class ProductSpecs{
  // Stores product specification -> Max and Min weight of each item the user keys in

  String itemName;
  String maxW;
  String minW;
  String capacity;
  static List<String> keyList = List<String>(); //Collection of all the names of the items

  ProductSpecs(this.itemName,this.maxW, this.minW, this.capacity);

  Future<bool> setItemSpecs() async{
    List<String> itemSpecs = [itemName, maxW, minW, capacity];
    // can only save strings in shared preferences
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList(itemName,itemSpecs);
    return _addKey(itemName);
    // stores the name of keys after they new item is added
  }

  static Future<ProductSpecs> getItemSpecs(String key) async{
    //returns an object containing all the specs of the item
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> itemSpecs = pref.getStringList(key);
    ProductSpecs specs = ProductSpecs(itemSpecs[0],itemSpecs[1],itemSpecs[2],itemSpecs[3]);
    return specs;
  }

  Future<bool> _addKey(String key){
    getKeyList().then((storedKeyList){
      ProductSpecs.keyList = storedKeyList;
      keyList.add(key);
      return setKeyList(keyList);
    });
  }

  static void removeKey(String key) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(key);
    getKeyList().then((_keyList){
      _keyList.forEach((_key){
        if (_key == key){
          _keyList.remove(_key);
          setKeyList(_keyList);
        }
      });
    });
  }

  static Future<List<String>> getKeyList() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getStringList("keys") == null){
      pref.setStringList("keys", []);
    }
    return pref.getStringList("keys");
  }

  static Future<bool> setKeyList(List<String> _keyList) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setStringList("keys",_keyList);
  }
}